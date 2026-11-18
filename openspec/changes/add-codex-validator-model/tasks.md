# Tasks

## 1. Configure the built-in Codex validator

- [ ] 1.1 Add the optional `validatorOptions.codex.model` field and wire it through the host selection to `startThread()`. Start with a failing focused test that captures the configured model at the SDK boundary.
- [ ] 1.2 Cover omitted model settings with focused tests for a missing configuration object and an empty Codex options object. Confirm that the SDK receives the existing thread options without a `model` property.
- [ ] 1.3 Reject explicit blank models at the active Codex validator. Confirm that a focused test sees a block through the existing violation path before any SDK thread starts.
- [ ] 1.4 Test host selection and custom `ai` precedence in the CLI with both a nonblank and a blank Codex model. Confirm that `--agent claude-code` uses its built-in default. Confirm that with `--agent codex` and custom `ai`, the custom validator receives the prompt and no built-in Codex thread starts.
- [ ] 1.5 Document the configuration example and host lookup in the fork's configuration guide. Confirm that the example uses the public configuration type and run the fork's standard checks.

## 2. Try the package through the Codex hook

- [ ] 2.1 Build and pack the fork. Install the package in a disposable spec-split-audit checkout and confirm that the hook runs the expected package build.
- [ ] 2.2 Seed the same Ruby stub and RSpec example in both disposable checkouts before starting the Codex sessions. Confirm that both trials use the same package, rules, host model, validator model, and patch.
- [ ] 2.3 Leave the example unrun in Trial A and submit the patch with the request in the design. Confirm that the hook runs, the validator prompt contains no observed assertion failure, and Probity blocks the patch without changing the stub.
- [ ] 2.4 Run the example in Trial B and observe its assertion failure. Submit the same patch with the same request. Confirm that the hook runs, the validator prompt contains the failure, and Probity allows the patch. Rerun the example to observe a pass.
- [ ] 2.5 Use the matching procedure in the design to pair each hook verdict with exactly one validator session. Record the patch, configuration, session ID, requested and recorded models, verdict, duration, and token usage for each trial. Identify the source of each field and accept only unambiguous matches.

## Workflow follow-up

- Use SPE-36 for permanent adoption in spec-split-audit. Bring the working example and live results upstream after the maintainer tries the feature.
