#!/bin/sh
# Pet động cho tmux status bar — đổi pet bằng prefix + e (lưu vào @tmux_pet).
# Danh sách: nyan | neko | zoo | cat | bear
#   nyan : mèo cầu vồng (script nyan-anim.sh sẵn có)
#   neko : mèo EMOJI đổi biểu cảm   (chi tiết, nhiều màu)
#   zoo  : "sở thú" diễu hành — mỗi giây một con thú emoji
#   cat  : kaomoji mèo, khung CỐ ĐỊNH, chỉ đổi mắt -> không giật
#   bear : kaomoji gấu, tương tự
# Emoji & kaomoji lấy từ fallback có sẵn của macOS (không cần cài font).
DIR="$HOME/.config/tmux"
PETS="nyan neko zoo cat bear"

get_pet() {
  p="$(tmux show-option -gqv @tmux_pet 2>/dev/null)"
  [ -n "$p" ] && printf '%s' "$p" || printf 'neko'
}

# prefix+e -> xoay sang pet kế tiếp (quay vòng)
if [ "$1" = "next" ]; then
  cur="$(get_pet)"; nx=""; found=0
  for p in $PETS; do
    [ "$found" = 1 ] && { nx="$p"; break; }
    [ "$p" = "$cur" ] && found=1
  done
  [ -z "$nx" ] && nx="${PETS%% *}"
  tmux set-option -g @tmux_pet "$nx"
  tmux display-message "pet: $nx"
  exit 0
fi

pet="$(get_pet)"
now="$(date +%s)"

case "$pet" in
  nyan)
    exec "$DIR/nyan-anim.sh"
    ;;

  neko)   # mèo emoji đổi biểu cảm (thêm 1 khoảng trắng cho chắc bề rộng)
    case $(( now % 6 )) in
      0) e='🐱' ;;   # bình thường
      1) e='😺' ;;   # cười
      2) e='😸' ;;   # nhe răng
      3) e='😻' ;;   # mê (mắt tim)
      4) e='😹' ;;   # cười chảy nước mắt
      5) e='😼' ;;   # nhếch mép
    esac
    printf '%s ' "$e"
    ;;

  zoo)    # diễu hành: mỗi giây một con
    case $(( now % 8 )) in
      0) e='🐱' ;;
      1) e='🦊' ;;
      2) e='🐻' ;;
      3) e='🐰' ;;
      4) e='🐼' ;;
      5) e='🐸' ;;
      6) e='🐧' ;;
      7) e='🐶' ;;
    esac
    printf '%s ' "$e"
    ;;

  cat)    # kaomoji mèo: khung (=X･ω･X=) cố định, chỉ X đổi -> không giật
    case $(( now % 4 )) in
      0) x='^' ;;   # mở mắt
      1) x='-' ;;   # chớp
      2) x='o' ;;   # tròn mắt
      3) x='˘' ;;   # lim dim
    esac
    printf '#[fg=#fab387](=%s･ω･%s=)' "$x" "$x"
    ;;

  bear)   # kaomoji gấu: khung ʕXᴥXʔ cố định
    case $(( now % 4 )) in
      0) x='•' ;;
      1) x='-' ;;
      2) x='◕' ;;
      3) x='°' ;;
    esac
    printf '#[fg=#e0af68]ʕ%sᴥ%sʔ' "$x" "$x"
    ;;

  *)
    printf '#[fg=#fab387](=^･ω･^=)' ;;
esac
