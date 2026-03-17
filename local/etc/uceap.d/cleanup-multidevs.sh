function cleanup_multidevs() {
	_terminus_login
	multidevs=($(terminus env:list $TERMINUS_SITE --field=id | grep -E '^pr-[0-9]+(-e2e)?$'))
	for multidev in "${multidevs[@]}"; do
		pr_id=$(echo "$multidev" | grep -oE '[0-9]+')
		state=$(gh pr view "$pr_id" --repo "$repo" --json state -q ".state")
		if [[ "$state" != "OPEN" ]]; then
			echo "PR #$pr_id ($multidev) is $state"
			terminus env:delete "$TERMINUS_SITE.$multidev" --yes
		fi
	done
}

_cleanup_multidevs_desc='deletes Pantheon multidevs that do not have an open PR'
_cleanup_multidevs_help='
Deletes Pantheon multidevs that do not have an open PR.

# Usage

```bash
uceap cleanup-multidevs
```

## Description

This command requires the `TERMINUS_SITE` environment variable to be set.

This command assumes your current working directory is a checkout of
corresponding GitHub repository, or that the GH_REPO environment variable isset.
'