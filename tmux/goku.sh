#!/bin/sh
# Hiện ảnh bằng chafa — block art truecolor (chạy được trên Alacritty).
# Ảnh mặc định: ~/.config/tmux/art/goku.png
#   -> Bạn TỰ bỏ ảnh Goku (png/jpg/gif) của mình vào đó.
# Dùng:
#   goku            # hiện ảnh
#   prefix + g      # hiện trong popup nổi (tmux)
IMG="$HOME/.config/tmux/art/goku.png"

command -v chafa >/dev/null 2>&1 || { echo "Cần cài chafa:  brew install chafa"; exit 1; }

if [ ! -f "$IMG" ]; then
  printf '\n  Chưa có ảnh Goku.\n  Bỏ 1 ảnh (png/jpg/gif) vào:\n    %s\n  rồi gõ lại: goku\n\n' "$IMG"
else
  chafa "$IMG"
fi

# Khi gọi từ popup: chờ một phím để không bị đóng ngay
[ "$1" = "--wait" ] && { printf '  [Enter để đóng] '; read -r _; }
