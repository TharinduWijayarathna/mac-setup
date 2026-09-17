# mac-setup

My terminal environment, as a single idempotent script. Run it on a fresh Mac
and get the same shell I use day to day.

Repo: <https://github.com/TharinduWijayarathna/mac-setup> (private)

## Usage

This repo is **private**, so a fresh Mac needs GitHub auth before it can clone.
That's mildly circular — `gh` is one of the formulae this script installs — so
pick whichever bootstrap suits the machine.

**With `gh`:**

```bash
brew install gh          # if Homebrew is already there
gh auth login
gh repo clone TharinduWijayarathna/mac-setup ~/mac-setup
bash ~/mac-setup/install.sh
```

**Without cloning** — the script is standalone and has no dependency on the
repo around it, so copying the one file over is enough:

```bash
scp ~/mac-setup/install.sh newmac:~/
ssh newmac 'bash ~/install.sh'
```

### Flags

| Command | What it does |
| --- | --- |
| `bash install.sh` | Everything: brew, shell, git identity |
| `bash install.sh --shell` | oh-my-zsh + plugins + `.zshrc`/`.zprofile` only |
| `bash install.sh --brew` | Homebrew + formulae + casks only |
| `bash install.sh --git` | git identity only |
| `bash install.sh --brew --no-casks` | CLI tools, skip the GUI apps |

Safe to re-run — every step checks before it acts, and existing dotfiles are
backed up to `<file>.backup.<timestamp>` before being replaced.

## What it sets up

**Shell** — oh-my-zsh with the `robbyrussell` theme, `git` and
`zsh-autosuggestions` plugins, and `alias ar="php artisan"`.

**PATH** — Homebrew via `.zprofile`, Laravel Herd (PHP 8.1–8.4 plus its bundled
nvm), and Antigravity IDE. The Herd and Antigravity blocks are guarded, so they
stay inert on a machine where those aren't installed.

**Homebrew formulae** — `autocannon` `awscli` `gh` `k6` `make` `wget`

**Homebrew casks** — `caffeine` `claude-code` `dbngin` `discord`
`gstreamer-runtime` `herd` `raycast` `rectangle` `sequel-ace` `sketch` `vlc`
`vorssaint`

**git** — global `user.name` and `user.email`.

## Where this came from

Captured from my main MacBook (macOS 14 / Darwin 24.6, Apple Silicon) on
2026-09-17 by reading the live `.zshrc`, `.zprofile`, `~/.oh-my-zsh/custom`,
`brew leaves`, `brew list --cask` and `~/.gitconfig`. The generated `.zshrc` was
test-loaded in an isolated `ZDOTDIR` to confirm oh-my-zsh sources cleanly, both
plugins load, and the alias resolves.

If the source machine drifts, re-capture rather than hand-editing — the point of
this file is that it matches something real.

## Not covered

Apple Terminal's colors, font and window size live in the `com.apple.Terminal`
defaults domain rather than a dotfile. To carry those across: Terminal →
Settings → Profiles → Export, and import the `.terminal` file on the new Mac.
