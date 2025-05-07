# Load UCEAP functions
source_dir=$(dirname "${BASH_SOURCE[0]}")
if [ -d $source_dir/uceap.d ]; then
	for func in $source_dir/uceap.d/*; do
		if [ -f "$func" ]; then
			. "$func"
		fi
	done
fi
unset func

funcs=($(typeset -F | cut -d' ' -f3 | grep -vE '^_'))

function uceap_help() {
	echo "Available commands:"
	echo
	for func in "${funcs[@]}"; do
		command=("${func//_/-}")
		desc="_${func}_desc"
		echo "  $command: ${!desc}"
		echo
	done
	echo
	echo "Please run 'uceap <command>' to execute a command."
	echo "Please run 'uceap help <command>' to see the help for a command."
}

function uceap() {
	if [ $# -eq 0 ]; then
		uceap_help
		return 0
	fi
	if [ "$1" == "help" ]; then
		if [ $# -eq 2 ]; then
			command="$2"
			func=("${command//-/_}")
			if [[ " ${funcs[@]} " =~ " ${func} " ]]; then
				help="_${func}_help"
				echo "${!help}"
			else
				echo "[error] Unknown command: $func"
				uceap_help
			fi
		else
			uceap_help
		fi
	else
		command="$1"
		func=("${command//-/_}")
		if [[ " ${funcs[@]} " =~ " ${func} " ]]; then
			shift
			eval "$func" "$@"
		else
			echo "[error] Unknown command: $func"
			uceap_help
		fi
	fi
}
