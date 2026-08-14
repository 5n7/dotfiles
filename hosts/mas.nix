# Homebrew mas apps grouped by host: common apps plus the active profile's own group.
{ host }:
let
  masApps = {
    common = {
      "RunCat Neo" = 6757801838;
    };
    personal = {
      Xcode = 497799835;
    };
    work = {
    };
  };
in
masApps.common // masApps.${host.profile}
