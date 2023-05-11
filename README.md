# Tauri in a Docker container

This is a custom Docker image for [Tauri](https://tauri.app/).

## Usage

### Github Actions

```yaml
- name: Run Docker container
  uses: addnab/docker-run-action@v3
  with:
    image: ghcr.io/zanzythebar/tauridocker:latest
    options: -v ${{ github.workspace }}/some_dir:/workspace
    run: |
      export NODE_VERSION=16.13.0
      mkdir build
      echo "::group::install node dependencies"
      npm install -g pnpm
      npm install -g typescript
      pnpm install
      echo "::group::tauri build"
      pnpm tauri build 
      echo "::endgroup::"
- name: Verify build
  run: |
    ls -la build
```

```yaml
- name: Checkout repository
  uses: actions/checkout@v3
  with:
    token: ${{ env.GITHUB_TOKEN }}
- name: Build the App (Linux)
  if: matrix.platform == 'ubuntu-latest'
  uses: addnab/docker-run-action@v3
  with:
    image: ghcr.io/zanzythebar/tauridocker:latest
    options: -v ${{ github.workspace }}:/workspace
    run: |
      echo "::group::install node dependencies"
      npm install -g pnpm
      npm install -g typescript
      pnpm install
      echo "::group::tauri build"
      pnpm tauri build
      echo "::endgroup::"
- name: Archive the App (Linux)
  if: matrix.platform == 'ubuntu-latest'
  uses: actions/upload-artifact@v3
  with:
    name: production-files
    path: |
      src-tauri/target/release/bundle/deb/*.deb
      src-tauri/target/release/bundle/appimage/*.AppImage
    retention-days: 5
    if-no-files-found: error
- name: Verify build (Linux)
  if: matrix.platform == 'ubuntu-latest'
  run: |
    ls -la src-tauri/target/release/bundle/appimage
    ls -la src-tauri/target/release/bundle/deb
```

### Docker

```bash
docker run --name tauridocker -v ~/app:/workspace ghcr.io/zanzythebar/tauridocker:latest
```

> **Note**: Volume mounting is currently in development and may not work as expected. Please make a `pr` if you find any issues.

Alternatively you could use a data volume container to save the some configurations. First create the data volume container. You can use other docker images for this, or mount directories from the system.

### Example

```bash
docker run --name vc_tauridocker zanzythebar/vc_tauridocker:latest
```

Then add the following line to the docker run call:

```bash
--volumes-from=vc_tauridocker \
```
