#!/bin/bash
# Widget tmux: hiện % CÒN LẠI của cửa sổ rate-limit 5h của Claude Code.
# Đọc cache do claude-usage-statusline.sh ghi. Tô màu theo mức còn lại và
# làm mờ + thêm dấu ~ nếu dữ liệu cũ (không có session Claude nào đang chạy).
cache="$HOME/.cache/claude-usage"
bg="#1e1e2e"

[ -f "$cache" ] || exit 0
IFS=$'\t' read -r five seven reset ts < "$cache"
[ -z "$five" ] && exit 0

now="$(date +%s)"
age=$(( now - ${ts:-0} ))
rem5=$(( 100 - five ))

# màu theo % còn lại
if   [ "$rem5" -le 15 ]; then col="#f38ba8"   # đỏ: sắp hết
elif [ "$rem5" -le 40 ]; then col="#f9e2af"   # vàng
else                          col="#a6e3a1"   # xanh: thoải mái
fi

# giờ reset
rt=""
[ -n "$reset" ] && rt=" ↻$(date -r "$reset" +%H:%M 2>/dev/null)"

label="5h ${rem5}%${rt}"

# dữ liệu cũ hơn 15' -> coi như stale (Claude Code không chạy gần đây)
if [ "$age" -gt 900 ]; then
  printf '#[fg=#6c7086,bg=%s] ~%s ' "$bg" "$label"
else
  printf '#[fg=%s,bg=%s] %s ' "$col" "$bg" "$label"
fi
