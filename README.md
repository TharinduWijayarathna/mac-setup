# mac-setup

My terminal environment, as a single idempotent script. Run it on a fresh Mac
and get the same shell I use day to day.

## Usage

```bash
git clone <this-repo> ~/mac-setup
bash ~/mac-setup/install.sh
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

## Not covered

Apple Terminal's colors, font and window size live in the `com.apple.Terminal`
defaults domain rather than a dotfile. To carry those across: Terminal →
Settings → Profiles → Export, and import the `.terminal` file on the new Mac.
