# Internal Probity release runbook

This runbook prepares, verifies, and hands off `@kfitzpatrick/probity@1.10.1-kfitzpatrick.1`. Kevin reviews and performs repository pushes and package publication manually. The package must be published from the verified tarball; do not rebuild or repack at publication time.

## Agreed release contents

- Base: upstream commit `f9758ce9f8ea621e7004e92e60e748ee62e5f25c`.
- Selected change: Codex SDK/CLI 0.163.0, integrating commits `beca58b` and `5d8399d` by merge. Keep `main` unchanged.
- Branch: `internal/probity`.
- Package: `@kfitzpatrick/probity@1.10.1-kfitzpatrick.1`.
- Registry and tag: `https://npm.pkg.github.com`, `internal`.
- Install and import using `@kfitzpatrick/probity` directly. Do not use an npm alias or add a custom configuration-loader alias.
- Published package metadata omits `repository`. Preserve upstream attribution, source links, and the MIT license.
- CI validation only. No workflow publishes this package automatically.

## Credentials and registry routing

The publisher and consumer credentials are separate classic GitHub PATs. The publisher token needs `write:packages`; the consumer token needs `read:packages`. Store the publisher token in the macOS Keychain item with service `probity-packages-publish` and account `kfitzpatrick`. The publish script reads it only when Kevin explicitly supplies `--publish`.

For consumption, pass the read token through `NODE_AUTH_TOKEN`; use a temporary npm config so no credential is written to the repository or user npm configuration. For example:

```sh
umask 077
consumer_npmrc=$(mktemp)
trap 'rm -f "$consumer_npmrc"' EXIT
cat > "$consumer_npmrc" <<'NPMRC'
registry=https://registry.npmjs.org/
@kfitzpatrick:registry=https://npm.pkg.github.com
//npm.pkg.github.com/:_authToken=${NODE_AUTH_TOKEN}
NPMRC
NPM_CONFIG_USERCONFIG="$consumer_npmrc" npm view @kfitzpatrick/probity@1.10.1-kfitzpatrick.1 version
```

Check scope routing with the same isolated configuration (`npm config get @kfitzpatrick:registry`). Verify publisher token identity and Packages API access without printing the token. Do not use the publisher token for consumer checks. A routing check, token identity check, and dry run do not establish publication permission, package existence, or consumer access.

## Branch validation and local artifact

Run the repository checks on `internal/probity`:

```sh
npm ci
npm run checks
npm run build
```

The optional AI-backed integration tests require vendor authentication (`PROBITY_INTEGRATION_AI=1`) and are not part of this release check. Record that limitation rather than attempting them without the required credentials.

After review, commit the release changes. Build and pack from that commit:

```sh
release_dir=releases/1.10.1-kfitzpatrick.1
mkdir -p "$release_dir"
npm run build
npm pack --ignore-scripts --pack-destination "$release_dir"
```

Keep the generated, ignored artifact at:

```text
releases/1.10.1-kfitzpatrick.1/kfitzpatrick-probity-1.10.1-kfitzpatrick.1.tgz
```

Inspect the tarball contents and embedded `package/package.json`. Confirm the name/version, `bin.probity`, exported root/types/rules entry points, compiled files, README, and MIT license. Confirm `repository` is absent and that no development sources, tests, local credentials, or unrelated files are packed. Check the package's installed CLI and imports in a fresh temporary consumer project using the tarball path; install it as `@kfitzpatrick/probity` with no alias. Load a `probity.config.ts` that imports that package name, invoke `./node_modules/.bin/probity --version`, and pass a hook payload that exercises a rule decision. Import the root and `@kfitzpatrick/probity/rules` entry points directly as well.

Record the exact version, source commit, tarball path, SHA-256, and results in the release verification record beside the artifact. Use that record for the finalized source commit, checksum, exact commands, and checks; never derive the expected checksum from a replacement artifact. Verify the working tree and confirm `main` is unchanged.

## Push checkpoint

Only Kevin pushes. Once the reviewed local branch and changes are ready, Kevin may run:

```sh
git -C /Users/kevin.fitzpatrick/werk/probity.internal-probity push kfitzpatrick internal/probity
```

Expected effect: push the local `internal/probity` branch to the `kfitzpatrick` remote's branch of the same name. This does not change `main` or publish a package. Stop for Kevin's confirmation before relying on the pushed branch.

## Manual publication checkpoint

The publish script defaults to a dry run and requires the exact artifact, its previously recorded checksum, and version. After the tarball and verification record are finalized, Kevin should first review and run the dry run:

```sh
bash scripts/publish-internal-probity.sh \
  releases/1.10.1-kfitzpatrick.1/kfitzpatrick-probity-1.10.1-kfitzpatrick.1.tgz \
  <recorded-64-character-lowercase-sha256> \
  1.10.1-kfitzpatrick.1
```

The placeholder must be replaced with the checksum in the verification record. The dry run checks the exact tarball and does not read the Keychain token. After reviewing the dry-run output and artifact checksum, Kevin may publish those same bytes by adding `--publish` before the tarball path:

```sh
bash scripts/publish-internal-probity.sh --publish \
  releases/1.10.1-kfitzpatrick.1/kfitzpatrick-probity-1.10.1-kfitzpatrick.1.tgz \
  <recorded-64-character-lowercase-sha256> \
  1.10.1-kfitzpatrick.1
```

This is a manual action for Kevin. Do not invoke it on his behalf. Do not run `npm publish` separately or rebuild/repack between verification and publication.

## Checks after first publication

GitHub creates the package on first publication. In package settings, Kevin verifies visibility is **Private**, confirms there is no linked repository, and reviews user and Actions access. Grant only intended consumers `read` access. If linking the public source repository later, keep permission inheritance disabled and recheck access. A successful publish or npm dry run does not prove private visibility or correct access.

With the separate consumer token, verify exact-version metadata retrieval, install the package into a clean temporary project, load the config, and run the CLI. Verify denial using an authenticated account that does not have package access; anonymous failure alone is not evidence of private visibility. Record which checks require package existence or an authorized account.

Do not grant `spec-split-audit` workflow access as part of this release. That belongs to consumer issue #38 after its trusted workflow is reviewed. The follow-up should use `GITHUB_TOKEN` with `packages: read`, scoped to trusted jobs that do not execute untrusted contributor code.

## Consumer issue #38 handoff

Ready-to-use text for Kevin to post after publication (do not post automatically):

> The internal Probity package is `@kfitzpatrick/probity@1.10.1-kfitzpatrick.1` on `https://npm.pkg.github.com`. Install it directly under that package name; do not use a dependency alias. Import configuration helpers from `@kfitzpatrick/probity` and run the locally installed `probity` executable. The package is intended to be private; request `read` access from Kevin. CI access is deferred until the trusted workflow is reviewed, then should use a narrowly scoped `GITHUB_TOKEN` with `packages: read`.

## Switching back to upstream

Once upstream contains the required change, choose its exact released version,
remove `@kfitzpatrick/probity`, and install `@nizos/probity` with
`npm install --save-dev --save-exact @nizos/probity@<approved-upstream-version>`.
Change configuration imports back to `@nizos/probity` and keep project scripts
invoking the local `probity` binary. Regenerate and commit the consumer lockfile,
then verify its hook behavior. Remove the custom scope/token routing if that
project no longer needs GitHub Packages. Consumer changes belong to issue #38.

## References

- [GitHub npm registry and classic PAT authentication](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-npm-registry)
- [GitHub package visibility and access controls](https://docs.github.com/en/packages/learn-github-packages/configuring-a-packages-access-control-and-visibility)
