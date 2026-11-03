import { describe, expect, test } from "bun:test";
import { findTokens, findUrls } from "./tokens";

const texts = (lines: string[], find = findTokens) => find(lines).map((t) => t.text);

describe("URLs", () => {
  test("end at Japanese punctuation and the text after them", () => {
    expect(
      texts([
        "詳細はhttps://example.com/a_(b)。次は、https://github.com/5n7/dotfiles/pull/12、です",
      ]),
    ).toEqual(["https://example.com/a_(b)", "https://github.com/5n7/dotfiles/pull/12"]);
  });

  test("leave what a sentence or a bracket adds", () => {
    expect(
      texts(["see (https://a.test/path). <https://b.test/x?y=1&z=2>, [x](https://c.test)"]),
    ).toEqual(["https://a.test/path", "https://b.test/x?y=1&z=2", "https://c.test"]);
  });

  test("include git remotes", () => {
    expect(texts(["git@github.com:5n7/dotfiles.git ssh://host/repo"])).toEqual([
      "git@github.com:5n7/dotfiles.git",
      "ssh://host/repo",
    ]);
  });

  test("open only what a browser takes", () => {
    expect(
      texts(["https://a.test git@github.com:o/r.git file:///tmp/x 4ea006d"], findUrls),
    ).toEqual(["https://a.test"]);
  });
});

describe("paths", () => {
  test("keep an editor's line and column, not the sentence's period", () => {
    expect(texts(["at ./src/x.ts:12:5 and ~/src/github.com/5n7, see src/main.rs."])).toEqual([
      "./src/x.ts:12:5",
      "~/src/github.com/5n7",
      "src/main.rs",
    ]);
  });

  test("drop an ellipsis a bracket or comma follows, and a bare slash", () => {
    expect(texts(["(https://a.test/dir/...) https://b.test/dir/..., see /... here"])).toEqual([
      "https://a.test/dir/",
      "https://b.test/dir/",
    ]);
  });

  test("keep a .. segment, but not a sentence's period or ellipsis", () => {
    expect(
      texts(["cd ../.. then ~/foo/.. or src/a.ts... See https://a.test/docs/. or dir/..."]),
    ).toEqual(["../..", "~/foo/..", "src/a.ts", "https://a.test/docs/", "dir/"]);
  });

  test("take a git status path whole, spaces and git's quotes included", () => {
    expect(
      texts([
        "new file:   a b.txt",
        'modified:   "a\\"b.txt"',
        "modified:   lib (new commits)",
        "modified:   photo (1)",
      ]),
    ).toEqual(["a b.txt", '"a\\"b.txt"', "lib", "photo (1)"]);
  });

  test("read a git status label only as git aligns it", () => {
    expect(texts(["- modified: `src/main.ts` was moved"])).toEqual(["src/main.ts"]);
    expect(texts(["  deleted: the old config is no longer read"])).toEqual([]);
    expect(texts(["  modified: src/a.ts and src/b.ts"])).toEqual(["src/a.ts", "src/b.ts"]);
    expect(texts(["        both modified:   x y.txt"])).toEqual(["x y.txt"]);
  });

  test("take the path from git status and diffs", () => {
    expect(
      texts(["modified:   README.md", "renamed:    old.md -> new.md", "+++ b/src/lib.rs"]),
    ).toEqual(["README.md", "new.md", "src/lib.rs"]);
  });
});

describe("identifiers", () => {
  test("tell commits from words and numbers", () => {
    expect(texts(["commit 4ea006d defaced 1234567"])).toEqual(["4ea006d", "1234567"]);
  });

  test("find UUIDs, addresses and long numbers", () => {
    expect(
      texts(["id 123e4567-e89b-12d3-a456-426614174000 at 192.168.1.10:8080 pid 48213 of 12"]),
    ).toEqual(["123e4567-e89b-12d3-a456-426614174000", "192.168.1.10:8080", "48213"]);
  });
});

describe("overlaps", () => {
  test("a URL wins over the path and numbers inside it", () => {
    expect(texts(["open https://example.com/src/12345/main.rs"])).toEqual([
      "https://example.com/src/12345/main.rs",
    ]);
  });

  test("a captured path is placed where it sits in its line", () => {
    expect(findTokens(["modified:   a/b.ts"])).toEqual([{ line: 0, start: 12, text: "a/b.ts" }]);
  });
});
