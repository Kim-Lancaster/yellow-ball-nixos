{
  description = "Yellow Ball Project NixOS config and dev shells";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "aarch64-linux";
      pkgs   = import nixpkgs { inherit system; };
    in rec {
      nixosConfigurations = {
        ybp-pi = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./nixos/configuration.nix
            ./nixos/hardware-configuration.nix
            # If you ever need inline overrides, add a module like:
            # ({ config, pkgs, ... }: { /* overrides */ })
          ];
        };

        dev-vm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
              ./nixos/dev-vm.nix

              # --- 1 QEMU VM support (correct path) ---
              (import "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix")

              # --- 2 Classic eth0 naming ---
              ({ config, pkgs, ... }: {
                networking.usePredictableInterfaceNames = false;
                boot.kernelParams = [ "net.ifnames=0" "biosdevname=0" ];
              })

              # --- 3 Static IP on your bridge ---
              ({ config, pkgs, ... }: {
                networking.interfaces.eth0.ipv4.addresses = [
                  { address = "192.168.4.3"; prefixLength = 24; }
                ];
                networking.defaultGateway = "192.168.4.1";
                networking.nameservers = [ "8.8.8.8" "1.1.1.1" ];
              })

              # --- 4 Size the VM (options provided by qemu-vm.nix) ---
              ({ config, pkgs, ... }: {
                virtualisation.cores      = 8;        # vCPUs
                virtualisation.memorySize = 8192;     # MiB
                virtualisation.diskSize   = 20 * 1024;# MiB (20 GiB)
              })
            ];
        };
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ pkgs.git pkgs.gcc pkgs.cmake ];
        shellHook = ''
          echo "Welcome to the dev shell!"
        '';
      };
    };
}