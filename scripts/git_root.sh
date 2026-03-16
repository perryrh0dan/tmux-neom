#!/usr/bin/env bash

# return current working directory of tmux pane
getPaneDir() {
  nextone="false"
  ret=""
  for i in $(tmux list-panes -F "#{pane_active} #{pane_current_path}"); do
    [ "$i" == "1" ] && nextone="true" && continue
    [ "$i" == "0" ] && nextone="false"
    [ "$nextone" == "true" ] && ret+="$i "
  done
  echo "${ret%?}"
}

main() {
  path=$(getPaneDir)

  git_root=$(git -C "$path" rev-parse --show-toplevel 2>/dev/null)
  if [[ -n "$git_root" ]]; then
    basename "$git_root"
  else
    # fallback: print basename of current directory
    basename "$path"
  fi
}

#run main driver program
main
