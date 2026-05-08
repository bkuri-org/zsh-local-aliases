# ── local-aliases: per-directory aliases for zsh ─────────────────
# Drop a .aliases file in any directory. Its aliases auto-load
# when you cd into the tree and auto-unload when you leave.
#
# Works with oh-my-zsh (add to plugins=()) or standalone:
#   source /path/to/local-aliases.plugin.zsh
# ────────────────────────────────────────────────────────────────

# Configurable filename (default: .aliases)
: ${ZSH_LOCAL_ALIASES_FILE:=.aliases}

typeset -gA _local_aliases=()

function _source_local_aliases() {
  local target_dir="${1:-$PWD}"
  local dir="$target_dir"
  local files=()

  # Walk up collecting .aliases files (root-most first → nearest last)
  while [[ "$dir" != "/" ]]; do
    [[ -f "$dir/$ZSH_LOCAL_ALIASES_FILE" ]] && files=("$dir/$ZSH_LOCAL_ALIASES_FILE" $files)
    dir="$(dirname "$dir")"
  done

  # Step 1: Unalias everything previously injected by local files
  local name
  for name in "${(@k)_local_aliases}"; do
    unalias "$name" 2>/dev/null || true
  done
  _local_aliases=()

  # Step 2: Snapshot current alias names before sourcing
  local -A before
  while IFS='=' read -r k _; do
    before[$k]=1
  done < <(alias -L | sed 's/^alias //; s/=.*//')

  # Step 3: Source all .aliases files (nearest to CWD wins = last sourced)
  local f
  for f in $files; do
    source "$f"
  done

  # Step 4: Track whatever is new since the snapshot
  while IFS='=' read -r k _; do
    [[ -z "${before[$k]}" ]] && _local_aliases[$k]=1
  done < <(alias -L | sed 's/^alias //; s/=.*//')
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _source_local_aliases
_source_local_aliases "$PWD"