#!/bin/bash
# Publish a previously reviewed tarball. Defaults to a dry run.
# Requires macOS Keychain item: service=probity-packages-publish,
# account=kfitzpatrick, password=<GitHub classic PAT with write:packages>.
set -euo pipefail
set +x

usage() {
  cat <<'EOF'
Usage: bash scripts/publish-internal-probity.sh [--publish] TARBALL SHA256 VERSION

Example (dry run; replace the checksum with the recorded release checksum):
  bash scripts/publish-internal-probity.sh ./release.tgz <sha256> 1.10.1-kfitzpatrick.1

Add --publish to perform the manual publication after reviewing the dry run.
Obtain SHA256 from the release verification record, not a newly downloaded file.
The script never builds, repacks, or changes package permissions.

Before first publication, the tarball must omit repository metadata to avoid
automatic inheritance from the public source repository. After publishing,
verify Private visibility and user/Actions access in GitHub package settings.
Connect the source repository afterward only with inheritance disabled.
EOF
}

publish=false
if [[ "${1:-}" == "--publish" ]]; then
  publish=true
  shift
fi
if [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi
if [[ $# != 3 ]]; then
  usage >&2
  exit 2
fi

tarball=$1
expected_sha=$2
expected_version=$3
registry=https://npm.pkg.github.com

[[ -f "$tarball" ]] || { echo 'Tarball does not exist.' >&2; exit 1; }
[[ "$expected_sha" =~ ^[0-9a-f]{64}$ ]] || {
  echo 'Expected SHA256 must contain 64 lowercase hexadecimal characters.' >&2
  exit 1
}

# Stage the exact bytes to avoid publishing a source file changed after inspection.
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
chmod 700 "$stage"
cp "$tarball" "$stage/package.tgz"
actual_sha=$(shasum -a 256 "$stage/package.tgz")
actual_sha=${actual_sha%% *}
[[ "$actual_sha" == "$expected_sha" ]] || {
  echo 'Checksum mismatch; refusing publication.' >&2
  exit 1
}

tar -xOzf "$stage/package.tgz" package/package.json |
  node -e '
    let text = "";
    process.stdin.on("data", chunk => { text += chunk; });
    process.stdin.on("end", () => {
      const pkg = JSON.parse(text);
      function requireCondition(ok, message) {
        if (!ok) throw new Error(message);
      }
      requireCondition(pkg.name === "@kfitzpatrick/probity", "Unexpected package name");
      requireCondition(pkg.version === process.argv[1], "Unexpected package version");
      requireCondition(pkg.private !== true, "private:true prevents npm publication");
      requireCondition(!Object.hasOwn(pkg, "repository"),
        "Remove repository metadata before initial unlinked publication");
      requireCondition(pkg.bin?.probity === "dist/bin.js", "Unexpected CLI entry");
      requireCondition(pkg.publishConfig?.registry?.replace(/\/$/, "") ===
        "https://npm.pkg.github.com", "Missing or incorrect publish registry");
      requireCondition(!pkg.publishConfig?.access || pkg.publishConfig.access === "restricted",
        "Unexpected publish access setting");
      requireCondition(!pkg.publishConfig?.tag || pkg.publishConfig.tag === "internal",
        "Unexpected publish tag setting");
    });
  ' "$expected_version"

# Isolate npm configuration from the source checkout and per-user npm settings.
cat > "$stage/npmrc" <<'EOF'
registry=https://registry.npmjs.org/
@kfitzpatrick:registry=https://npm.pkg.github.com
//npm.pkg.github.com/:_authToken=${NODE_AUTH_TOKEN}
EOF
chmod 600 "$stage/npmrc"
cd "$stage"

echo "Verified @kfitzpatrick/probity@$expected_version"
echo "SHA256: $actual_sha"
echo "Registry: $registry; tag: internal"

if [[ "$publish" == true ]]; then
  NODE_AUTH_TOKEN=$(security find-generic-password \
    -s probity-packages-publish -a kfitzpatrick -w)
  [[ -n "$NODE_AUTH_TOKEN" ]] || { echo 'Keychain token is empty.' >&2; exit 1; }
  export NODE_AUTH_TOKEN
  NPM_CONFIG_USERCONFIG="$stage/npmrc" npm publish "$stage/package.tgz" \
    --registry="$registry" --tag=internal --ignore-scripts
  unset NODE_AUTH_TOKEN
  echo 'Published. Verify Private visibility and user/Actions access in GitHub now.'
else
  NODE_AUTH_TOKEN='' NPM_CONFIG_USERCONFIG="$stage/npmrc" \
    npm publish "$stage/package.tgz" --dry-run \
    --registry="$registry" --tag=internal --ignore-scripts
  echo 'Dry run only: no package was published and no Keychain token was loaded.'
fi
