// Ctrl+F, then a key: the herdr TUI's prefix for the app, whose keys.json binds
// single chords only. Both halves come from one list in ./default.nix:
// keys.json's "mod:prefix" section sends every key the prefix knows here as a
// command, and card.json is what ? lists. Adapted from the tmux-prefix example
// in herdrdev/herdr-layout-examples (Apache-2.0).

import { View, div } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import {
  agents,
  appHome,
  closeOverlay,
  commands,
  focused,
  hc,
  keys,
  nextCommand,
  notify,
  openOverlay,
  props,
  readTextFile,
  run,
  settings,
  shared,
  spaces,
  terminals,
  theme,
} from "herdr";

// A popup can't sit at the bottom, so the overlay is a frameless window
// covering Herdr's, which leaves the keyboard, Esc and clicks to this mod. The
// chip sits this far above its bottom edge, and ? grows it upward.
const BOTTOM = 54;
const GROW = { duration: 120, easing: "ease-out" };

// The space avatar colors, as the spaces sidebar draws them.
const MARK = {
  ansi1: "#d9649a",
  ansi2: "#3fae6a",
  ansi3: "#e3814f",
  ansi4: "#5b8def",
  ansi5: "#8b7cf6",
  ansi6: "#22a99a",
};

const GLYPHS = { tab: "⇥", "shift-tab": "⇧⇥", space: "␣" };

// Where the prefix acts: the focused space and tab, and the terminal that gets
// keys, which is the one terminal.show put in the pane's place if any.
function here() {
  const f = focused();
  const space = spaces().find((s) => s.id === f?.space);
  const address = f?.shown ?? f?.terminal ?? null;
  const terminal = terminals().find((x) => x.address === address);
  return {
    space,
    tab: space?.tabs.find((x) => x.id === f?.tab),
    address,
    terminal,
    // terminals()' cwd is where a terminal started; this one is where it is now.
    cwd: f?.cwd ?? null,
  };
}

// A command as keys.json writes it: "name", or "name:value" with the value in
// its first argument.
function runCommand(command) {
  const at = command.indexOf(":");
  if (at < 0) return run(command);
  const name = command.slice(0, at);
  const value = command.slice(at + 1);
  const arg = commands().find((c) => c.name === name)?.args[0]?.name;
  // An unknown command goes as written, for the app to name in its error.
  if (!arg) return run(command);
  run(name, { [arg]: /^\d+$/.test(value) ? Number(value) : value });
}

const prefixBinding = (keystroke) =>
  keys().find((k) => k.section === "mod:prefix" && k.keys === keystroke);

// Runs hc and shows a failure under `title`, which would otherwise go unseen.
async function hcOrNotify(title, args) {
  try {
    const result = await hc(args);
    if (result.code !== 0) throw new Error(hcError(result.stderr));
  } catch (err) {
    notify({ title, body: err.message ?? String(err), level: "error" });
  }
}

// hc writes its errors as JSON when no terminal is attached to it.
function hcError(stderr) {
  try {
    return JSON.parse(stderr).error.message;
  } catch {
    return stderr.trim();
  }
}

function openPluck(mode) {
  openOverlay({ mod: "pluck", props: { mode }, kind: "window", frame: "none" });
}

// The agents that came to need you, blocked or finished while you weren't
// looking.
const waiting = () => agents().filter((a) => a.status === "blocked" || a.status === "done");

// This mod's own commands, run once the prefix has closed.
const ACTIONS = {
  // The TUI's open_notification_target: the agent that came to need you last.
  attention() {
    const [latest] = waiting().sort((a, b) => b.seq - a.seq);
    if (latest) run("agent.focus", { terminal: latest.address });
  },

  "open-url"() {
    openPluck("open");
  },

  pluck() {
    openPluck("copy");
  },

  // Ctrl+F twice: a literal one for the program.
  "send-prefix"(cx) {
    const { address } = here();
    if (!address) return;
    // A task of its own, since closing the prefix cancels the view's.
    cx.spawn(() => hcOrNotify("Couldn't send Ctrl+F", ["keys", address, "ctrl+f"]), {
      owner: null,
    });
  },

  // The same dialog as the + menu's "New worktree…".
  worktree() {
    const { space, cwd } = here();
    if (!space) return;
    openOverlay({
      mod: "worktree",
      props: { space: space.id, folder: cwd, action: "new" },
      kind: "dialog",
      width: 460,
      height: 280,
    });
  },
};

// The app takes Tab and Shift+Tab to move the keyboard between tab stops,
// before keys.json or on_key_down sees them. GPUI tries bindings under the
// mod's own key context first, as win98's menu relies on for Escape, so the mod
// binds both keys there as actions.
const KEY_CONTEXT = "Prefix";
const TAB_ACTIONS = { tab: "prefix_tab", "shift-tab": "prefix_shift_tab" };

let tabKeysBound = false;

function bindTabKeysOnce(cx) {
  if (tabKeysBound) return;
  cx.bind_keys(
    Object.entries(TAB_ACTIONS).map(([keystroke, action]) => ({
      keystroke,
      action,
      context: KEY_CONTEXT,
    })),
  );
  tabKeysBound = true;
}

