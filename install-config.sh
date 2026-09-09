#!/bin/zsh
# Link only declared files; keep application state in the home directory.
emulate -L zsh
setopt err_exit pipefail
repo=${0:A:h}
dry_run=0
case "${1:-}" in
  --dry-run) dry_run=1 ;;
  '') ;;
  *) print -u2 'Usage: ./install-config.sh [--dry-run]'; exit 2 ;;
esac
(( $# <= 1 )) || exit 2
backup_root=''
backup_count=0
backup() {
  local target=$1 relative=${1#$HOME/}
  if (( dry_run )); then
    print -r -- "Back up: $target"
    return
  fi
  if [[ -z $backup_root ]]; then
    mkdir -p "$HOME/.local/state/dotfiles/backups"
    backup_root=$(mktemp -d "$HOME/.local/state/dotfiles/backups/install.XXXXXXXX")
  fi
  # Separate each backup: a saved parent symlink must never be traversed by a
  # later backup of one of its children.
  backup_count=$((backup_count + 1))
  mkdir -p "$backup_root/$backup_count/${relative:h}"
  mv -- "$target" "$backup_root/$backup_count/$relative"
}
# Detach directory symlinks before writing through them. Copy first, so a failed
# copy leaves the original link and its contents intact.
ensure_directory() {
  local target=$1 staging
  [[ $target == $HOME ]] && return
  ensure_directory "${target:h}"
  if [[ -L $target ]]; then
    [[ -d $target ]] || { print -u2 -- "Not a directory: $target"; return 1; }
    print -r -- "Preserve contents and replace directory symlink: $target"
    if (( dry_run )); then
      return
    fi
    staging=$(mktemp -d "${target}.migration.XXXXXXXX")
    cp -Rp "$target/." "$staging/"
    backup "$target"
    mv -- "$staging" "$target"
  elif [[ ! -d $target ]]; then
    if [[ -e $target ]]; then backup "$target"; fi
    if (( ! dry_run )); then mkdir -p "$target"; fi
  fi
}
# Validate the entire manifest before making changes.
typeset -a entries
while IFS= read -r entry || [[ -n $entry ]]; do
  [[ -z $entry || $entry == \#* ]] && continue
  [[ $entry != /* && /$entry/ != */../* && -f "$repo/config/$entry" ]] || {
    print -u2 -- "Invalid or missing managed file: $entry"; exit 1
  }
  entries+=("$entry")
done < "$repo/config-links.txt"
link_file() {
  local source=$1 target=$2
  ensure_directory "${target:h}"
  if [[ -L $target && ${target:A} == ${source:A} ]]; then return; fi
  print -r -- "Link: $target -> $source"
  if [[ -e $target || -L $target ]]; then backup "$target"; fi
  if (( ! dry_run )); then ln -s -- "$source" "$target"; fi
}
for entry in "${entries[@]}"; do
  link_file "$repo/config/$entry" "$HOME/.config/$entry"
done
link_file "$repo/config/zsh/zshrc" "$HOME/.zshrc"
[[ -z $backup_root ]] || print -r -- "Backups: $backup_root"
print 'Configuration links ready. No packages or plugins were installed.'
