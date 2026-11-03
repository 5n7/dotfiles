import { describe, expect, test } from "bun:test";
import { type Phase, press } from "./phase";

const hints = new Map([
  ["/tmp/a", "a"],
  ["/tmp/b", "ma"],
  ["/tmp/c", "ms"],
]);

const typing = (typed = ""): Phase => ({ kind: "typing", typed });

describe("press", () => {
  test("picks the text whose hint a letter completes, in either case", () => {
    expect(press(hints, typing(), "a")).toEqual({ kind: "picked", text: "/tmp/a" });
    expect(press(hints, typing("m"), "S")).toEqual({ kind: "picked", text: "/tmp/c" });
  });

  test("waits on a letter that starts a hint", () => {
    expect(press(hints, typing(), "m")).toEqual(typing("m"));
  });

  test("clears what was typed on a letter that starts no hint", () => {
    expect(press(hints, typing("m"), "z")).toEqual(typing(""));
  });

  test("takes a letter back on backspace and ignores other keys", () => {
    expect(press(hints, typing("m"), "\x7f")).toEqual(typing(""));
    expect(press(hints, typing("m"), "1")).toEqual(typing("m"));
  });

  test("reads keys that arrive together in order, stopping at a pick", () => {
    expect(press(hints, typing(), "ma")).toEqual({ kind: "picked", text: "/tmp/b" });
    expect(press(hints, typing(), "as")).toEqual({ kind: "picked", text: "/tmp/a" });
  });

  test("quits on Esc and Ctrl+C, and on any key when there is nothing to pick", () => {
    expect(press(hints, typing("m"), "\x1b")).toBe("quit");
    expect(press(hints, typing(), "m\x03")).toBe("quit");
    expect(press(hints, { kind: "empty", note: "nothing" }, "a")).toBe("quit");
  });

  test("leaves the phase alone on an escape sequence", () => {
    const phase = typing("m");
    expect(press(hints, phase, "\x1b[A")).toBe(phase);
  });

  test("skips escape sequences among other keys, and quits on any bare Esc", () => {
    expect(press(hints, typing(), "m\x1b[A")).toEqual(typing("m"));
    expect(press(hints, typing(), "\x1bOPm")).toEqual(typing("m"));
    expect(press(hints, typing(), "\x1b\x1b")).toBe("quit");
  });
});
