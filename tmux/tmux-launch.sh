#!/bin/bash
# Mở Alacritty là vào tmux: attach session đang có, hoặc khởi động server
# (để tmux-continuum tự khôi phục) rồi attach vào session vừa khôi phục.

# Alacritty chạy script này trực tiếp (không qua login shell) nên PATH tối thiểu;
# thêm cả hai prefix Homebrew để chạy được trên Apple Silicon lẫn Intel.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
T="$(command -v tmux)"
[ -z "$T" ] && { echo "Không tìm thấy tmux trong PATH"; exec "${SHELL:-/bin/zsh}"; }

# Đang ở trong tmux rồi (vd: pane gọi lại) -> chạy shell thường, tránh lồng nhau
[ -n "$TMUX" ] && exec "${SHELL:-/bin/zsh}"

# Server đã chạy -> attach vào session hiện có
if "$T" has-session 2>/dev/null; then
  exec "$T" attach
fi

# Chưa có server (vd: sau khi khởi động lại máy):
# tạo một session tạm để server khởi động -> tmux-continuum tự restore ngầm.
"$T" new-session -d -s __boot__ 2>/dev/null

# Chờ tối đa ~6s cho các session được khôi phục xuất hiện
for _ in $(seq 1 24); do
  "$T" list-sessions -F '#S' 2>/dev/null | grep -qv '^__boot__$' && break
  sleep 0.25
done

# Nếu đã khôi phục được session thật -> bỏ session tạm
if "$T" list-sessions -F '#S' 2>/dev/null | grep -qv '^__boot__$'; then
  "$T" kill-session -t __boot__ 2>/dev/null
fi

exec "$T" attach
