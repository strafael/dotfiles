prepend_path() { case ":$PATH:" in *":$1:"*) ;; *) PATH="$1:$PATH";; esac; }
append_path()  { case ":$PATH:" in *":$1:"*) ;; *) PATH="$PATH:$1";; esac; }

prepend_path "$HOME/bin"
prepend_path "$HOME/.local/bin"
prepend_path "${ASDF_DATA_DIR:-$HOME/.asdf}/shims"

export PATH
