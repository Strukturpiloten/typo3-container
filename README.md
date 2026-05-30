# TYPO3 Container Images

This repository contains the container image recipes for the Strukturpiloten TYPO3 runtime, installer, and manager images.

## Published Images

| Image | Purpose |
| --- | --- |
| `ghcr.io/strukturpiloten/typo3-phpfpm` | TYPO3 PHP-FPM runtime image with TYPO3 extensions and container utilities |
| `ghcr.io/strukturpiloten/typo3-installer` | TYPO3 installer image with TYPO3 CLI tooling and container utilities |
| `ghcr.io/strukturpiloten/typo3-manager` | TYPO3 manager image with TYPO3 CLI tooling, cron support, and container utilities |

All images are built for `linux/amd64` and `linux/arm64` by `.github/workflows/publish-images.yml`.

## Tag Policy

The workflow publishes these tags:

- `latest`, for the current default branch build
- `main`, for the current `main` branch build
- `sha-<commit>`, for an immutable build tied to a Git commit
- `vX.Y.Z`, `X.Y.Z`, `X.Y`, and `X`, for releases created from Git tags like `v1.2.3`

Use SemVer Git tags for intentional releases of this container project. The SemVer version describes the image recipe and release policy in this repository, not the TYPO3, PHP, or Alpine version inside the image. For production deployments, prefer a SemVer tag or an image digest over `latest`.

## Rebuild Policy

Images are rebuilt and published when container-related files change on `main`, when a release tag is pushed, on manual dispatch, and on a daily scheduled build. Scheduled and manual builds run without cache so remote package updates from `apk`, PHP extension builds, and remote release assets are picked up even when no file in this repository changed.

## Update Policy

The PHP-FPM base image is pinned by digest in `.env.tmpl` and should be updated by Renovate. Prefer pinned external release assets over `latest` URLs. If an external source cannot be pinned cleanly, keep the scheduled no-cache rebuild enabled.

## Reusing The Workflow

To reuse the workflow in another container repository:

1. Copy `.github/workflows/publish-images.yml`.
2. Adjust the matrix entries for the image names, Dockerfile paths, OCI titles, and OCI descriptions.
3. Adjust the build arguments and the values read from the repository configuration files.
4. Keep the SemVer tags, SHA tags, scheduled rebuild, digest-pinned base image updates, and OCI metadata.
