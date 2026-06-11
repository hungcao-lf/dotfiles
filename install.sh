#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# dotfiles installer — tmux + Alacritty + zsh (oh-my-zsh)
#
# Chạy trên một máy Mac mới:
#   git clone <repo-url> ~/dotfiles && cd ~/dotfiles && ./install.sh
#
# Ghi đè TẤT CẢ config liên quan (kể cả khi máy đã có sẵn). Bản cũ được
# backup thành *.bak.<timestamp> trước khi ghi đè. Chạy lại nhiều lần an toàn.
# ---------------------------------------------------------------------------
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log()  { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }

[ "$(uname -s)" = "Darwin" ] || { echo "Script này chỉ dành cho macOS."; exit 1; }

# Backup file/dir nếu đang tồn tại (giữ lại bản cũ, không xoá trắng)
backup() {
  if [ -e "$1" ] || [ -L "$1" ]; then
    local b="$1.bak.$(date +%Y%m%d%H%M%S)"
    mv "$1" "$b"
    warn "đã backup $1 -> $b"
  fi
}

# Clone mới hoặc cập nhật repo git có sẵn
clone_or_pull() { # $1 url, $2 dest
  if [ -d "$2/.git" ]; then
    git -C "$2" pull --ff-only || warn "không pull được $2 (bỏ qua)"
  else
    rm -rf "$2"
    git clone --depth=1 "$1" "$2"
  fi
}

# ---------------------------------------------------------------------------
# 1) Homebrew + packages
# ---------------------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  log "Cài Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Nạp brew vào PATH cho cả Apple Silicon (/opt/homebrew) lẫn Intel (/usr/local)
if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)";
elif [ -x /usr/local/bin/brew ]; then eval "$(/usr/local/bin/brew shellenv)"; fi

log "Cài tmux, Alacritty, font Nerd, jq, chafa..."
brew list jq              >/dev/null 2>&1 || brew install jq
brew list chafa           >/dev/null 2>&1 || brew install chafa
brew list tmux            >/dev/null 2>&1 || brew install tmux
brew list --cask alacritty                  >/dev/null 2>&1 || brew install --cask alacritty
brew list --cask font-jetbrains-mono-nerd-font >/dev/null 2>&1 || brew install --cask font-jetbrains-mono-nerd-font

# ---------------------------------------------------------------------------
# 2) tmux config + scripts
# ---------------------------------------------------------------------------
log "Đặt config tmux..."
mkdir -p ~/.config/tmux ~/.config/tmux/art
backup ~/.tmux.conf
cp "$DOTFILES_DIR/tmux/.tmux.conf"      ~/.tmux.conf
cp "$DOTFILES_DIR/tmux/nyan-anim.sh"    ~/.config/tmux/nyan-anim.sh
cp "$DOTFILES_DIR/tmux/tmux-launch.sh"  ~/.config/tmux/tmux-launch.sh
cp "$DOTFILES_DIR/tmux/tmux-pwd.sh"     ~/.config/tmux/tmux-pwd.sh
cp "$DOTFILES_DIR/tmux/tmux-claude.sh"  ~/.config/tmux/tmux-claude.sh
cp "$DOTFILES_DIR/tmux/claude-usage-statusline.sh" ~/.config/tmux/claude-usage-statusline.sh
cp "$DOTFILES_DIR/tmux/tmux-pet.sh"     ~/.config/tmux/tmux-pet.sh
cp "$DOTFILES_DIR/tmux/goku.sh"         ~/.config/tmux/goku.sh
chmod +x ~/.config/tmux/nyan-anim.sh ~/.config/tmux/tmux-launch.sh ~/.config/tmux/tmux-pwd.sh \
         ~/.config/tmux/tmux-claude.sh ~/.config/tmux/claude-usage-statusline.sh \
         ~/.config/tmux/tmux-pet.sh ~/.config/tmux/goku.sh

# ---------------------------------------------------------------------------
# 3) Alacritty config (thay placeholder bằng đường dẫn launcher thật)
# ---------------------------------------------------------------------------
log "Đặt config Alacritty..."
mkdir -p ~/.config/alacritty
backup ~/.config/alacritty/alacritty.toml
sed "s|__TMUX_LAUNCH__|$HOME/.config/tmux/tmux-launch.sh|g" \
  "$DOTFILES_DIR/alacritty/alacritty.toml" > ~/.config/alacritty/alacritty.toml
# Theme mà alacritty.toml import (themes/themes/terminal_app.toml)
clone_or_pull https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes

# ---------------------------------------------------------------------------
# 4) oh-my-zsh + plugins + .zshrc
# ---------------------------------------------------------------------------
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
if [ ! -d "$ZSH" ]; then
  log "Cài oh-my-zsh..."
  RUNZSH=no KEEP_ZSHRC=yes CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
log "Cài plugin zsh (autosuggestions, syntax-highlighting, completions)..."
clone_or_pull https://github.com/zsh-users/zsh-autosuggestions     "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_or_pull https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
clone_or_pull https://github.com/zsh-users/zsh-completions         "$ZSH_CUSTOM/plugins/zsh-completions"

log "Đặt .zshrc..."
backup ~/.zshrc
cp "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc

# ---------------------------------------------------------------------------
# 5) TPM + plugin tmux (resurrect + continuum) — cài headless
# ---------------------------------------------------------------------------
log "Cài TPM + plugin tmux..."
clone_or_pull https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins || warn "install_plugins lỗi (chạy lại prefix + I trong tmux)"

# ---------------------------------------------------------------------------
# 6) Claude Code statusLine -> cầu nối % rate-limit ra tmux
#    (widget "5h NN%" ở status bar đọc cache do statusLine ghi)
# ---------------------------------------------------------------------------
if [ -d "$HOME/.claude" ] || command -v claude >/dev/null 2>&1; then
  log "Cấu hình statusLine của Claude Code..."
  mkdir -p "$HOME/.claude"
  SETTINGS="$HOME/.claude/settings.json"
  [ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
  cp "$SETTINGS" "$SETTINGS.bak.$(date +%Y%m%d%H%M%S)"
  tmp="$(mktemp)"
  jq --arg cmd "$HOME/.config/tmux/claude-usage-statusline.sh" \
     '.statusLine = {type:"command", command:$cmd, padding:0}' \
     "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
else
  warn "Không thấy Claude Code (~/.claude) — bỏ qua statusLine."
  warn "Widget '5h NN%' ở tmux sẽ ẩn cho tới khi có dữ liệu usage."
fi

# ---------------------------------------------------------------------------
# 7) Đặt zsh làm shell mặc định
# ---------------------------------------------------------------------------
ZSH_BIN="$(command -v zsh)"
if [ "${SHELL:-}" != "$ZSH_BIN" ]; then
  grep -q "$ZSH_BIN" /etc/shells || echo "$ZSH_BIN" | sudo tee -a /etc/shells >/dev/null || true
  warn "Đổi shell mặc định sang zsh (có thể hỏi mật khẩu)..."
  chsh -s "$ZSH_BIN" || warn "chsh thất bại — đổi thủ công sau."
fi

log "XONG! Mở một cửa sổ Alacritty MỚI -> tự vào tmux."
log "tmux tự lưu session mỗi 15' và tự khôi phục sau khi reboot."
