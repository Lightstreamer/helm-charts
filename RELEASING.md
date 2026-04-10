# Releasing a new chart version

This document describes how to publish a new version of the Lightstreamer Helm chart.

## Prerequisites

- Write access to the repository
- All changes merged to `main`
- `docker` on your PATH (for README regeneration)

## Steps

1. **Update [`charts/lightstreamer/Chart.yaml`](charts/lightstreamer/Chart.yaml)**:

   - **`version`** — the chart version. Bump it following [Semantic Versioning](https://semver.org/):
     - **patch** (e.g. `0.7.0` → `0.7.1`): bug fixes, documentation corrections
     - **minor** (e.g. `0.7.0` → `0.8.0`): new features, non-breaking changes
     - **major** (e.g. `0.7.0` → `1.0.0`): breaking changes
   - **`appVersion`** — the Lightstreamer Broker version. Update only when the chart targets a new Lightstreamer release.

2. **Regenerate the chart README** *(optional — the release workflow does this automatically)*:

   This uses [helm-docs](https://github.com/norwoodj/helm-docs) to regenerate `charts/lightstreamer/README.md` from `README.md.gotmpl` and `values.yaml`. Running it locally lets you review the changes before pushing.

   ```sh
   ./generate-docs.sh
   ```

3. **Update the CHANGELOG** — document the changes in the new version.

4. **Lint and validate** — verify the chart renders correctly:
   ```sh
   helm lint charts/lightstreamer
   helm template lightstreamer charts/lightstreamer
   ```

5. **Commit and push** to `main`:
   ```sh
   git add charts/lightstreamer/Chart.yaml charts/lightstreamer/README.md CHANGELOG.md
   git commit -m "Release <version>"
   git push
   ```

6. **Trigger the release workflow** — go to the GitHub repository:
   - Navigate to **Actions** → **Release Charts** (left sidebar)
   - Click the **Run workflow** dropdown
   - Select the `main` branch
   - Click **Run workflow**

7. **Verify the release** — once the workflow completes:
   - Pull the auto-generated README commit:
     ```sh
     git pull
     ```
   - A new GitHub release tagged `lightstreamer-<version>` should appear under **Releases**
   - The `gh-pages` branch `index.yaml` should be updated
   - Confirm the chart is available:
     ```sh
     helm repo update
     helm search repo lightstreamer/lightstreamer --versions
     ```

## How it works

The release workflow:

1. Regenerates the chart README via [helm-docs](https://github.com/norwoodj/helm-docs), committing any changes to `main`
2. Runs [`helm/chart-releaser-action`](https://github.com/helm/chart-releaser-action), which:
   1. Detects chart changes since the last release tag
   2. Runs `helm package` to produce a `.tgz` artifact
   3. Creates a GitHub release with the packaged chart attached
   4. Updates `index.yaml` on the `gh-pages` branch, which serves as the Helm repository at `https://lightstreamer.github.io/helm-charts`
