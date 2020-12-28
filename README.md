# GitHub Release from Changelog Action

Action to create a GitHub release from a CHANGELOG file.

**NOTE**: This action requires `GITHUB_TOKEN` exported to the environment. See
below for an example.

## Inputs

### `tag`

**Optional** The tag to use for the release. Omit if triggering from a tag event.

### `filename`

**Optional** The changelog filename. Default searches across a range of
common changelog filenames.

## Outputs

### `release_url`

The GitHub release URL.

### `tag`

The tag used to create the release.

## Example usage

**NOTE**: Remember to add `GITHUB_TOKEN` via environment.

```yaml
on:
  push:
    tags:
      - "v*"
---
jobs:
  release_version:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Generate GitHub Release
        uses: lsegal/github-release-from-changelog-action@latest
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