export default class Prefix extends View {
  init(_props, cx) {
    bindTabKeysOnce(cx);
    // Where the keyboard was, to give it back.
    this.origin = focused();
    this.handle = cx.focus_handle();
    this.handle.focus();
    this.expanded = false;
    // Each layer's size, borders included, once drawn.
    this.sizes = { chip: null, list: null };
    // Read rather than imported: the app imports only modules inside this
    // folder, and card.json links into the Nix store.
    this.groups = [];
    cx.spawn(async (cx) => {
      this.groups = JSON.parse((await readTextFile(`${appHome()}/mods/prefix/card.json`)) ?? "[]");
      cx.notify();
    });
    cx.spawn(async (cx) => {
      for (;;) this.command(await nextCommand(), cx);
    });
  }

  // Closing a window leaves the keyboard nowhere, so it goes back to the pane
  // or terminal it came from, before a command moves it on.
  dismiss() {
    closeOverlay(props().overlay);
    const { pane, terminal } = this.origin ?? {};
    if (pane) run("pane.focus", { pane });
    else if (terminal) run("pane.focus", { terminal });
  }

  // A key keys.json binds: "run:<command>", or one of this mod's own.
  command(command, cx) {
    this.dismiss();
    if (command.startsWith("run:")) runCommand(command.slice("run:".length));
    else ACTIONS[command]?.(cx);
  }

  runBinding(keystroke) {
    const action = prefixBinding(keystroke)?.action;
    if (action) run(action);
    else this.dismiss();
  }

  // Any other key: ? shows or hides the list, and the rest, Esc included,
  // close the prefix.
  key(e, cx) {
    if (prefixBinding(e.keystroke)) return;
    if (e.key_char !== "?") return this.dismiss();
    // A held ? repeats, which would flicker.
    if (e.is_held) return;
    this.expanded = !this.expanded;
    cx.notify();
  }

  render() {
    const look = { t: theme(), mono: settings().font_family ?? "JetBrains Mono" };
    return (
      v_flex()
        .id("prefix")
        .size_full()
        .items_center()
        .justify_end()
        .pb(BOTTOM)
        .key_context(KEY_CONTEXT)
        .on_action(TAB_ACTIONS.tab, () => this.runBinding("tab"))
        .on_action(TAB_ACTIONS["shift-tab"], () => this.runBinding("shift-tab"))
        .track_focus(this.handle)
        .on_key_down((e, cx) => this.key(e, cx))
        // A press the mod lets through would drag the window.
        .on_mouse_down("left", (_e, cx) => {
          cx.stop_propagation();
          this.dismiss();
        })
        .child(this.card(look))
    );
  }

  // The card: a chip that ? grows into the list. Both layers are drawn inside
  // it all along, each at its own size, and ? swaps its size and their opacity.
  card(look) {
    const { t } = look;
    const size = (this.expanded && this.sizes.list) || this.sizes.chip;
    return div()
      .id("card")
      .relative()
      .flex_none()
      .overflow_hidden()
      .bg(t.popover)
      .border(1)
      .border_color(this.expanded ? t.border : t.accent)
      .rounded(this.expanded ? 10 : 14)
      .shadow_lg()
      .when(Boolean(size), (el) => el.w(size.width).h(size.height))
      .when(!size, (el) => el.opacity(0))
      .transition("width", GROW)
      .transition("height", GROW)
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
      .child(this.layer("chip", !this.expanded, { duration: 60 }, chip(look)))
      .child(this.layer("list", this.expanded, { duration: 80, delay: 40 }, this.list(look)));
  }

  // One of the card's layers, at its top left, measured to size the card.
  layer(name, shown, fade, content) {
    const zoom = settings().zoom ?? 1;
    return (
      div()
        .id(`${name}-layer`)
        .absolute()
        .top(0)
        .left(0)
        .opacity(shown ? 1 : 0)
        .transition("opacity", fade)
        // on_size_change reports zoomed pixels; sizes are set in unzoomed ones.
        .on_size_change((size, cx) => {
          this.sizes[name] = { width: size.width / zoom + 2, height: size.height / zoom + 2 };
          cx.notify();
        })
        .child(content)
    );
  }

  // Where the keys will land, then every key.
  list(look) {
    const at = here();
    const count = waiting().length;
    // tab.next and tab.prev skip settled tabs.
    const oneTab = (at.space?.tabs.filter((x) => !x.settled).length ?? 0) < 2;
    // A row with nothing to act on now is dimmed; Needs you counts its agents.
    const state = (command) => ({
      dim:
        command === "attention"
          ? count === 0
          : oneTab && (command === "run:tab.next" || command === "run:tab.prev"),
      badge: command === "attention" && count > 0 ? count : null,
    });
    return v_flex()
      .pt(10)
      .px(16)
      .pb(12)
      .whitespace_nowrap()
      .child(header(look, at))
      .child(div().h(1).mt(8).mb(10).bg(look.t.raised))
      .child(
        h_flex()
          .gap(28)
          .items_start()
          .children(this.groups.map((group) => column(look, group, state))),
      );
  }
}

