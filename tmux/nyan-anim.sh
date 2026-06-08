#!/bin/sh
# Mèo cầu vồng cho tmux status bar: vệt cầu vồng chạy + mặt mèo (=^.^=) có tai.
# Màu cầu vồng xoay theo giây -> hiệu ứng "bay" khi status-interval = 1.
# Mặt mèo rộng CỐ ĐỊNH (7 ký tự ASCII + 1 ô nốt nhạc) nên không giật layout.

f=$(date +%s)

color() {
  case "$1" in
    0) printf '#ff5555' ;;  # đỏ
    1) printf '#ffaa00' ;;  # cam
    2) printf '#ffff55' ;;  # vàng
    3) printf '#55ff55' ;;  # lục
    4) printf '#55aaff' ;;  # lam
    5) printf '#cba6f7' ;;  # tím
  esac
}

# Vệt cầu vồng 8 block, màu xoay theo frame
out=''
n=0
while [ "$n" -lt 8 ]; do
  idx=$(( (n + f) % 6 ))
  out="${out}#[fg=$(color "$idx")]█"
  n=$(( n + 1 ))
done

# Biểu cảm mặt mèo: đa số (=^.^=), thỉnh thoảng ngáp / le lưỡi / chớp mắt / nya♪
note=' '
case "$(( f % 14 ))" in
  8|9)   face='(=^O^=)' ;;            # ngáp
  10|11) face='(=^p^=)' ;;            # le lưỡi / liếm tay
  12|13) face='(=^.^=)'; note='♪' ;;  # nya♪
  *)
    if [ $(( f % 5 )) -eq 0 ]; then
      face='(=^-^=)'                  # chớp mắt
    else
      face='(=^.^=)'                  # bình thường
    fi
    ;;
esac

printf '%s#[fg=#f5c2e7,bold]%s%s' "$out" "$face" "$note"
