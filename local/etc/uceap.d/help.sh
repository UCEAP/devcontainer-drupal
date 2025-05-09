function help() {
	if [ $# -eq 1 ]; then
		command="$1"
		func=("${command//-/_}")
		if [[ " ${funcs[@]} " =~ " ${func} " ]]; then
			help="_${func}_help"
			echo "${!help}" | glow
		else
			echo "[error] Unknown command: $func"
			_help | glow
		fi
	else
		_help | glow
	fi
}

function _help() {
	echo 'Available commands:'
	echo
	for func in "${funcs[@]}"; do
		command=("${func//_/-}")
		desc="_${func}_desc"
		echo "- **$command**: ${!desc}"
		echo
	done
	echo
	echo 'Please run `uceap <command>` to execute a command.'
	echo 'Please run `uceap help <command>` to see the help for a command.'
}
_help_desc='displays help for uceap commands'
_help_help='
Show help for UCEAP CLI commands.

# Usage

``` sh
uceap help
uceap help <command>
```
'