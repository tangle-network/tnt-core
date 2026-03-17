import { describe, it, expect, beforeEach } from "vitest";
import {
  serializeNote,
  deserializeNote,
  NoteManager,
  MemoryNoteStorage,
} from "../src/note/index.js";
import type { NoteData } from "../src/note/index.js";

function makeNote(overrides: Partial<NoteData> = {}): NoteData {
  return {
    sourceChainId: 1,
    targetChainId: 5,
    amount: 1000n,
    tokenSymbol: "TNT",
    targetAnchor: "0x1234567890abcdef1234567890abcdef12345678",
    privateKey: "0x" + "ab".repeat(32),
    blinding: "0x" + "cd".repeat(31),
    ...overrides,
  };
}

describe("serializeNote / deserializeNote", () => {
  it("should roundtrip a note without index", () => {
    const note = makeNote();
    const uri = serializeNote(note);
    const restored = deserializeNote(uri);

    expect(restored.sourceChainId).toBe(note.sourceChainId);
    expect(restored.targetChainId).toBe(note.targetChainId);
    expect(restored.amount).toBe(note.amount);
    expect(restored.tokenSymbol).toBe(note.tokenSymbol);
    expect(restored.targetAnchor).toBe(note.targetAnchor);
    expect(restored.privateKey).toBe(note.privateKey);
    expect(restored.blinding).toBe(note.blinding);
    expect(restored.index).toBeUndefined();
  });

  it("should roundtrip a note with index", () => {
    const note = makeNote({ index: 42 });
    const uri = serializeNote(note);
    const restored = deserializeNote(uri);
    expect(restored.index).toBe(42);
  });

  it("should produce a tangle:// URI", () => {
    const uri = serializeNote(makeNote());
    expect(uri).toMatch(/^tangle:\/\/v1:vanchor\//);
  });

  it("should preserve amount as bigint through roundtrip", () => {
    const note = makeNote({ amount: 999999999999999999n });
    const restored = deserializeNote(serializeNote(note));
    expect(restored.amount).toBe(999999999999999999n);
  });
});

describe("NoteManager with MemoryNoteStorage", () => {
  let manager: NoteManager;
  let storage: MemoryNoteStorage;

  beforeEach(async () => {
    storage = new MemoryNoteStorage();
    manager = new NoteManager(storage);
    await manager.init();
  });

  it("should start empty", () => {
    expect(manager.getAllNotes()).toHaveLength(0);
  });

  it("should add and retrieve notes", async () => {
    const note = makeNote({ index: 0 });
    await manager.addNote(note);
    const notes = manager.getNotes(5, note.targetAnchor);
    expect(notes).toHaveLength(1);
    expect(notes[0].amount).toBe(1000n);
  });

  it("should persist notes to storage", async () => {
    await manager.addNote(makeNote({ index: 0 }));
    const stored = await storage.load();
    expect(stored).toHaveLength(1);
    expect(stored[0]).toMatch(/^tangle:\/\//);
  });

  it("should remove notes", async () => {
    const note = makeNote({ index: 0 });
    await manager.addNote(note);
    expect(manager.getAllNotes()).toHaveLength(1);
    await manager.removeNote(note);
    expect(manager.getAllNotes()).toHaveLength(0);
  });

  it("should only return notes with index set via getNotes", async () => {
    const withIndex = makeNote({ index: 0, privateKey: "0x" + "01".repeat(32) });
    const withoutIndex = makeNote({ privateKey: "0x" + "02".repeat(32) });
    await manager.addNote(withIndex);
    await manager.addNote(withoutIndex);
    const notes = manager.getNotes(5, withIndex.targetAnchor);
    expect(notes).toHaveLength(1);
  });

  it("should compute balance", async () => {
    const anchor = "0x1234567890abcdef1234567890abcdef12345678";
    await manager.addNote(
      makeNote({ amount: 500n, index: 0, privateKey: "0x" + "01".repeat(32) })
    );
    await manager.addNote(
      makeNote({ amount: 300n, index: 1, privateKey: "0x" + "02".repeat(32) })
    );
    expect(manager.getBalance(5, anchor)).toBe(800n);
  });

  it("selectNotesFifo should select notes in index order", async () => {
    const anchor = "0x1234567890abcdef1234567890abcdef12345678";
    await manager.addNote(
      makeNote({ amount: 100n, index: 2, privateKey: "0x" + "01".repeat(32) })
    );
    await manager.addNote(
      makeNote({ amount: 200n, index: 0, privateKey: "0x" + "02".repeat(32) })
    );
    await manager.addNote(
      makeNote({ amount: 300n, index: 1, privateKey: "0x" + "03".repeat(32) })
    );

    const { selected, totalInput, change } = manager.selectNotesFifo(
      5,
      anchor,
      400n
    );

    // Should pick index 0 (200) then index 1 (300) = 500
    expect(selected).toHaveLength(2);
    expect(selected[0].amount).toBe(200n);
    expect(selected[1].amount).toBe(300n);
    expect(totalInput).toBe(500n);
    expect(change).toBe(100n);
  });

  it("selectNotesFifo should throw on insufficient balance", async () => {
    const anchor = "0x1234567890abcdef1234567890abcdef12345678";
    await manager.addNote(makeNote({ amount: 50n, index: 0 }));
    expect(() => manager.selectNotesFifo(5, anchor, 1000n)).toThrow(
      "Insufficient shielded balance"
    );
  });

  it("should reload notes from storage on init", async () => {
    await manager.addNote(makeNote({ index: 0 }));

    // Create a new manager with the same storage
    const manager2 = new NoteManager(storage);
    await manager2.init();
    expect(manager2.getAllNotes()).toHaveLength(1);
  });
});
