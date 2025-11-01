{
  description = "NixOS VPS Disk Image Builder";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    impermanence.url = "github:nix-community/impermanence";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;

    # 支持多架构的函数 / Function to support multiple architectures
    mkSystem = system: lib.nixosSystem {
      inherit system;
      modules = [
        inputs.impermanence.nixosModules.impermanence
        inputs.disko.nixosModules.disko
        ./configuration.nix
        # 使用预编译 QEMU，避免重新编译
        {
          nixpkgs.config.allowUnfree = true;
        }
      ];
    };
  in rec {
    # 支持多架构的 NixOS 配置 / Multi-architecture NixOS configurations
    nixosConfigurations = {
      bootstrap-x86_64 = mkSystem "x86_64-linux";
      bootstrap-aarch64 = mkSystem "aarch64-linux";
    };

    # 支持多架构的镜像包 / Multi-architecture image packages
    packages = {
      x86_64-linux = {
        image-x86_64 = self.nixosConfigurations.bootstrap-x86_64.config.system.build.diskoImages;
        image-aarch64 = self.nixosConfigurations.bootstrap-aarch64.config.system.build.diskoImages;
        # Alternative builds without KVM requirement
        system-x86_64 = self.nixosConfigurations.bootstrap-x86_64.config.system.build.toplevel;
        system-aarch64 = self.nixosConfigurations.bootstrap-aarch64.config.system.build.toplevel;
      };
      aarch64-linux = {
        image-x86_64 = self.nixosConfigurations.bootstrap-x86_64.config.system.build.diskoImages;
        image-aarch64 = self.nixosConfigurations.bootstrap-aarch64.config.system.build.diskoImages;
        # Alternative builds without KVM requirement
        system-x86_64 = self.nixosConfigurations.bootstrap-x86_64.config.system.build.toplevel;
        system-aarch64 = self.nixosConfigurations.bootstrap-aarch64.config.system.build.toplevel;
      };
    };
  };
}
