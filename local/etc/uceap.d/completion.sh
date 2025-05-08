function completion() {
	commands=("${funcs[@]//_/-}")
	if [ $# -eq 1 ]; then
		shell="$1"
		case "$shell" in
			bash)
  		  echo complete -W \"${commands[*]}\" uceap
				;;
			zsh)
				echo "_uceap() { _arguments \"1: :(${commands[*]})\" }"
				echo "compdef _uceap uceap"
				;;
			*)
				echo "[error] Unsupported shell: $shell"
				return 1
				;;
		esac
	else
		echo "[error] Invalid number of arguments"
		return 1
	fi
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