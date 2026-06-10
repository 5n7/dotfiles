# Darwin settings shared by every host profile.
{
  lib,
  host,
  ...
}:
{
  networking = lib.mkIf (host.hostName != null) {
    hostName = host.hostName;
    localHostName = host.hostName;
  };

  users.users.${host.username} = {
    home = "/Users/${host.username}";
  };

  system.primaryUser = host.username;
}
