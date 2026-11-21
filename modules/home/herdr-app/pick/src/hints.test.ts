import { describe, expect, test } from "bun:test";
import { assignHints, hintCodes } from "./hints";

describe("hintCodes", () => {
  test("gives a letter each while the letters last", () => {
    expect(hintCodes(3)).toEqual(["a", "s", "d"]);
    expect(hintCodes(26).every((hint) => hint.length === 1)).toBe(true);
  });

  test.each([27, 100, 676])("gives %i distinct hints, none starting another", (count) => {
    const hints = hintCodes(count);
    expect(new Set(hints).size).toBe(count);
    expect(hints.some((a) => hints.some((b) => a !== b && b.startsWith(a)))).toBe(false);
  });

  test("keeps as many single letters as it can", () => {
    expect(hintCodes(27).filter((hint) => hint.length === 1)).toHaveLength(25);
  });
});

describe("assignHints", () => {
  test("leaves the texts past the last hint without one", () => {
    const pairs = 26 ** 2;
    const places = Array.from({ length: pairs + 1 }, (_, row) => ({
      text: String(row),
      row,
      column: 0,
    }));
    const hints = assignHints(places);
    expect(hints.size).toBe(pairs);
    expect(hints.has("0")).toBe(false);
  });

  test("deals from the bottom row up and shares a hint between copies", () => {
    const place = (row: number, column: number, text: string) => ({ text, row, column });
    const hints = assignHints([place(0, 0, "old"), place(1, 0, "new"), place(1, 9, "old")]);
    expect([...hints]).toEqual([
      ["new", "a"],
      ["old", "s"],
    ]);
  });
});
