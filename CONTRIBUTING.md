# Contributing

This repo produces a **base image use by downstream Drupal projects** (e.g. [myeap2](https://github.com/UCEAP/myeap2)), which reference it in their `.devcontainer/docker-compose.yml`. The scripts here run as devcontainer lifecycle hooks (`uceap devcontainer-on-create`, etc.), so the most meaningful test is **rebuilding a real project's devcontainer against your changes** — that's the only path that exercises the hooks the way users hit them.

## Test inside a Drupal project

Build the image locally with a recognizable tag (first build ~5 min; cached rebuilds are near-instant):

```bash
docker build -t local/devcontainer-drupal:test .
```

Then in the Drupal project (e.g. myeap2), point its image at your local tag and rebuild the devcontainer:

```diff
 services:
   drupal:
-    image: "ghcr.io/uceap/devcontainer-drupal:main"
+    image: "local/devcontainer-drupal:test"
```

> Pushing the PR also publishes `ghcr.io/uceap/devcontainer-drupal:pr-<n>` automatically, which you can point at instead — but that round-trip through CI is slower than building locally.

## Isolated testing

You can enter the container by itself:
```bash
docker run --rm -it local/devcontainer-drupal:test bash
```
Then run commands inside the container:
```bash
uceap help
```
But you'll of course be missing any actual code and data to test with.
