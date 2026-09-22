### History
export HISTFILE=$PERSONAL_FILES/zsh_history
export HISTSIZE=10000
# How many commands history will save on file.
export SAVEHIST=10000

export EDITOR="nvim"
# Use the macOS default browser instead of forcing a particular application.
[[ $OSTYPE == darwin* ]] && export BROWSER="open"

# Path Variables
export VISUAL='nvim'

# Expose GitHub CLI's credential to tools that require GITHUB_TOKEN without
# storing the token in this repository. A missing/invalid login leaves it unset.
if (( $+commands[gh] )) && github_token=$(gh auth token 2>/dev/null); then
  export GITHUB_TOKEN="$github_token"
fi
unset github_token

# Use the repo-managed Lazygit theme on macOS and remote hosts.
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml"
