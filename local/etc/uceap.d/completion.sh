function completion() {
    # Validate arguments
    if [ $# -ne 1 ]; then
        echo "[error] Usage: completion <shell>" >&2
        return 1
    fi

    # Convert function names to command names (replace _ with -)
    local commands=("${funcs[@]//_/-}")
    local shell="$1"

    case "$shell" in
        bash)
            _generate_bash_completion "${commands[@]}"
            ;;
        zsh)
            _generate_zsh_completion "${commands[@]}"
            ;;
        *)
            echo "[error] Unsupported shell: $shell" >&2
            return 1
            ;;
    esac
}

function _generate_bash_completion() {
    cat <<EOF
_uceap_completions() {
    local cur prev opts
    COMPREPLY=()
    cur="\${COMP_WORDS[COMP_CWORD]}"
    prev="\${COMP_WORDS[COMP_CWORD-1]}"
    opts="${commands[*]}"

    if [[ \$COMP_CWORD -eq 1 ]]; then
        COMPREPLY=( \$(compgen -W "\$opts help" -- "\$cur") )
    elif [[ \$COMP_CWORD -eq 2 && "\$prev" == "help" ]]; then
        COMPREPLY=( \$(compgen -W "\$opts" -- "\$cur") )
    fi
}
complete -F _uceap_completions uceap
EOF
}

function _generate_zsh_completion() {
    cat <<EOF
_uceap() {
    local -a commands
    commands=(${commands[*]})
    if (( CURRENT == 2 )); then
        _arguments "1: :((help \${commands[*]}))"
        return
    fi
    if (( CURRENT == 3 )); then
        if [[ \$words[2] == help ]]; then
            _arguments "2: :(\${commands[*]})"
            return
        fi
    fi
}
compdef _uceap uceap
EOF
}

_completion_desc="generate shell completion scripts"
_completion_help='
Generate shell completion scripts for UCEAP CLI commands.

# Usage

``` sh
uceap completion bash
uceap completion zsh
```

## bash

First, ensure that you install `bash-completion` using your package manager.

After, add this to your `~/.bash_profile`:

``` bash
eval "$(uceap completion bash)"
```

## zsh

Generate a `_uceap` completion script and put it somewhere in your `$fpath`:

``` zsh
uceap completion zsh > /usr/local/share/zsh/site-functions/_uceap
```

Ensure that the following is present in your `~/.zshrc`:

``` zsh
autoload -U compinit
compinit -i
```

Zsh version 5.7 or later is recommended.
'