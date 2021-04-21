{ stdenv
, lib
, buildPackages
, fetchFromGitHub
, tianocore
, rcw
, openssl
, bootMode ? "sd"
, bl33 ? "${tianocore}/FV/LX2160ACEX7_EFI.fd"
}:

assert lib.elem bootMode [ "sd" "spi" ];
let
  atfBoot = if bootMode == "sd" then "sd" else "flexspi_nor";
  isCross = stdenv.buildPlatform != stdenv.hostPlatform;
in
stdenv.mkDerivation rec {
  pname = "atf";
  version = "unstable-2020-08-31";

  src = fetchFromGitHub {
    owner = "SolidRun";
    repo = "arm-trusted-firmware";
    rev = "ed25defc9847c1159574e5efa84b4ddf208e3f74";
    sha256 = "0j4gw05ppqkz2l98d6fqpq2agjgl93q7b6m6zs1nwn0gb6s33rwc";
  };

  enableParallelBuilding = true;

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  nativeBuildInputs = [ openssl ];

  makeFlags = [
    "PLAT=lx2160acex7"
    "BL33=${bl33}"
    "RCW=${rcw}/lx2160acex7/rcws/rcw_lx2160acex7.bin"
    "TRUSTED_BOARD_BOOT=0"
    "GENERATE_COT=0"
    "BOOT_MODE=${atfBoot}"
    "SECURE_BOOT=false"
  ] ++ lib.optional isCross "CROSS_COMPILE=${stdenv.cc.targetPrefix}" ++ [
    "all"
    "fip"
    "pbl"
  ];

  hardeningDisable = [ "all" ];

  installPhase = ''
    mkdir -p $out/lx2160acex7
    cp -v --target-directory $out/lx2160acex7 \
      build/lx2160acex7/release/*.bin \
      build/lx2160acex7/release/*.pbl

    mkdir -p $out/bin
    cp -v tools/fiptool/fiptool $out/bin
  '';

  passthru = {
    inherit atfBoot;
  };
}
