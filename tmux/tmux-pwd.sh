#!/bin/sh
# Hiển thị đường dẫn của pane hiện tại cho tmux status bar.
# Rút gọn $HOME thành ~ cho đỡ dài. Nhận đường dẫn qua tham số $1
# (tmux truyền vào bằng #{pane_current_path}).
p="$1"
case "$p" in
  "$HOME")    printf '~' ;;
  "$HOME"/*)  printf '~%s' "${p#"$HOME"}" ;;
  *)          printf '%s' "$p" ;;
esac
