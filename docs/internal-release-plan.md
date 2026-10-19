# Issue #7: Private internal Probity release plan

Status: implementation approved on 2026-10-19; preparing an unpublished release.

Issue: https://github.com/kfitzpatrick/probity/issues/7

Consumer issue: https://github.com/kfitzpatrick/spec-split-audit/issues/38

## Approved execution decisions (2026-10-19)

- Reuse `/Users/kevin.fitzpatrick/werk/probity.internal-probity` on
  `internal/probity`, initially clean at `0ace932`.
- Upstream baseline and unchanged local `main`:
  `f9758ce9f8ea621e7004e92e60e748ee62e5f25c`.
- Kevin approved the Codex SDK and bundled CLI update to `0.163.0`.
  Integrate `beca58b` and `5d8399d` from `codex/issue-87-upstream`, retaining
  the committed plan (`323b8c1`) and manual publisher (`0ace932`). Older
  text-block, array-output, and Copilot argument fixes are already upstream.
- Package: `@kfitzpatrick/probity@1.10.1-kfitzpatrick.1`, registry
  `https://npm.pkg.github.com`, tag `internal`.
- Keep the upstream `@nizos/probity` development dependency for repository
  dogfooding/tests. It is not a runtime dependency of the internal package.
- See [the release runbook](internal-release.md) for manual checkpoints.
  The final artifact record is generated alongside the retained tarball in
  ignored `releases/1.10.1-kfitzpatrick.1/` after committing and validating.

## Objective and boundaries

Prepare an unpublished, verified `@kfitzpatrick/probity` release on
`internal/probity` for Kevin and his agents. Keep `main` aligned with upstream
and free of internal patches and publishing configuration. Kevin publishes
manually after reviewing the prepared release.

Consumers install the exact custom version locally under its own name,
`@kfitzpatrick/probity`, and import that name in their configuration. Do not use
an npm dependency alias to install it as `@nizos/probity`. Preserve upstream's
existing configuration-loader alias without adding a custom alias; local
installation is the supported setup for the internal build.

Do not publish, change live package permissions, modify the consumer repository,
or post to either issue as part of implementation. Post-publication work below
is a separate follow-up after Kevin publishes.

All repository pushes are manual learning checkpoints for Kevin. Prepare and
verify local changes, then stop before each push and provide the exact command,
remote, branch, and expected effect for Kevin to execute. Wait for confirmation
before continuing work that depends on that push. Never run `git push` on
Kevin's behalf. Package publication is likewise a manual checkpoint: provide
the verified artifact and command, then wait for Kevin to publish it.

## Known prerequisites and open decisions

- Kevin has created publisher and consumer tokens. Authentication and scopes
  have not yet been verified.
- Local npm authentication uses classic PATs. Use package-only scopes:
  `write:packages` for publication and `read:packages` for consumption.
- GitHub hosts the registry at `https://npm.pkg.github.com`; no registry server
  needs provisioning. The package is created by its first publication.
- Package visibility and access settings can only be verified after publication.
- The inspected workspace has Node `22.14.0` and npm `10.9.2`, satisfying the
  project's Node >=22 requirement.
- At inspection, the checkout was clean and detached at `7746e0d`, package
  metadata was `@nizos/probity@1.10.1`, and `internal/probity` was absent from
  available refs. Recheck these facts before implementation.
- Decide the upstream baseline and intended custom patch set before integration.
- Proposed version: `1.10.1-kfitzpatrick.1`, subject to baseline and availability.

## Work section 1: Verify credentials and npm routing

Owner: primary agent, with Kevin supplying credentials through his environment.

Dependencies: implementation approval; tokens already created.

Tasks:

1. Verify `@kfitzpatrick` maps to `https://npm.pkg.github.com` while ordinary
   dependencies continue to use `https://registry.npmjs.org/`.
2. Verify the configured token's identity and Packages API access without
   printing or committing credentials.
3. Keep publisher credentials separate from read-only consumer credentials.
4. Record which checks remain impossible before the package exists. API access
   and dry runs do not establish publication or package installation permission.

Completion: routing and authentication are verified, with remaining checks
explicitly recorded.

## Work section 2: Inventory patches and packaging in parallel

Dependencies: implementation approval. Can run alongside work section 1.

| Subagent        | Model        | Effort | Focus and deliverable                                                                                                                                                  |
| --------------- | ------------ | ------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Patch inventory | `gpt-6-luna` | medium | Compare upstream and fork branches; identify candidate custom commits, dependencies, and selection ambiguities. Return a recommended baseline and explicit patch list. |
| Packaging audit | `gpt-6-luna` | medium | Inspect CLI, exports, compiled files, lockfile, license, and workflows. Return required changes and concrete verification commands.                                    |

These bounded inspections use the least expensive suitable model. Give each
agent focused context rather than a full-history fork. The primary agent checks
both reports and resolves disagreements. If the inventory reveals nontrivial
merge history, uncertain patch dependencies, or complex debugging, assign that
focused analysis to `gpt-6.1-sol` with high reasoning effort. Routine inventory
and checks stay on Luna. Disclose any unavailable-model substitution.

Completion: a reviewed patch inventory and packaging checklist. Resolve material
ambiguity about intended custom behavior with Kevin before applying those patches.

## Work section 3: Establish the internal branch

Owner: primary agent.

Dependencies: work section 2's baseline and patch selection.

Tasks:

1. Record the starting `main` commit before making changes. Inspect Git
   status, available refs, and worktree ownership. Preserve the plan,
   publish script, and any other existing local work.
2. Create or reuse `internal/probity` from the agreed baseline. If that
   branch is checked out in another worktree, inspect its purpose before
   choosing where to work; do not reset or overwrite it.
