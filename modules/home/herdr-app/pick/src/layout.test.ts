import { describe, expect, test } from "bun:test";
import { layOut } from "./layout";
import type { Token } from "./tokens";

const pieces = (screen: ReturnType<typeof layOut>) =>
  screen.tokens.flatMap(({ pieces }) => pieces.map(({ row, column, text }) => [row, column, text]));

describe("layOut", () => {
  test("wraps a line at the width, its tokens with it", () => {
    const token: Token = { line: 0, start: 4, text: "https://a.test/abc" };
    const screen = layOut(["see https://a.test/abc"], [token], 10, 5);
    expect(screen.rows).toEqual(["see https:", "//a.test/a", "bc"]);
    expect(pieces(screen)).toEqual([
      [0, 4, "https:"],
      [1, 0, "//a.test/a"],
      [2, 0, "bc"],
    ]);
    expect([...screen.hints]).toEqual([["https://a.test/abc", "a"]]);
  });

  test("moves a wide character that won't fit to the next row", () => {
    expect(layOut(["abc日本"], [], 4, 5).rows).toEqual(["abc", "日本"]);
  });

  test("keeps the bottom rows when the lines take more than the screen holds", () => {
    expect(layOut(["/tmp/a", "0123456789"], [], 5, 2).rows).toEqual(["01234", "56789"]);
  });

  test("gives hints only to tokens on screen", () => {
    const gone: Token = { line: 0, start: 0, text: "/tmp/gone" };
    const here: Token = { line: 2, start: 0, text: "/tmp/here" };
    const screen = layOut(["/tmp/gone", "", "/tmp/here"], [gone, here], 20, 2);
    expect([...screen.hints.keys()]).toEqual(["/tmp/here"]);
  });

  test("deals hints by screen row, so a wrapped line's lower rows come first", () => {
    const upper: Token = { line: 0, start: 0, text: "/tmp/upper" };
    const lower: Token = { line: 0, start: 11, text: "/tmp/lower" };
    const screen = layOut(["/tmp/upper /tmp/lower"], [upper, lower], 11, 5);
    expect([...screen.hints]).toEqual([
      ["/tmp/lower", "a"],
      ["/tmp/upper", "s"],
    ]);
  });
});
