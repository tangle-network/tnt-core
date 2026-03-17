import { poseidonHash2 } from "./poseidon.js";
import { ZERO_VALUE } from "./constants.js";

/// Merkle proof for a leaf at a given index
export interface MerkleProof {
  pathElements: bigint[];
  pathIndices: number;
  root: bigint;
}

/// Incremental Poseidon Merkle tree (mirrors the on-chain MerkleTreeWithHistory)
export class MerkleTree {
  readonly levels: number;
  private _layers: bigint[][];
  private _zeroValues: bigint[];

  private constructor(levels: number, layers: bigint[][], zeros: bigint[]) {
    this.levels = levels;
    this._layers = layers;
    this._zeroValues = zeros;
  }

  /// Create an empty tree with the given height
  static async create(levels: number): Promise<MerkleTree> {
    const zeros = await MerkleTree._computeZeros(levels);
    const layers: bigint[][] = [[]];
    for (let i = 1; i <= levels; i++) {
      layers.push([]);
    }
    return new MerkleTree(levels, layers, zeros);
  }

  /// Create a tree from existing leaves
  static async fromLeaves(
    levels: number,
    leaves: bigint[]
  ): Promise<MerkleTree> {
    const tree = await MerkleTree.create(levels);
    for (const leaf of leaves) {
      await tree.insert(leaf);
    }
    return tree;
  }

  /// Insert a leaf and recompute affected path
  async insert(leaf: bigint): Promise<number> {
    const index = this._layers[0].length;
    if (index >= 2 ** this.levels) {
      throw new Error("MerkleTree: tree is full");
    }

    this._layers[0].push(leaf);

    // Recompute path from leaf to root
    let currentIndex = index;
    let currentValue = leaf;

    for (let level = 0; level < this.levels; level++) {
      const isRight = currentIndex % 2 === 1;
      const siblingIndex = isRight ? currentIndex - 1 : currentIndex + 1;

      const sibling =
        siblingIndex < this._layers[level].length
          ? this._layers[level][siblingIndex]
          : this._zeroValues[level];

      const [left, right] = isRight
        ? [sibling, currentValue]
        : [currentValue, sibling];

      currentValue = await poseidonHash2(left, right);
      currentIndex = Math.floor(currentIndex / 2);

      if (currentIndex < this._layers[level + 1].length) {
        this._layers[level + 1][currentIndex] = currentValue;
      } else {
        this._layers[level + 1].push(currentValue);
      }
    }

    return index;
  }

  /// Get the current root
  get root(): bigint {
    if (this._layers[this.levels].length === 0) {
      return this._zeroValues[this.levels];
    }
    return this._layers[this.levels][0];
  }

  /// Get all leaves
  get leaves(): bigint[] {
    return [...this._layers[0]];
  }

  /// Get the number of inserted leaves
  get nextIndex(): number {
    return this._layers[0].length;
  }

  /// Generate a Merkle proof for the leaf at the given index
  async proof(index: number): Promise<MerkleProof> {
    if (index >= this._layers[0].length) {
      throw new Error(`MerkleTree: leaf at index ${index} not found`);
    }

    const pathElements: bigint[] = [];
    let currentIndex = index;
    let pathIndices = 0;

    for (let level = 0; level < this.levels; level++) {
      const isRight = currentIndex % 2 === 1;
      const siblingIndex = isRight ? currentIndex - 1 : currentIndex + 1;

      const sibling =
        siblingIndex < this._layers[level].length
          ? this._layers[level][siblingIndex]
          : this._zeroValues[level];

      pathElements.push(sibling);

      if (isRight) {
        pathIndices |= 1 << level;
      }

      currentIndex = Math.floor(currentIndex / 2);
    }

    return {
      pathElements,
      pathIndices,
      root: this.root,
    };
  }

  /// Find the index of a leaf by its value
  indexOf(leaf: bigint): number {
    return this._layers[0].indexOf(leaf);
  }

  /// Precompute zero values for each level
  private static async _computeZeros(levels: number): Promise<bigint[]> {
    const zeros: bigint[] = [ZERO_VALUE];
    for (let i = 1; i <= levels; i++) {
      zeros.push(await poseidonHash2(zeros[i - 1], zeros[i - 1]));
    }
    return zeros;
  }
}
