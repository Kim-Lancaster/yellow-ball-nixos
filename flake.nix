{
    description = "Yellow Ball Project NixOS config and dev shells"; 
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    };
    outputs = {self, nixpkgs, ...}:
        let
            system = "aarch64-linux";
            pkgs = import nixpkgs { inherit system };
        in rec {
            nixosConfigurations ={
                ybp-pi = pkgs.nixosSystem {
                    system = "aarch64-linux";
                    modules = [
                        ./nixos/configuration.nix
                        ./nixos/hardware-configuration.nix
                    ];
                    configuration = {config, pkgs, ...}: {};
                };
                dev-vm = pkgs.nixosSystem {
                    system = "x86_64-linux";
                    modules = [
                      ./nixos/configuration.nix
                    ];
                    configuration = {config, pkgs, ...}: {};
                };
            };
            devShells.${system}.default = pkgs.mkShell {
                buildInputs = [pkgs.git pkgs.gcc pkgs.cmake];
                shellHook = ''
                    echo "Welcome to the dev shell!"
                '';
            };
        };
}