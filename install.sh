#!/usr/bin/env bash
#
# mac-setup — replicate Tharindu's terminal environment on a fresh Mac.
#
#   bash install.sh              # everything
#   bash install.sh --shell      # oh-my-zsh + plugins + .zshrc/.zprofile only
#   bash install.sh --brew       # Homebrew + formulae + casks only
#   bash install.sh --git        # git identity only
#   bash install.sh --no-casks   # skip the GUI apps (combine with others)
#
# Safe to re-run: every step checks before it acts, and existing dotfiles are
# backed up to <file>.backup.<timestamp> before being replaced.

set -euo pipefail

TS="$(date +%Y%m%d-%H%M%S)"
DO_SHELL=0 DO_BREW=0 DO_GIT=0 SKIP_CASKS=0 ANY=0

for arg in "$@"; do
  case "$arg" in
    --shell)     DO_SHELL=1; ANY=1 ;;
    --brew)      DO_BREW=1;  ANY=1 ;;
    --git)       DO_GIT=1;   ANY=1 ;;
    --no-casks)  SKIP_CASKS=1 ;;
    -h|--help)   sed -n '2,15p' "$0"; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 1 ;;
  esac
done
if [ "$ANY" -eq 0 ]; then DO_SHELL=1; DO_BREW=1; DO_GIT=1; fi

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m  ok\033[0m %s\n' "$*"; }
skip() { printf '\033[1;33m  --\033[0m %s\n' "$*"; }

backup() {
  [ -e "$1" ] && { cp "$1" "$1.backup.$TS"; ok "backed up $1 -> $1.backup.$TS"; }
  return 0
}

# ---------------------------------------------------------------- Xcode CLT
if [ "$DO_BREW" -eq 1 ]; then
  info "Xcode command line tools"
  if xcode-select -p >/dev/null 2>&1; then
    ok "already installed"
  else
    xcode-select --install || true
    echo "  Finish the Xcode CLT installer in the GUI, then re-run this script."
    exit 1
  fi
fi

# ---------------------------------------------------------------- Homebrew
BREW_BIN=""
if [ "$DO_BREW" -eq 1 ] || [ "$DO_SHELL" -eq 1 ]; then
  if [ -x /opt/homebrew/bin/brew ]; then BREW_BIN=/opt/homebrew/bin/brew
  elif [ -x /usr/local/bin/brew ]; then BREW_BIN=/usr/local/bin/brew
  fi
fi

if [ "$DO_BREW" -eq 1 ]; then
  info "Homebrew"
  if [ -n "$BREW_BIN" ]; then
    ok "already installed at $BREW_BIN"
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -x /opt/homebrew/bin/brew ]; then BREW_BIN=/opt/homebrew/bin/brew; else BREW_BIN=/usr/local/bin/brew; fi
  fi
  eval "$("$BREW_BIN" shellenv)"

  info "Homebrew formulae"
  # Top-level packages only; dependencies come along automatically.
  FORMULAE=(autocannon awscli gh k6 make wget)
  for f in "${FORMULAE[@]}"; do
    if brew list --formula "$f" >/dev/null 2>&1; then skip "$f already installed"
    else brew install "$f" && ok "$f"; fi
  done

  if [ "$SKIP_CASKS" -eq 1 ]; then
    skip "casks (--no-casks)"
  else
    info "Homebrew casks (GUI apps)"
    CASKS=(
      caffeine        # keep the Mac awake
      claude-code     # Claude Code CLI
      dbngin          # local MySQL/PostgreSQL servers
      discord
      gstreamer-runtime
      herd            # Laravel Herd: PHP 8.1-8.4 + nvm + nginx
      raycast         # launcher
      rectangle       # window snapping
      sequel-ace      # MySQL GUI
      sketch
      vlc
      vorssaint
    )
    for c in "${CASKS[@]}"; do
      if brew list --cask "$c" >/dev/null 2>&1; then skip "$c already installed"
      else brew install --cask "$c" && ok "$c"; fi
    done
  fi
fi

# ---------------------------------------------------------------- oh-my-zsh
if [ "$DO_SHELL" -eq 1 ]; then
  info "oh-my-zsh"
  if [ -d "$HOME/.oh-my-zsh" ]; then
    ok "already installed"
  else
    RUNZSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ok "installed"
  fi

  ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

  info "zsh plugins"
  # zsh-autosuggestions: ghost-text completion from history as you type.
  if [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    skip "zsh-autosuggestions already present"
  else
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions \
      "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    ok "zsh-autosuggestions"
  fi

  # ------------------------------------------------------------- .zprofile
  info "~/.zprofile"
  backup "$HOME/.zprofile"
  cat > "$HOME/.zprofile" <<'EOF'

eval "$(/opt/homebrew/bin/brew shellenv zsh)"
EOF
  ok "written"

  # --------------------------------------------------------------- .zshrc
  info "~/.zshrc"
  backup "$HOME/.zshrc"
  cat > "$HOME/.zshrc" <<'EOF'
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# git      -> gst/gco/gp/glog etc. aliases + branch name in the prompt
# autosugg -> greyed-out suggestion from history, accept with the right arrow
plugins=(git zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# ---------------------------------------------------------------- aliases
alias ar="php artisan"

# ------------------------------------------------------------------- Herd
# Laravel Herd: PHP binaries, per-version ini scan dirs, and its bundled nvm.
if [ -d "$HOME/Library/Application Support/Herd" ]; then
  export PATH="$HOME/Library/Application Support/Herd/bin/":$PATH

  export HERD_PHP_84_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/84/"
  export HERD_PHP_83_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/83/"
  export HERD_PHP_82_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/82/"
  export HERD_PHP_81_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/81/"

  export NVM_DIR="$HOME/Library/Application Support/Herd/config/nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

[[ -f "/Applications/Herd.app/Contents/Resources/config/shell/zshrc.zsh" ]] \
  && builtin source "/Applications/Herd.app/Contents/Resources/config/shell/zshrc.zsh"

# -------------------------------------------------------- Antigravity IDE
[ -d "$HOME/.antigravity-ide/antigravity-ide/bin" ] \
  && export PATH="$HOME/.antigravity-ide/antigravity-ide/bin:$PATH"
EOF
  ok "written"

  info "default shell"
  if [ "${SHELL:-}" = "/bin/zsh" ]; then ok "already zsh"
  else chsh -s /bin/zsh && ok "set to /bin/zsh"; fi
fi

# ---------------------------------------------------------------- git
if [ "$DO_GIT" -eq 1 ]; then
  info "git identity"
  git config --global user.name  "Tharindu Wijayarathna"
  git config --global user.email "wikum.dev@gmail.com"
  ok "Tharindu Wijayarathna <wikum.dev@gmail.com>"
fi

echo
info "Done. Run 'exec zsh' or open a new terminal tab to load the new shell."
