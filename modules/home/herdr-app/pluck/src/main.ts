import { draw, ENTER, LEAVE } from "./draw";
import { layOut, type Screen } from "./layout";
import { type Phase, press } from "./phase";
import { findTokens, findUrls, type Token } from "./tokens";

const PICKED_MS = 150;
const NOTE_MS = 1200;
// A picker the window never showed, or whose pane went away, gets no keys.
const IDLE_MS = 60_000;

const OPENER = process.platform === "darwin" ? "/usr/bin/open" : "xdg-open";

interface Mode {
  find: (lines: readonly string[]) => Token[];
  nothing: string;
  take: (text: string) => unknown;
}

const MODES: Record<string, Mode> = {
  copy: {
    find: findTokens,
    nothing: "nothing to copy on screen",
    take: (text) => process.stdout.write(`\x1b]52;c;${Buffer.from(text).toString("base64")}\x07`),
  },
  open: {
    find: findUrls,
    nothing: "no URL on screen",
    take: (text) => Bun.spawn([OPENER, text], { stdio: ["ignore", "ignore", "ignore"] }).exited,
  },
};

class Picker {
  private readonly tokens: Token[];
  private screen!: Screen;
  private phase: Phase = { kind: "typing", typed: "" };
  private note?: ReturnType<typeof setTimeout>;

  constructor(
    private readonly mode: Mode,
    private readonly lines: string[],
  ) {
    this.tokens = mode.find(lines);
    this.fit();
  }

  start(): void {
    process.stdout.write(ENTER);
    const idle = setTimeout(() => this.quit(), IDLE_MS);
    // Shown in a pane, the picker takes the pane's size from herdr-core's.
    process.stdout.on("resize", () => {
      this.fit();
      // From when it shows, not from its start in the hidden terminal.
      clearTimeout(this.note);
      if (this.phase.kind === "empty") this.note = setTimeout(() => this.quit(), NOTE_MS);
      this.render();
    });
    process.stdin.setRawMode(true);
    process.stdin.on("data", (data: Buffer) => {
      idle.refresh();
      this.input(data.toString("utf8"));
    });
    this.render();
  }

  // The size decides which tokens are on screen, and so which get hints. Typing
  // starts over, and with none on screen there is nothing to pick.
  private fit(): void {
    this.screen = layOut(this.lines, this.tokens, process.stdout.columns, process.stdout.rows);
    if (this.phase.kind === "picked") return;
    this.phase =
      this.screen.hints.size > 0
        ? { kind: "typing", typed: "" }
        : { kind: "empty", note: this.mode.nothing };
  }

  private render(): void {
    process.stdout.write(
      draw({ screen: this.screen, phase: this.phase, height: process.stdout.rows }),
    );
  }

  private input(keys: string): void {
    const next = press(this.screen.hints, this.phase, keys);
    if (next === "quit") return this.quit();
    this.phase = next;
    if (next.kind === "picked") return void this.pick(next.text);
    this.render();
  }

  private async pick(text: string): Promise<void> {
    process.stdin.removeAllListeners("data");
    this.render();
    await this.mode.take(text);
    await Bun.sleep(PICKED_MS);
    this.quit();
  }

  private quit(): void {
    process.stdin.removeAllListeners("data");
    process.stdout.write(LEAVE, () => process.exit(0));
  }
}

const [name, screen] = process.argv.slice(2);
if (
  name === undefined ||
  !Object.hasOwn(MODES, name) ||
  screen === undefined ||
  !process.stdin.isTTY
) {
  console.error("usage: pluck copy|open <screen>, on a terminal");
  process.exit(64);
}
new Picker(MODES[name], screen.split("\n")).start();
