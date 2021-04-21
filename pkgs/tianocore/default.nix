{ fetchFromGitHub, edk2, utillinux, nasm, iasl, dtc }:
let
  edk2-platforms = fetchFromGitHub {
    owner = "SolidRun";
    repo = "edk2-platforms";
    rev = "696d322818631d25c2295173258b0ededd847607";
    sha256 = "0s1k9v9909jvfx76fg6y00ylqmzcs65jaiklsgih64z0jxdfzagn";
  };
  edk2-non-osi = fetchFromGitHub {
    owner = "SolidRun";
    repo = "edk2-non-osi";
    rev = "93839d3e676bc969dce82096f8d4c7076dc24c7c";
    sha256 = "1q6c2yzsjl4lwq1g1v08410k3yyrsk5lgv1ljk19yhycmk824xxz";
  };
in
edk2.mkDerivation "${edk2-platforms}/Platform/SolidRun/LX2160aCex7/LX2160aCex7.dsc" {
  name = "tianocore-honeycomb-lx2k";
  nativeBuildInputs = [ utillinux nasm iasl dtc ];
  hardeningDisable = [ "format" "stackprotector" "pic" "fortify" ];
  preBuild = ''
    export PACKAGES_PATH=${edk2}:${edk2-platforms}:${edk2-non-osi}
  '';
}
