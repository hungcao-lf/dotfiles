# dotfiles

Setup terminal cá nhân cho macOS: **tmux + Alacritty + zsh (oh-my-zsh)**.
Mục tiêu: cài 1 phát trên máy Mac mới là dùng được ngay, và **session tmux tự
khôi phục sau khi tắt/mở máy**.

## Cài đặt

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

Script sẽ **ghi đè** mọi config liên quan (kể cả khi máy đã có sẵn tmux/zsh).
Bản cũ được backup thành `*.bak.<timestamp>` trước khi ghi đè, nên không mất gì.
Chạy lại nhiều lần đều an toàn (idempotent).

Sau khi xong: **mở một cửa sổ Alacritty mới** → tự vào tmux.

## Có gì bên trong

| Thành phần | File trong repo | Cài tới |
|---|---|---|
| tmux config | `tmux/.tmux.conf` | `~/.tmux.conf` |
| tmux launcher | `tmux/tmux-launch.sh` | `~/.config/tmux/tmux-launch.sh` |
| nyan cat status bar | `tmux/nyan-anim.sh` | `~/.config/tmux/nyan-anim.sh` |
| pet động (đổi `prefix+e`) | `tmux/tmux-pet.sh` | `~/.config/tmux/tmux-pet.sh` |
| Goku/ảnh qua chafa (`prefix+g`) | `tmux/goku.sh` | `~/.config/tmux/goku.sh` |
| pwd ở status bar | `tmux/tmux-pwd.sh` | `~/.config/tmux/tmux-pwd.sh` |
| widget usage Claude | `tmux/tmux-claude.sh` | `~/.config/tmux/tmux-claude.sh` |
| statusLine Claude Code | `tmux/claude-usage-statusline.sh` | `~/.config/tmux/claude-usage-statusline.sh` |
| Alacritty | `alacritty/alacritty.toml` | `~/.config/alacritty/alacritty.toml` |
| zsh | `zsh/.zshrc` | `~/.zshrc` |

`install.sh` còn tự cài: Homebrew, tmux, Alacritty, font JetBrainsMono Nerd,
oh-my-zsh + 3 plugin (autosuggestions, syntax-highlighting, completions),
TPM + plugin tmux (resurrect + continuum), theme Alacritty.

## Tự khôi phục session (cách hoạt động)

- **tmux-resurrect** + **tmux-continuum**: tự lưu session mỗi **15 phút**
  (và lưu cả nội dung pane). Lưu/khôi phục tay: `Ctrl-a Ctrl-s` / `Ctrl-a Ctrl-r`.
- **Alacritty** chạy thẳng `tmux-launch.sh` (`[terminal.shell]`), nên mở cửa sổ
  nào cũng vào tmux. Sau reboot, lần mở đầu tiên sẽ khởi động tmux server →
  continuum tự khôi phục session đã lưu.

> Không dùng cơ chế `@continuum-boot` (gõ phím qua AppleScript) vì cần quyền
> Accessibility và dễ gây lồng tmux. Việc auto-vào-tmux do Alacritty đảm nhận.

### Muốn Alacritty tự mở ngay khi đăng nhập máy?

Thêm Alacritty vào **System Settings → General → Login Items → "+"**.
Đăng nhập → Alacritty mở → `tmux-launch.sh` chạy → session cũ hiện lại.

## Widget usage Claude ở status bar (`5h NN%`)

Hiện **% CÒN LẠI của cửa sổ rate-limit 5 giờ** của Claude Code, kèm giờ reset
(vd `5h 70% ↻18:50`). Tô màu: xanh → vàng → đỏ khi sắp hết. Dữ liệu cũ hơn
15' (không có session Claude nào chạy) sẽ bị làm mờ + thêm dấu `~`.

Cách hoạt động:

```
Claude Code  --(statusLine, stdin JSON)-->  claude-usage-statusline.sh
                                                   |  ghi ~/.cache/claude-usage
                                                   v
                                   tmux #(tmux-claude.sh)  -> status bar
```

`install.sh` tự gắn `statusLine` vào `~/.claude/settings.json` (merge bằng jq,
không đụng các key khác; có backup).

> ⚠️ **Không có "số token còn lại" tuyệt đối.** Anthropic không công bố hạn mức
> token của Max/Pro. Thứ chính thống & trung thực nhất là **% cửa sổ rate-limit**
> mà Claude Code đưa cho `statusLine` (`rate_limits.five_hour.used_percentage`,
> `resets_at`). Widget chỉ cập nhật khi có session Claude Code đang chạy.

## Ảnh trong terminal — `chafa` (`prefix + g`)

`tmux/goku.sh` đổi 1 ảnh thành **block art truecolor** (chạy được trên Alacritty,
vốn không hỗ trợ ảnh thật). Tự bỏ ảnh của bạn vào `~/.config/tmux/art/goku.png`,
rồi:
- gõ `goku` (alias) để hiện trong pane, hoặc
- `prefix + g` để hiện trong **popup nổi**.

> Repo **không kèm ảnh** (tránh dính bản quyền) — bạn tự thêm ảnh của mình. Mọi
> `*.png/jpg/gif` đều bị `.gitignore` bỏ qua.

## Phím tắt tmux (prefix = `Ctrl-a`)

| Phím | Tác dụng |
|---|---|
| `Ctrl-a` `\|` / `-` | chia pane dọc / ngang |
| `Alt + mũi tên` | chuyển pane (không cần prefix) |
| `Alt + số` | chuyển window |
| `Ctrl-a m` | zoom pane |
| `Ctrl-a Ctrl-s` / `Ctrl-a Ctrl-r` | lưu / khôi phục session |
| `Ctrl-a r` | reload `~/.tmux.conf` |

## Gỡ / khôi phục bản cũ

Mỗi file cũ được backup kèm timestamp, ví dụ `~/.tmux.conf.bak.20260608_2245`.
Đổi tên lại để khôi phục.
