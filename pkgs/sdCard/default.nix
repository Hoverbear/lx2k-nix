{ runCommandNoCC, parted, uefi, util-linux, isoImage }:

runCommandNoCC "lx2k-sdcard.img" { } ''
  set -x
  truncate -s 2160066560 $out
  dd of=$out if=${isoImage.isoImage}/iso/*.iso
  dd of=$out if=${uefi}
''
