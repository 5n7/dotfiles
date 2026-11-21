const ALPHABET = [..."asdfghjklqwertyuiopzxcvbnm"];

export function hintCodes(count: number): string[] {
  const k = ALPHABET.length;
  // A letter made a prefix trades its single hint for k pairs, k - 1 more.
  const prefixes = count <= k ? 0 : Math.min(k, Math.ceil((count - k) / (k - 1)));
  const singles = ALPHABET.slice(0, k - prefixes);
  const pairs = ALPHABET.slice(k - prefixes).flatMap((first) =>
    ALPHABET.map((second) => first + second),
  );
  return [...singles, ...pairs].slice(0, count);
}

/** Where a token's hint goes: its text, and its first cell on screen. */
export interface Place {
  text: string;
  row: number;
  column: number;
}

export function assignHints(places: readonly Place[]): Map<string, string> {
  const texts = [...new Set(places.toSorted(bottomUp).map((place) => place.text))];
  return new Map(hintCodes(texts.length).map((code, i) => [texts[i]!, code]));
}

const bottomUp = (a: Place, b: Place) => b.row - a.row || a.column - b.column;
