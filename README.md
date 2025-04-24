A docker image supporting [GitHub Codespaces](https://github.com/features/codespaces) and [local devcontainers](https://containers.dev) for UCEAP Drupal projects, based on [Microsoft's PHP image](https://github.com/devcontainers/images/tree/main/src/php).

Refer to the UCEAP Software Engineering Playbook for more information on how to [setup your development environment](https://itse-playbook.uceap.work/fundamentals/setup-your-development-environment/).

## Personalization

Devcontainers support dotfiles!

See the [GitHub documentation](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles) for more info, and check out [Brandt's personal dotfiles](https://github.com/kurowski/dotfiles) for an example.

Visual Studio Code users should also look into the settings available in the Dev Containers extension, such as [Default Extensions](vscode://settings/dev.containers.defaultExtensions) to automatically install your favorite extensions in devcontainers.

## Quality of life

This image includes several scripts that integrate with the devcontainer lifecycle, but these can also be used independently:

* `/usr/local/bin/uceap-drupal-dev-on-create`
* `/usr/local/bin/uceap-drupal-dev-post-create`
* `/usr/local/bin/uceap-drupal-dev-post-start`
* `/usr/local/bin/uceap-drupal-dev-update-content`

It also includes one that doesn't fit into the devcontainer lifecycle, but performs similar tasks:

* `/usr/local/bin/uceap-drupal-dev-refresh-content`

I frequently invoke `uceap-drupal-dev-refresh-content` to reset my local environment after switching branches. It runs `composer install` and invokes `db-rebuild.sh` with a fresh copy of the latest snapshot of the dev environment database and files. With zsh completions installed, it's as easy as `dev-re<TAB>`.

> 👉 When working on a PR that adds update hooks or makes config changes, it's generally a good idea to make sure it applies cleanly to a database matching the QA environment. To do this, switch to the `qa` branch, run refresh-content, switch back to your branch, and run the deploy command (e.g. `drush md` for the portal):
> ``` zsh
> git checkout qa
> uceap-drupal-dev-refresh-content
> git checkout -
> composer install
> drush $DRUSH_TASK
> ```

Sometimes a process can die or port forwarding can fail. `uceap-drupal-dev-post-start` runs a few commands that should get things working again. (Again, zsh shell completion makes this `post-s<TAB>`).

Using devcontainers faciliates treating local environments as ephemeral: they're quick and easy to setup. Treat them as safe to destroy because you can always create a new one (or multiple new ones, to suit your needs). One thing you might miss is your shell history. Check out [Atuin](https://atuin.sh/) to sync your shell history across environments. `Control-R` has never looked so good 😎
