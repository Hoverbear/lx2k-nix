self: super: {
  linux_lx2k = self.callPackage ./pkgs/linux {};
  linuxPackages_lx2k = super.linuxPackagesFor self.linux_lx2k;
  lx2k = self.lib.makeScope self.newScope (self: with self; {
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

  });

  lx2k-2400 = self.lx2k;
  lx2k-2600 = self.lx2k.overrideScope' (_: _: { ddrSpeed = 2600; });
  lx2k-2900 = self.lx2k.overrideScope' (_: _: { ddrSpeed = 2900; });
  lx2k-3200 = self.lx2k.overrideScope' (_: _: { ddrSpeed = 3200; });
}
