import type { NoteData } from "./note.js";
import { serializeNote, deserializeNote } from "./note.js";

/// Abstract storage backend for notes. Implement this for your environment
/// (file system, database, browser IndexedDB, etc.)
export interface NoteStorage {
  /// Load all stored note URIs
  load(): Promise<string[]>;
  /// Save all note URIs (overwrites previous state)
  save(notes: string[]): Promise<void>;
}

/// In-memory note storage (for testing or ephemeral use)
export class MemoryNoteStorage implements NoteStorage {
  private notes: string[] = [];

  async load(): Promise<string[]> {
    return [...this.notes];
  }

  async save(notes: string[]): Promise<void> {
    this.notes = [...notes];
  }
}

/// File-based note storage (for Node.js CLI / server use)
export class FileNoteStorage implements NoteStorage {
  constructor(private readonly filePath: string) {}

  async load(): Promise<string[]> {
    try {
      const { readFile } = await import("fs/promises");
      const content = await readFile(this.filePath, "utf-8");
      return content
        .split("\n")
        .filter((line) => line.trim().length > 0);
    } catch {
      return [];
    }
  }

  async save(notes: string[]): Promise<void> {
    const { writeFile, mkdir } = await import("fs/promises");
    const { dirname } = await import("path");
    await mkdir(dirname(this.filePath), { recursive: true });
    await writeFile(this.filePath, notes.join("\n") + "\n", "utf-8");
  }
}

/// Manages a collection of shielded notes with FIFO selection for spending
export class NoteManager {
  private _notes: Map<string, NoteData> = new Map();
  private readonly _storage: NoteStorage;

  constructor(storage: NoteStorage) {
    this._storage = storage;
  }

  /// Load notes from storage
  async init(): Promise<void> {
    const uris = await this._storage.load();
    this._notes.clear();
    for (const uri of uris) {
      try {
        const note = deserializeNote(uri);
        const key = this._noteKey(note);
        this._notes.set(key, note);
      } catch {
        // Skip malformed notes
      }
    }
  }

  /// Add a note and persist
  async addNote(note: NoteData): Promise<void> {
    const key = this._noteKey(note);
    this._notes.set(key, note);
    await this._persist();
  }

  /// Remove a note by its key and persist
  async removeNote(note: NoteData): Promise<void> {
    const key = this._noteKey(note);
    this._notes.delete(key);
    await this._persist();
  }

  /// Update a note's index after deposit confirmation
  async setNoteIndex(note: NoteData, index: number): Promise<void> {
    const key = this._noteKey(note);
    const existing = this._notes.get(key);
    if (existing) {
      existing.index = index;
      await this._persist();
    }
  }

  /// Get all notes for a specific chain and anchor
  getNotes(targetChainId: number, targetAnchor: string): NoteData[] {
    return [...this._notes.values()].filter(
      (n) =>
        n.targetChainId === targetChainId &&
        n.targetAnchor.toLowerCase() === targetAnchor.toLowerCase() &&
        n.index !== undefined
    );
  }

  /// Select notes FIFO until the target amount is covered.
  /// Returns the selected notes and the change amount.
  selectNotesFifo(
    targetChainId: number,
    targetAnchor: string,
    targetAmount: bigint
  ): { selected: NoteData[]; totalInput: bigint; change: bigint } {
    const available = this.getNotes(targetChainId, targetAnchor).sort(
      (a, b) => (a.index ?? 0) - (b.index ?? 0)
    );

    const selected: NoteData[] = [];
    let totalInput = 0n;

    for (const note of available) {
      if (totalInput >= targetAmount) break;
      selected.push(note);
      totalInput += note.amount;
    }

    if (totalInput < targetAmount) {
      throw new Error(
        `Insufficient shielded balance: have ${totalInput}, need ${targetAmount}`
      );
    }

    return {
      selected,
      totalInput,
      change: totalInput - targetAmount,
    };
  }

  /// Get total shielded balance for a chain/anchor
  getBalance(targetChainId: number, targetAnchor: string): bigint {
    return this.getNotes(targetChainId, targetAnchor).reduce(
      (sum, n) => sum + n.amount,
      0n
    );
  }

  /// Get all notes
  getAllNotes(): NoteData[] {
    return [...this._notes.values()];
  }

  private _noteKey(note: NoteData): string {
    return `${note.targetChainId}:${note.targetAnchor}:${note.privateKey}:${note.blinding}`;
  }

  private async _persist(): Promise<void> {
    const uris = [...this._notes.values()].map(serializeNote);
    await this._storage.save(uris);
  }
}
