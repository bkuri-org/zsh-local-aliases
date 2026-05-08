# local-aliases — per-directory aliases for zsh

Drop a `.aliases` file anywhere. Its aliases **auto-load** when you `cd` into the directory tree and **auto-unload** when you leave. Global aliases are never touched.

Like `.gitignore` or `.env`, but for aliases.

## Usage

```bash
# ~/projects/my-app/.aliases
alias status='git status --short'
alias deploy='git push && ssh prod "cd /app && git pull && systemctl reload app"'
alias logs='journalctl -fu app --since "5 min ago"'
```

```bash
# ~/projects/infra/.aliases
alias status='sudo systemctl status --all'
alias logs='journalctl -f -n 50'
```

Move between directories — the right aliases follow you:

```bash
cd ~/projects/my-app
status  # → git status --short

cd ~/projects/infra
status  # → sudo systemctl status --all

cd /
status  # → (no status alias, falls back to whatever was defined globally)
```

### Cascading

Files are discovered by walking up from `$PWD` toward `/`. The file **nearest to `$PWD`** wins for any alias name collision. This means a child directory can override a parent's alias.

```
~/projects/
  .aliases          # alias status='git status'
  sub-project/
    .aliases        # alias status='git status --short'  ← wins here
```

## Installation

### oh-my-zsh

```bash
git clone https://github.com/yourname/zsh-local-aliases \
  ${ZSH_CUSTOM:-$ZSH/custom}/plugins/local-aliases
```

Then add to your `plugins=()` list in `.zshrc`:

```zsh
plugins=(... local-aliases)
```

### Standalone (no OMZ)

Source the plugin directly in your `.zshrc`:

```zsh
source /path/to/local-aliases/local-aliases.plugin.zsh
```

### Antigen / Antidote / Zinit

```bash
antigen bundle yourname/zsh-local-aliases
# or
antidote bundle yourname/zsh-local-aliases
```

## Configuration

Override the filename (default `.aliases`):

```zsh
ZSH_LOCAL_ALIASES_FILE=.my-aliases   # before sourcing the plugin
```

## How it works

1. On `cd`, walks up from `$PWD` to `/` collecting all `.aliases` files
2. Unloads any aliases that were previously injected by local files
3. Sources the files (root-most first, nearest last — so nearest wins)
4. Compares the alias list before/after to track only what's new

No state files, no prompt, no manual registration. Just `alias x=y` in a file.

## License

MIT