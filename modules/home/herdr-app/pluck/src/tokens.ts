export interface Token {
  line: number;
  start: number;
  text: string;
}

interface Kind {
  // With a `token` group, only the group is taken.
  re: RegExp;
  trim?: boolean;
}

type Candidate = Token & { reach: number };

const LINE_COLUMN = String.raw`(?::\d+(?::\d+)?)`;
const OCTET = String.raw`(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)`;
const PATH_CHAR = String.raw`[\w.\-@+%~]`;
const PORT = String.raw`(?::\d{1,5})`;
// RFC 3986's URL characters, less the ' that quotes a URL in prose. ASCII only,
// so Japanese punctuation ends a URL.
const URL_CHAR = String.raw`[A-Za-z0-9\-._~:/?#\[\]@!$&()*+,;=%]`;

const COMMIT: Kind = { re: /\b(?=[0-9a-f]*[a-f])(?=[0-9a-f]*\d)[0-9a-f]{7,40}\b/dg };
const DIFF_PATH: Kind = { re: /(?:^|\s)(?:---|\+\+\+) [ab]\/(?<token>\S+)/dg };
const IPV4: Kind = {
  re: new RegExp(String.raw`\b(?:${OCTET}\.){3}${OCTET}${PORT}?\b`, "dg"),
};
const NUMBER: Kind = { re: /\b\d{4,}\b/dg };
const PATH: Kind = {
  re: new RegExp(
    String.raw`(?<!${PATH_CHAR})${PATH_CHAR}*${PORT}?(?:\/${PATH_CHAR}+)+\/?${LINE_COLUMN}?`,
    "dg",
  ),
  trim: true,
};
const URL: Kind = {
  re: new RegExp(
    String.raw`\b(?:(?:file|ftp|git|https?|ssh):\/\/|git@[\w.\-]+:)${URL_CHAR}+`,
    "dgi",
  ),
  trim: true,
};
const UUID: Kind = { re: /\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b/dgi };

const KINDS = [COMMIT, DIFF_PATH, IPV4, NUMBER, PATH, URL, UUID];

const OPENABLE = /^https?:\/\//i;

export function findTokens(lines: readonly string[]): Token[] {
  return resolveOverlaps(candidates(lines, KINDS));
}

export function findUrls(lines: readonly string[]): Token[] {
  return resolveOverlaps(candidates(lines, [URL]).filter((c) => OPENABLE.test(c.text)));
}

function candidates(lines: readonly string[], kinds: readonly Kind[]): Candidate[] {
  return lines.flatMap((text, line) => kinds.flatMap((kind) => matches(text, line, kind)));
}

function matches(text: string, line: number, kind: Kind): Candidate[] {
  return [...text.matchAll(kind.re)].flatMap((m) => {
    const [start, end] = m.indices!.groups?.token ?? m.indices![0]!;
    const taken = text.slice(start, end);
    const token = kind.trim ? trimSentenceEnd(taken) : taken;
    return /[^/]/.test(token) ? [{ line, start, text: token, reach: m[0].length }] : [];
  });
}

const OPENING: Record<string, string> = { ")": "(", "]": "[" };
const DOT_SEGMENT = /(?:^|\/)\.\.$/;

function trimSentenceEnd(text: string): string {
  for (;;) {
    text = text.replace(/\.{3,}$/, "");
    const last = text.at(-1);
    if (last === undefined || (last === "." && DOT_SEGMENT.test(text))) return text;
    const open = OPENING[last];
    const unopened = open !== undefined && count(text, last) > count(text, open);
    if (!"!*,.:;?".includes(last) && !unopened) return text;
    text = text.slice(0, -1);
  }
}

const count = (text: string, char: string) => text.split(char).length - 1;

// Of two overlapping matches the longer wins, then the earlier on screen. So a
// URL beats the path inside it, and a diff path, whose match counts the +++ b/
// before it, beats the path that starts at b/.
function resolveOverlaps(candidates: Candidate[]): Token[] {
  const preferred = candidates.toSorted((a, b) => b.reach - a.reach || byPosition(a, b));
  const kept: Candidate[] = [];
  for (const c of preferred) {
    if (!kept.some((k) => k.line === c.line && k.start < endOf(c) && c.start < endOf(k))) {
      kept.push(c);
    }
  }
  return kept.map(({ reach: _, ...token }) => token).sort(byPosition);
}

const endOf = (t: Token) => t.start + t.text.length;

const byPosition = (a: Token, b: Token) => a.line - b.line || a.start - b.start;
