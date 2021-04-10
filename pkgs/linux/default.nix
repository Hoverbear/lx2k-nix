{ pkgs, ... }:

pkgs.buildLinux {
  src = pkgs.fetchFromGitHub {
    owner = "SolidRun";
    repo = "linux-stable";
    rev = "bc1160fd43de6bc9a09e25c027a057e1376e5b9a";
    sha256 = "1cq36vpsd68g144gn7f3jjkl2bwibqv7nrrrjgvkdj1lfijcwm14";
  };
  version = "5.10.5";
  kernelPatches = [ ];
  structuredExtraConfig = with pkgs.lib.kernel; {
    CGROUP_FREEZER = yes;
  };
}
