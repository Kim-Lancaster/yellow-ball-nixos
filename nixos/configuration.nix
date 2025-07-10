{ config, pkgs, lib, ... }:

{
  # hardware-generated fileSystems, partition, firmware, etc.
  imports = [ ./hardware-configuration.nix ];

  system.stateVersion = "25.05";

  # --- Bootloader (Pi needs extlinux, not GRUB) ---
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # --- identity ---
  networking.hostName = "ybp-pi";
  
  # --- Time ---
  time.timeZone = "America/Los_Angeles";
  
  # ---Networking---
  networking.useDHCP = false;
  networking.enableIPv6 = false;
  networking.interfaces.end0 = {
    useDHCP = false;                         # required, or dhcpcd will start
    ipv4.addresses = [{
      address      = "192.168.4.2";
      prefixLength = 24;
    }];
  };
  networking.defaultGateway = "192.168.4.1";  # my router on the same /24
  networking.nameservers   = [ "1.1.1.1" "8.8.8.8" ];
  
  # --- SSH: key-only root login ---
  services.openssh = {
    enable                  = true;             # start sshd
    settings = {
      PasswordAuthentication  = false;            # disable password auth
      PermitRootLogin         = "without-password"; # allow root but ONLY with keys
   };
   #openFirewall = true; 
  };

  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      ./secrets/root-ssh-keys.pub
    ];
  };
}
