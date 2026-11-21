#!/bin/sh
. "${0%/*}/lib.sh"

jq -rj '
  (.model.id // "") as $id
  | (.model.display_name // .model.id // "model") as $raw
  | ($raw | sub("\\s*\\([^)]*context\\)$"; "")) as $name
  | (($id + " " + $raw) | ascii_downcase) as $hay
  | (if   ($hay | test("opus"))   then "[38;2;187;154;247m"
     elif ($hay | test("sonnet")) then "[38;2;122;162;247m"
     elif ($hay | test("haiku"))  then "[38;2;158;206;106m"
     else "[38;2;169;177;214m" end) as $c
  | $c + "Model: " + $name + "[0m"
' 2>/dev/null
