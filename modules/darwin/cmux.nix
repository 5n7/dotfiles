# cmux terminal+browser preferences.
{ host, lib, ... }:
let
  # Hosts permitted in cmux's embedded browser. An empty whitelist would route
  # everything through cmux, so this list is only meaningful on work.
  embeddedHosts = ''
    localhost
    *.localhost
    127.0.0.1
    ::1
    0.0.0.0
    *.localtest.me
    192.168.0.1
  '';
in
{
  system.defaults.CustomUserPreferences."com.cmuxterm.app" = {
    browserExternalOpenPatterns = "";
    browserOpenTerminalLinksInCmuxBrowser = 1;
    browserThemeMode = "system";
  }
  // lib.optionalAttrs (host.profile == "work") {
    browserHostWhitelist = embeddedHosts;
    browserInsecureHTTPAllowlist = embeddedHosts;
  };
}
