import { describe, expect, test } from "bun:test";
import { draw, STYLE } from "./draw";
import type { Piece, Screen } from "./layout";
import type { Phase } from "./phase";

const one = (row: number, column: number, text: string) => ({
  token: { line: row, start: column, text },
  pieces: [{ row, column, text }],
});

const screen = (
  rows: string[],
  tokens: Screen["tokens"],
  hints: Record<string, string>,
): Screen => ({ rows, tokens, hints: new Map(Object.entries(hints)) });

const typing = (typed = ""): Phase => ({ kind: "typing", typed });

const at = (row: number, column: number) => `\x1b[${row};${column}H`;

describe("draw", () => {
  test("puts a hint on the token's first cell", () => {
    const shown = screen(["", "日本 https://a.test"], [one(1, 5, "https://a.test")], {
      "https://a.test": "a",
    });
    expect(draw({ screen: shown, phase: typing(), height: 24 })).toContain(
      `${at(2, 6)}${STYLE.hint}a`,
    );
  });

  test("carries a hint the right edge cuts onto the token's next piece", () => {
    const pieces: Piece[] = [
      { row: 0, column: 19, text: "/" },
      { row: 1, column: 0, text: "tmp/abc" },
    ];
    const token = { line: 0, start: 19, text: "/tmp/abc" };
    const shown = screen(["x".repeat(19) + "/", "tmp/abc"], [{ token, pieces }], {
      "/tmp/abc": "md",
    });
    const out = draw({ screen: shown, phase: typing(), height: 24 });
    expect(out).toContain(`${at(1, 20)}${STYLE.hint}m`);
    expect(out).toContain(`${at(2, 1)}${STYLE.hint}d`);
  });

  test("moves past the letters already typed", () => {
    const shown = screen(["/tmp/x"], [one(0, 0, "/tmp/x")], { "/tmp/x": "ma" });
    const out = draw({ screen: shown, phase: typing("m"), height: 24 });
    expect(out).toContain(`${at(1, 2)}${STYLE.hint}a`);
    expect(out).not.toContain(`${STYLE.hint}ma`);
  });

  test("drops a hint that what was typed rules out", () => {
    const shown = screen(["/tmp/x"], [one(0, 0, "/tmp/x")], { "/tmp/x": "sa" });
    expect(draw({ screen: shown, phase: typing("m"), height: 24 })).not.toContain(STYLE.hint);
  });

  test("marks the pick in place of every hint", () => {
    const shown = screen(
      ["https://a.test https://b.test"],
      [one(0, 0, "https://a.test"), one(0, 15, "https://b.test")],
      { "https://a.test": "a", "https://b.test": "s" },
    );
    const out = draw({
      screen: shown,
      phase: { kind: "picked", text: "https://a.test" },
      height: 24,
    });
    expect(out).toContain(`${STYLE.picked}https://a.test`);
    expect(out).not.toContain(STYLE.hint);
  });

  test("says on the bottom row that there is nothing to pick", () => {
    const out = draw({
      screen: screen(["no links"], [], {}),
      phase: { kind: "empty", note: "no URL" },
      height: 5,
    });
    expect(out).toContain(`${at(5, 1)}\x1b[2K${STYLE.note} no URL `);
  });
});
