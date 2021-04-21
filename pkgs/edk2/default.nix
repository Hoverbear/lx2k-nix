{ stdenv, lib, buildPackages, fetchFromGitHub, libuuid, python3, bc }:
let
  edk2 = stdenv.mkDerivation {
    pname = "edk2-solidrun";
    version = "unstable-2020-08-31";
    src = fetchFromGitHub {
      owner = "SolidRun";
      repo = "edk2";
      fetchSubmodules = true;
      rev = "ef3bbb20003ee0c300468c642499b3338b8ebf32";
      sha256 = "1af847y3hld8ky09m47xl17m0a4ksqkc4swpv44ycwls512z2fjw";
    };

    depsBuildBuild = [ buildPackages.stdenv.cc ];
    nativeBuildInputs = [ libuuid python3 ];

    postPatch = "patchShebangs BaseTools/BinWrappers";

    makeFlags = [ "-C BaseTools" ]
      ++ lib.optional (stdenv.cc.isClang) [ "BUILD_CC=clang BUILD_CXX=clang++ BUILD_AS=clang" ];

    NIX_CFLAGS_COMPILE = "-Wno-return-type" + lib.optionalString (stdenv.cc.isGNU) " -Wno-error=stringop-truncation";

    hardeningDisable = [ "format" "fortify" ];

    installPhase = ''
      mkdir -vp $out
      mv -v BaseTools $out
      mv -v edksetup.sh $out
    '';

    enableParallelBuilding = true;

    passthru = {
      mkDerivation = projectDscPath: attrs: stdenv.mkDerivation ({
        inherit (edk2) src;

        nativeBuildInputs = [ bc python3 ] ++ attrs.nativeBuildInputs or [ ];

        prePatch = ''
          rm -rf BaseTools
          ln -sv ${edk2}/BaseTools BaseTools
        '';

        configurePhase = let
          crossPrefix =
            if stdenv.hostPlatform != stdenv.buildPlatform then
              stdenv.cc.targetPrefix
            else
              "";
        in ''
          runHook preConfigure
          export WORKSPACE="$PWD"
          export GCC5_AARCH64_PREFIX=${crossPrefix} DTCPP_PREFIX=${crossPrefix}
          . ${edk2}/edksetup.sh BaseTools
          runHook postConfigure
        '';

        buildPhase = ''
          runHook preBuild
          build -a AARCH64 -b ${attrs.releaseType or "RELEASE"} -t GCC5 -p ${projectDscPath} -n $NIX_BUILD_CORES
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          mv -v Build/*/* $out
          runHook postInstall
        '';
      } // removeAttrs attrs [ "nativeBuildInputs" ]);
    };
  };
in
edk2
