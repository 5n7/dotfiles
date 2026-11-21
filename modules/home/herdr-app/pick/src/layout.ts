import { assignHints } from "./hints";
import type { Token } from "./tokens";

/** Part of a token on one screen row. */
export interface Piece {
  row: number;
  column: number;
  text: string;
}

export interface Screen {
  rows: string[];
  /** The tokens with a piece on screen, each with its pieces in order. */
  tokens: { token: Token; pieces: Piece[] }[];
  hints: Map<string, string>;
}

interface Span {
  line: number;
  start: number;
  end: number;
}

const graphemes = new Intl.Segmenter();

// hc read gives a screen's bottom lines with each wrapped line joined back into
// one. This lays them out as the terminal shows them: each line wrapped at the
// width, and only the bottom rows when they take more than the screen holds.
export function layOut(
  lines: readonly string[],
  tokens: readonly Token[],
  columns: number,
  rows: number,
): Screen {
  const spans = lines.flatMap((text, line) =>
    wrap(text, columns).map(([start, end]) => ({ line, start, end })),
  );
  const shown = spans.slice(Math.max(0, spans.length - rows));
  const visible = tokens.flatMap((token) => {
    const pieces = piecesOf(token, shown, lines[token.line]!);
    return pieces.length > 0 ? [{ token, pieces }] : [];
  });
  const places = visible.map(({ token, pieces: [first] }) => ({ ...first!, text: token.text }));
  return {
    rows: shown.map((span) => lines[span.line]!.slice(span.start, span.end)),
    tokens: visible,
    hints: assignHints(places),
  };
}

function wrap(text: string, columns: number): [number, number][] {
  const spans: [number, number][] = [];
  let start = 0;
  let width = 0;
  for (const { segment, index } of graphemes.segment(text)) {
    const cells = Bun.stringWidth(segment);
    if (width + cells > columns && index > start) {
      spans.push([start, index]);
      start = index;
      width = 0;
    }
    width += cells;
  }
  spans.push([start, text.length]);
  return spans;
}

function piecesOf(token: Token, shown: readonly Span[], text: string): Piece[] {
  const end = token.start + token.text.length;
  return shown.flatMap((span, row) => {
    if (span.line !== token.line || span.end <= token.start || end <= span.start) return [];
    const from = Math.max(token.start, span.start);
    const column = Bun.stringWidth(text.slice(span.start, from));
    return [{ row, column, text: text.slice(from, Math.min(end, span.end)) }];
  });
}
