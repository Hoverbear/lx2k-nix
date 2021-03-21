{ runCommandNoCC, parted, uefi, util-linux, isoImage }:

runCommandNoCC "lx2k-sdcard.img" { } ''
  set -x
  truncate -s 2160066560 $out
  dd of=$out if=${uefi}
  dd iflag=skip_bytes of=$out if=${isoImage.isoImage}/iso/*.iso skip=8388608
''
