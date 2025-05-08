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

function uceap() {
	if [ $# -eq 0 ]; then
		help
		return 0
	else
		command="$1"
		func=("${command//-/_}")
		if [[ " ${funcs[@]} " =~ " ${func} " ]]; then
			shift
			eval "$func" "$@"
		else
			echo "[error] Unknown command: $func"
			help
		fi
	fi
}
