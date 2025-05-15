function cleanup_multidevs() {
	_terminus_login
	multidevs=($(terminus env:list $TERMINUS_SITE --field=id | grep -E '^pr-[0-9]+$'))
	for pr in "${multidevs[@]}"; do
		pr_id=${pr#pr-}
		state=$(gh pr view "$pr_id" --repo "$repo" --json state -q ".state")
		if [[ "$state" != "OPEN" ]]; then
			echo "PR #$pr is $state"
			terminus env:delete "$TERMINUS_SITE.$pr" --yes
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