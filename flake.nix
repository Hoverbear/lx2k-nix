{
  description = "NixOS for HoneyComb / ClearFog LX2K";

  inputs = {
    nixos.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixos }: {
    packages = let 
      pkgsForSystem = pkgs: rec {
        
        linux_lx2k = pkgs.callPackage ./pkgs/linux {};
        linuxPackages_lx2k = pkgs.linuxPackagesFor linux_lx2k;
        
        lx2k = pkgs.lib.makeScope pkgs.newScope (self: with self; {
          rcw = self.callPackage ./pkgs/rcw { };
          atf = self.callPackage ./pkgs/atf { };
          ddr-phy-bin = self.callPackage ./pkgs/ddr-phy-bin { };
          uefi = self.callPackage ./pkgs/uefi { };
          qoriq-mc-bin = self.callPackage ./pkgs/qoriq-mc-bin { };
          mc-utils = self.callPackage ./pkgs/mc-utils { };
          edk2 = callPackage ./pkgs/edk2 { };
          tianocore = callPackage ./pkgs/tianocore { };
        });

        lx2k-2400 = lx2k.overrideScope' (_: _: { ddrSpeed = 2400; });
        lx2k-2600 = lx2k.overrideScope' (_: _: { ddrSpeed = 2600; });
        lx2k-2900 = lx2k.overrideScope' (_: _: { ddrSpeed = 2900; });
        lx2k-3200 = lx2k.overrideScope' (_: _: { ddrSpeed = 3200; });
      };
    in {
      "x86_64-linux" = pkgsForSystem (import nixos {
        system = "x86_64-linux";
        crossSystem = "aarch64-linux";
      });
      "aarch64-linux" = pkgsForSystem (import nixos {
        system = "aarch64-linux";
      }) // {
        # TODO: Currently the `loopback.cfg` refuses to cross compile.
        isoImage = self.nixosConfigurations.isoImage.config.system.build.isoImage;
      };
    };

    nixosConfigurations = {
      isoImage = nixos.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          { imports = [ "${nixos}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix" ]; }
          self.nixosModules.lx2k
        ];
      };
    };

    nixosModules = {
      lx2k = {
        # use vendor kernel
        boot.kernelPackages = self.packages."aarch64-linux".linuxPackages_lx2k;
        boot.kernelParams = [
          # Serial port
          "console=ttyAMA0,115200"
          "earlycon=pl011,mmio32,0x21c0000"
          "pci=pcie_bus_perf"
          "arm-smmu.disable_bypass=0" # TODO: remove once firmware supports it
        ];
        boot.kernelModules = [
          "amc6821" # via sensors-detect
        ];
      };
    };
  };
}
