A docker image supporting [GitHub Codespaces](https://github.com/features/codespaces) and [local devcontainers](https://containers.dev) for UCEAP Drupal projects, based on [Microsoft's PHP image](https://github.com/devcontainers/images/tree/main/src/php).

Refer to the UCEAP Software Engineering Playbook for more information on how to [setup your development environment](https://itse-playbook.uceap.work/fundamentals/setup-your-development-environment/).


## Helper script

This image includes a helper script that provides several commands to support features offered by this container. There are three main types of commands:

- __deploy-*__: perform deployments to various environments
- __devcontainer-*__: implementations of devcontainer lifecycle hooks
- _all others_: functionality to support the local developer experience

To see a list of available commands, run `uceap` in the terminal. You can also run `uceap help <command>` to see more information about a specific command.

## Tips and tricks

I frequently invoke `uceap refresh-content` to reset my local environment after switching branches. It runs `composer install` and invokes `db-rebuild.sh` with a fresh copy of the latest snapshot of the dev environment database and files. With shell completions installed, it's as easy as `uce<TAB>r<TAB>`.

> 👉 When working on a PR that adds update hooks or makes config changes, it's generally a good idea to make sure it applies cleanly to a database matching the QA environment. To do this, switch to the `qa` branch, run refresh-content, switch back to your branch, and run the deploy command (e.g. `drush md` for the portal):
> ``` zsh
> git checkout qa
> uceap refresh-content
> git checkout -
> composer install
> drush deploy
> ```

Troubleshooting an issue on the live site? `TERMINUS_ENV=live uceap refresh-content` will pull the latest backup of the database and files from LIVE. _You'll be knee-deep in PII in no time!_ **Be sure to reset your database and files with DEV data as soon as you're done.**

Sometimes a process can die or port forwarding can fail. `uceap devcontainer-post-start` runs a few commands that should get things working again. (Again, shell completion makes this `uce<TAB>sta<TAB>`).

Using devcontainers facilitates treating local environments as ephemeral: they're quick and easy to set up. Treat them as safe to destroy because you can always create a new one (or multiple new ones, to suit your needs). One thing you might miss is your shell history. Check out [Atuin](https://atuin.sh/) to sync your shell history across environments. `Control-R` has never looked so good 😎

## Personalization

Devcontainers support dotfiles!

See the [GitHub documentation](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles) for more info, and check out [Brandt's personal dotfiles](https://github.com/kurowski/dotfiles) for an example.

Visual Studio Code users should also look into the settings available in the Dev Containers extension, such as [Default Extensions](vscode://settings/dev.containers.defaultExtensions) to automatically install your favorite extensions in devcontainers.
