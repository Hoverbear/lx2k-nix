self: super: {
  linuxPackages_lx2k = super.linuxPackagesFor self.linux_lx2k;
  linux_lx2k = self.buildLinux {
    src = super.fetchFromGitHub {
      owner = "SolidRun";
      repo = "linux-stable";
      rev = "bc1160fd43de6bc9a09e25c027a057e1376e5b9a";
      sha256 = "1cq36vpsd68g144gn7f3jjkl2bwibqv7nrrrjgvkdj1lfijcwm14";
    };
    version = "5.10.5";
    kernelPatches = [ ];
    structuredExtraConfig = with super.lib.kernel; {
      CGROUP_FREEZER = yes;
    };
  };


  lx2k = self.lib.makeScope self.newScope (self: with self; rec {
    ddrSpeed = 2400;

    rcw = self.callPackage ./pkgs/rcw { };

    atf = self.callPackage ./pkgs/atf { };

    ddr-phy-bin = self.callPackage ./pkgs/ddr-phy-bin { };

    uefi = self.callPackage ./pkgs/uefi { };

    qoriq-mc-bin = self.callPackage ./pkgs/qoriq-mc-bin { };

    mc-utils = self.callPackage ./pkgs/mc-utils { };

    edk2 = callPackage ./pkgs/edk2 { };

    tianocore = callPackage ./pkgs/tianocore { };

    isoImage = self.callPackage ./pkgs/isoImage { };

    sdCard = self.callPackage ./pkgs/sdCard {
      uefi = uefi;
      isoImage = isoImage;
    };
  });

  lx2k-2400 = self.lx2k;
  lx2k-2600 = self.lx2k.overrideScope' (_: _: { ddrSpeed = 2600; });
  lx2k-2900 = self.lx2k.overrideScope' (_: _: { ddrSpeed = 2900; });
  lx2k-3200 = self.lx2k.overrideScope' (_: _: { ddrSpeed = 3200; });
}
