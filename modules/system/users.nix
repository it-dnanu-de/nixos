# modules/system/users.nix
# Human users — single-user system per OpenCode.md §1.
{ ... }:
{
  users.users = {
    root = {
      hashedPassword = "$y$j9T$cU7EmdsdvKvRUGw0aVg8L0$2oHDcpmagNsE36Gk0JNP6gPKaDlXHw37Z7MydW/TnB1";
    };
    nixos = {
      isNormalUser = true;
      hashedPassword = "$y$j9T$EK7M3B7ghhmEMMFP1p0v3/$QW85ZTYJgX.lCqFQMY0yDcHfjlhb4tPqoPsexc6bzE2";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [ settings.sshPubKey ];
    };
  };

  # intentional — human ruling (Memory.md)
  services.openssh.settings.PermitRootLogin = "yes";
}
