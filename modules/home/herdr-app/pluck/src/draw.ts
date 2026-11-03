import type { Piece, Screen } from "./layout";
import type { Phase } from "./phase";

export interface Picture {
  screen: Screen;
  phase: Phase;
  height: number;
}

const CSI = "\x1b[";

// Autowrap off, so a hint wider than a token at the right edge is cut instead
// of spilling onto the next row.
export const ENTER = `${CSI}?1049h${CSI}?25l${CSI}?7l`;
export const LEAVE = `${CSI}?7h${CSI}?25h${CSI}?1049l`;

export const STYLE = {
  screen: `${CSI}0;2m`,
  token: `${CSI}0;33m`,
  hint: `${CSI}0;1;30;43m`,
  picked: `${CSI}0;1;30;42m`,
  note: `${CSI}0;7m`,
};

export function draw({ screen, phase, height }: Picture): string {
  const out = [`${CSI}0m${CSI}2J`];
  screen.rows.forEach((text, row) => out.push(at(row, 0), STYLE.screen, text));
  for (const { token, pieces } of screen.tokens) {
    const style = phase.kind === "picked" && token.text === phase.text ? STYLE.picked : STYLE.token;
    for (const { row, column, text } of pieces) out.push(at(row, column), style, text);
    if (phase.kind !== "typing") continue;
    const hint = screen.hints.get(token.text);
    if (hint?.startsWith(phase.typed)) out.push(...hintOver(pieces, hint, phase.typed.length));
  }
  if (phase.kind === "empty")
    out.push(at(height - 1, 0), `${CSI}2K`, STYLE.note, ` ${phase.note} `);
  out.push(`${CSI}0m`);
  return out.join("");
}

// The hint's letters from `from` on, over the token's first cells. A token cut
// by the right edge carries them onto its next piece.
function hintOver(pieces: readonly Piece[], hint: string, from: number): string[] {
  const out: string[] = [];
  let start = 0;
  pieces.forEach(({ row, column, text }, i) => {
    const end = i === pieces.length - 1 ? hint.length : start + Bun.stringWidth(text);
    const [lo, hi] = [Math.max(from, start), Math.min(hint.length, end)];
    if (lo < hi) out.push(at(row, column + lo - start), STYLE.hint, hint.slice(lo, hi));
    start = end;
  });
  return out;
}

const at = (row: number, column: number) => `${CSI}${row + 1};${column + 1}H`;