3. Apply the selected custom patches and record their provenance.

Completion: the internal branch contains the intended patches and an explicit
upstream baseline; `main` has not changed.

## Work section 4: Prepare package metadata and branch validation

Owner: primary agent.

Dependencies: work sections 2 and 3.

Tasks:

1. Set the package name to `@kfitzpatrick/probity` and choose a unique exact
   version; synchronize manifest and lockfile.
2. Configure GitHub Packages as the publication registry and add credential-free
   scope routing where appropriate. Do not use `private: true` as a visibility
   control, because it prevents npm publication.
3. Omit the `repository` field from the published package metadata so the
   first publication does not automatically link to the public repository.
   Preserve source links and upstream attribution in the README and license.
4. Preserve the `probity` CLI, exported entry points, required compiled files,
   upstream attribution, and MIT license.
5. Add CI validation for `internal/probity`. Current CI targets `main`; the
   upstream canary workflow is guarded for `nizos/probity` on `main`.
6. Ensure internal validation does not publish automatically.

Completion: package configuration is consistent, correctly routed, and ready
for validation on the internal branch.

## Work section 5: Write the manual release runbook

Owner: documentation subagent, `gpt-6-luna`, medium reasoning effort.

Dependencies: agreed package contract from work section 2. Run in parallel with
work section 4, editing a separate documentation file to avoid conflicts.

Tasks:

1. Document build, checks, tarball inspection, and exact-version local
   installation under `@kfitzpatrick/probity`. Show configuration imports
   using that name and project scripts invoking the locally installed
   `probity` executable. Update the packaged README accordingly.
   Document switching the dependency, imports, and lockfile back to upstream
   after the custom patches are merged.
2. Document environment-based authentication without stored credentials.
3. Provide Kevin's exact manual publication commands once version and artifact
   details are finalized.
4. Explain private visibility, independent package permissions, intended readers,
   and trusted Actions access.
5. Provide post-publication metadata, installation, CLI, and denied-access checks.
6. Include the exact package/version/registry handoff for consumer issue #38.

Completion: the primary agent verifies the runbook against the implemented
configuration and actual verification results.

## Work section 6: Validate the unpublished artifact

Owner: primary agent; delegate narrow independent checks to `gpt-6-luna` only
when doing so materially improves speed or quality.

Dependencies: work section 4; integrate work section 5 before final review.

Tasks:

1. Install dependencies and run the repository's required checks and build.
2. Distinguish checks requiring external credentials from locally runnable checks;
   report any unverified integration behavior.
3. Pack and inspect the tarball for compiled files, exports, CLI executable,
   license, attribution, and unintended contents.
4. Install the tarball locally as `@kfitzpatrick/probity` into a temporary consumer
   project. Load a project configuration importing that name and verify an actual
   CLI rule decision, as well as exported entry points. Use no npm dependency
   alias and make no configuration-loader alias changes.
5. Commit the reviewed release changes and verify the working tree has no
   unexplained changes. Build and pack from that commit. Retain the tested
   tarball and record its exact version, source commit, checksum, and check
   results. Kevin's manual publication command must publish that exact
   tarball after verifying its checksum.
6. Verify `main` is unchanged and internal changes are confined to the intended
   branch. Recheck the documentation after any corrective changes.

Completion: a tested unpublished artifact with evidence and explicit limitations.

## Work section 7: Deliver the manual publication handoff

Owner: primary agent.

Dependencies: work sections 1, 5, and 6. Confirm registry routing and
authentication are still valid before handing Kevin the publication command.
Record that publication permission and package access remain unverified
until publication and the checks in section 8.

Deliverables:

- Reviewable final diff and baseline/custom patch inventory.
- Exact package version, registry, source commit, and tarball checksum.
- Validation results and any remaining limitations.
- Manual publication and post-publication access checklist.
- Ready-to-use handoff text for consumer issue #38; do not post it automatically.

Completion: Kevin can review and manually publish the prepared artifact. Stop
implementation here without publishing.

## Work section 8: Verify the published package and consumer access

Owner: Kevin for publication and live settings; primary agent for subsequently
authorized verification.

Dependencies: Kevin manually publishes the reviewed artifact.

Tasks:

1. Confirm package visibility is Private, no repository is linked, and no
   unintended user or Actions access exists. Configure access independently.
   Optionally connect the public source repository afterward, keeping permission
   inheritance disabled, and recheck user and Actions access.
2. Grant only intended consumers read access.
3. Use a consumer token to retrieve exact-version metadata, install the package,
   and execute its CLI in a fresh temporary project.
4. Verify an authenticated account without package access cannot retrieve it.
   Anonymous failure alone does not prove private visibility.
5. Defer `spec-split-audit` Actions access until its trusted workflow is reviewed.
   Use `GITHUB_TOKEN` with `packages: read`, and keep access out of jobs executing
   untrusted contributor code.
6. Supply finalized registry and version details for issue #38. Consumer changes
   and trusted CI verification belong to that separate integration task. Flag
   that this plan selects direct local installation under the custom package
   name rather than the dependency-alias option mentioned in the consumer issue;
   reconcile that difference during the consumer task.

Completion: private visibility and authorized/unauthorized access are verified;
consumer integration has a precise dependency handoff.

## Reference documentation

- [GitHub npm registry and authentication](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-npm-registry)
- [Package visibility, inheritance, and Actions access](https://docs.github.com/en/packages/learn-github-packages/configuring-a-packages-access-control-and-visibility)
- [GitHub Packages permissions](https://docs.github.com/en/packages/learn-github-packages/about-permissions-for-github-packages)
