#!/bin/bash
# statusLine command cho Claude Code.
# - Đọc JSON từ stdin (Claude Code truyền vào mỗi lần render).
# - Lấy % ĐÃ DÙNG của cửa sổ 5h/7d (dữ liệu rate-limit chính thống) + giờ reset.
# - Ghi ra ~/.cache/claude-usage (tab-separated) cho tmux đọc.
# - In một dòng status cho TUI của Claude Code.
#
# Lưu ý: Anthropic KHÔNG công bố hạn mức token tuyệt đối của Max/Pro, nên thứ
# trung thực nhất hiển thị được là % cửa sổ rate-limit, không phải "số token".

input="$(cat)"
cache="$HOME/.cache/claude-usage"
mkdir -p "$HOME/.cache"

# Lưu payload thô để debug/kiểm tra field (ghi đè mỗi lần, file nhỏ)
printf '%s' "$input" > "$HOME/.cache/claude-statusline-raw.json"

# Parse phòng thủ: field nào vắng (bản cũ) -> rỗng
IFS=$'\t' read -r five seven reset model dir < <(
  printf '%s' "$input" | jq -r '
    [ (.rate_limits.five_hour.used_percentage // empty),
      (.rate_limits.seven_day.used_percentage // empty),
      (.rate_limits.five_hour.resets_at       // empty),
      (.model.display_name // .model.id // "claude"),
      (.workspace.current_dir // .cwd // "") ] | @tsv' 2>/dev/null)

now="$(date +%s)"

# Cache cho tmux: 5h_used  7d_used  5h_reset_epoch  written_epoch  (đã bỏ thập phân)
printf '%s\t%s\t%s\t%s\n' "${five%.*}" "${seven%.*}" "${reset%.*}" "$now" > "$cache"

# Dòng status cho TUI Claude Code (hiện % CÒN LẠI cho dễ đọc)
out="${model:-claude}"
[ -n "$dir" ]   && out="$out  ${dir##*/}"
[ -n "$five" ]  && out="$out  5h $(( 100 - ${five%.*} ))%"
[ -n "$seven" ] && out="$out  7d $(( 100 - ${seven%.*} ))%"
[ -n "$reset" ] && out="$out  ↻$(date -r "${reset%.*}" +%H:%M 2>/dev/null)"
printf '%s\n' "$out"