// The waiting prefix: a state rather than a key to press, so no keycap.
function chip({ t, mono }) {
  return h_flex()
    .h(26)
    .px(14)
    .items_center()
    .font_family(mono)
    .text_size(11)
    .font_weight(700)
    .text_color(t.accent)
    .child("⌃F");
}

// Where the keys will land, and the ways out: Esc, and Ctrl+F where there is a
// terminal to send it to.
function header(look, { space, tab, address, terminal }) {
  const { t } = look;
  const program = terminal?.program;
  const arrow = () => div().text_color(t.dim).child("›");
  const hint = (cap, text) =>
    h_flex()
      .gap(5)
      .items_center()
      .child(keycap(look, [cap], true))
      .child(text);
  return h_flex()
    .h(24)
    .gap(8)
    .items_center()
    .text_size(11)
    .when(Boolean(space), (el) =>
      el.child(
        h_flex()
          .gap(6)
          .items_center()
          .text_color(t.foreground)
          .child(avatar(look, space))
          .child(space.name)
          .when(Boolean(tab), (el) => el.child(arrow()).child(tab.name))
          .when(Boolean(program), (el) =>
            el
              .child(arrow())
              .child(
                div()
                  .size(7)
                  .rounded(4)
                  .bg(t[terminal?.status] ?? t.dim),
              )
              .child(program.name),
          ),
      ),
    )
    .child(div().flex_1().min_w(24))
    .child(
      h_flex()
        .gap(14)
        .items_center()
        .text_color(t.dim)
        .child(hint("esc", "close"))
        .when(Boolean(address), (el) =>
          el.child(hint("⌃F", program ? `send to ${program.name}` : "send")),
        ),
    );
}

// The space's avatar, filled with the spaces sidebar's colors.
function avatar({ t }, space) {
  const color = shared("space.colors")?.[space.id] ?? "ansi6";
  return div()
    .size(14)
    .flex()
    .items_center()
    .justify_center()
    .rounded(4)
    .bg(color.startsWith("#") ? color : (MARK[color] ?? t[color]))
    .text_size(8.5)
    .font_semibold()
    .text_color(t.popover)
    .child([...space.name][0]?.toUpperCase() ?? "?");
}

// A group's column: its keys, then what they do, row by row.
function column(look, { name, rows }, state) {
  const { t } = look;
  const cells = rows.map((row) => {
    const { dim, badge } = state(row.command);
    const cell = () =>
      h_flex()
        .h(26)
        .items_center()
        .opacity(dim ? 0.38 : 1);
    return [
      cell().child(keycap(look, caps(row.keys))),
      cell()
        .gap(6)
        .text_size(11)
        .text_color(t.muted)
        .child(row.label)
        .when(badge !== null, (el) => el.child(counter(look, badge))),
    ];
  });
  return v_flex()
    .flex_none()
    .child(div().pb(6).text_size(9.5).font_semibold().text_color(t.dim).child(name.toUpperCase()))
    .child(
      h_flex()
        .gap(8)
        .child(v_flex().children(cells.map(([cap]) => cap)))
        .child(v_flex().children(cells.map(([, label]) => label))),
    );
}

// A count of agents, in the blocked color over a 22% wash of it.
function counter({ t, mono }, count) {
  return div()
    .px(5)
    .rounded(7)
    .bg(`${t.blocked.slice(0, 7)}38`)
    .font_family(mono)
    .text_size(9.5)
    .font_weight(700)
    .line_height("14px")
    .text_color(t.blocked)
    .child(String(count));
}

// One keycap for one or more keys, divided between them so a column of rows
// like h j k l stays narrow.
function keycap({ t, mono }, labels, small = false) {
  const divided = labels.length > 1;
  return h_flex()
    .h(small ? 16 : 20)
    .min_w(small ? 0 : 20)
    .rounded(4)
    .bg(t.background)
    .border(1)
    .border_b(small ? 1 : 2)
    .border_color(t.border)
    .font_family(mono)
    .text_size(small ? 9.5 : 10.5)
    .font_weight(500)
    .text_color(t.foreground)
    .children(
      labels.map((label, i) =>
        div()
          .flex_1()
          .h_full()
          .flex()
          .items_center()
          .justify_center()
          .px(divided ? 3 : small ? 4 : 5)
          .when(divided, (el) => el.min_w(15))
          .when(i > 0, (el) => el.border_l(1).border_color(t.border))
          .child(label),
      ),
    );
}

// What keycaps say for a row's keys: a run of digits as a range, a shifted
// letter as a capital.
function caps(names) {
  if (names.length > 2 && names.every((k) => /^\d$/.test(k)))
    return [`${names[0]}–${names.at(-1)}`];
  return names.map((k) => GLYPHS[k] ?? k.replace(/^shift-(.)$/, (_, c) => c.toUpperCase()));
}
