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

type Candidate = Token & { rank: number };

// RFC 3986's URL characters, less the ' that quotes a URL in prose. ASCII only,
// so Japanese punctuation ends a URL.
const URL_CHAR = String.raw`[A-Za-z0-9\-._~:/?#\[\]@!$&()*+,;=%]`;
const GIT_STATUS_LABELS = [
  "added by them",
  "added by us",
  "both added",
  "both deleted",
  "both modified",
  "copied",
  "deleted",
  "deleted by them",
  "deleted by us",
  "modified",
  "new file",
  "renamed",
  "typechange",
  "unknown",
  "unmerged",
].join("|");
const SUBMODULE_NOTE = String.raw`\((?:new commits|modified content|untracked content)[^)]*\)`;
const PATH_CHAR = String.raw`[\w.\-@+%~]`;
const OCTET = String.raw`(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)`;

const URL: Kind = {
  re: new RegExp(
    String.raw`\b(?:(?:file|ftp|git|https?|ssh):\/\/|git@[\w.\-]+:)${URL_CHAR}+`,
    "dgi",
  ),
  trim: true,
};
const GIT_STATUS_PATH: Kind = {
  re: new RegExp(
    String.raw`^[\s⎿]*(?=(?:${GIT_STATUS_LABELS}):)(?:.{12}|.{17})(?<=:\s+)(?:\S.*? -> )?(?<token>"(?:[^"\\]|\\.)*"|\S(?:.*?\S)?)(?=\s*(?:${SUBMODULE_NOTE})?\s*$)`,
    "dg",
  ),
};
const DIFF_PATH: Kind = { re: /(?:^|\s)(?:---|\+\+\+) [ab]\/(?<token>\S+)/dg };
const PATH: Kind = {
  re: new RegExp(
    String.raw`(?<!${PATH_CHAR})${PATH_CHAR}*(?:\/${PATH_CHAR}+)+\/?(?::\d+){0,2}`,
    "dg",
  ),
  trim: true,
};
const UUID: Kind = { re: /\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b/dgi };
const COMMIT: Kind = { re: /\b(?=[0-9a-f]*[a-f])(?=[0-9a-f]*\d)[0-9a-f]{7,40}\b/dg };
const IPV4: Kind = {
  re: new RegExp(String.raw`\b(?:${OCTET}\.){3}${OCTET}(?::\d{1,5})?\b`, "dg"),
};
const NUMBER: Kind = { re: /\b\d{4,}\b/dg };

// Where two overlap, the earlier kind wins, then the longer token, then the
// earlier one on screen.
const KINDS = [URL, GIT_STATUS_PATH, DIFF_PATH, PATH, UUID, COMMIT, IPV4, NUMBER];

const OPENABLE = /^https?:\/\//i;

export function findTokens(lines: readonly string[]): Token[] {
  return resolveOverlaps(candidates(lines, KINDS));
}

export function findUrls(lines: readonly string[]): Token[] {
  return resolveOverlaps(candidates(lines, [URL]).filter((c) => OPENABLE.test(c.text)));
}

function candidates(lines: readonly string[], kinds: readonly Kind[]): Candidate[] {
  return lines.flatMap((text, line) =>
    kinds.flatMap((kind, rank) => matches(text, line, kind, rank)),
  );
}

function matches(text: string, line: number, kind: Kind, rank: number): Candidate[] {
  return [...text.matchAll(kind.re)].flatMap((m) => {
    const [start, end] = m.indices!.groups?.token ?? m.indices![0]!;
    const taken = text.slice(start, end);
    const token = kind.trim ? trimSentenceEnd(taken) : taken;
    return /[^/]/.test(token) ? [{ line, start, text: token, rank }] : [];
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

function resolveOverlaps(candidates: Candidate[]): Token[] {
  const preferred = candidates.toSorted(
    (a, b) => a.rank - b.rank || b.text.length - a.text.length || byPosition(a, b),
  );
  const kept: Candidate[] = [];
  for (const c of preferred) {
    if (!kept.some((k) => k.line === c.line && k.start < endOf(c) && c.start < endOf(k))) {
      kept.push(c);
    }
  }
  return kept.map(({ rank: _, ...token }) => token).sort(byPosition);
}

const endOf = (t: Token) => t.start + t.text.length;

const byPosition = (a: Token, b: Token) => a.line - b.line || a.start - b.start;
