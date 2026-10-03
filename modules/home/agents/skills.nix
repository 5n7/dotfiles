# Repository skills grouped by host: common skills plus the active profile's own group.
{ host, lib }:
let
  skills = {
    common = [
      "polish"
    ];
    personal = [
      "browser-qa-report"
      "create-pr"
    ];
    work = [
    ];
  };
in
lib.genAttrs (skills.common ++ skills.${host.profile}) (name: ./skills + "/${name}")
