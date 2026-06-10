#!/bin/sh
# Context usage progress bar with threshold colors for ccstatusline (Tokyo Night).
#   green < 50%, yellow 50-79%, red >= 80%; empty track in a muted blue-gray.
# Mirrors ccstatusline's own context-length computation (input + cache tokens).
# All rendering is done inside jq so multibyte block glyphs stay intact.

. "${0%/*}/lib.sh"

jq -rj '
  def rep($s; $n): [range(0; $n) | $s] | join("");
  (.context_window // {}) as $cw
  | ($cw.context_window_size // 0) as $total
  | (
      if ($cw.current_usage | type) == "number" then $cw.current_usage
      elif ($cw.current_usage | type) == "object" then
        (($cw.current_usage.input_tokens // 0)
         + ($cw.current_usage.cache_creation_input_tokens // 0)
         + ($cw.current_usage.cache_read_input_tokens // 0))
      else 0 end
    ) as $used
  | if ($total | not) or $total <= 0 then ""
    else
      ([$used * 100 / $total, 100] | min | floor) as $p
      | (($p * 10 / 100) | floor) as $f
      | (10 - $f) as $e
      | (if $p >= 80 then "[38;2;247;118;142m"
         elif $p >= 50 then "[38;2;224;175;104m"
         else "[38;2;158;206;106m" end) as $c
      | "[38;2;65;72;104m" as $track
      | $c + "[" + rep("█"; $f) + $track + rep("░"; $e) + $c + "] "
        + (($used / 1000) | floor | tostring) + "k/"
        + (($total / 1000) | floor | tostring) + "k "
        + ($p | tostring) + "%[0m"
    end
' 2>/dev/null
