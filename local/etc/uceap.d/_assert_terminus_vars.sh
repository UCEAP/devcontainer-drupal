function _assert_terminus_vars() {
	if [ -z "$TERMINUS_ENV" ]; then
		echo "TERMINUS_ENV environment variable is not set."
		exit 1
	fi

	if [ -z "$TERMINUS_SITE" ]; then
		echo "TERMINUS_SITE environment variable is not set."
		exit 1
	fi
}
