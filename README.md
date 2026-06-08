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
