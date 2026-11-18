# Proposal

## Why

The spec-split-audit maintainer needs to compare Codex validator models independently of the model that proposes edits. The built-in validator currently leaves the model choice to the SDK.

## What Changes

- Add optional `validatorOptions.codex.model` to Probity's TypeScript configuration. Pass the configured model to the built-in Codex validator.
- Use the existing SDK default when the model is absent. Use the existing host selection and honor a custom `ai` validator first.
- Build a package for the maintainer to try. Use an independent TDD exercise through the real Codex hook to gather evidence for an upstream proposal.

## Capabilities

### New Capabilities

- `probity-validator-configuration` covers options for Probity's built-in validators, starting with Codex model selection.

### Modified Capabilities

## Impact

OpenSpec planning lives in this Probity checkout. The implementation target is `kfitzpatrick/probity:internal/probity`. The package needs no SDK upgrade.

SPE-36 tracks adoption in spec-split-audit. The independent TDD exercise supplies the acceptance evidence for this feature. The Claude Code and GitHub Copilot implementations have their own follow-up stories. [SPE-34](https://linear.app/spec-split-audit/issue/SPE-34/add-an-optional-codex-ai-validator-model-to-the-probity-fork) · [SPE-36](https://linear.app/spec-split-audit/issue/SPE-36/integrate-the-probity-validator-model-option-in-spec-split-audit) · [SPE-38](https://linear.app/spec-split-audit/issue/SPE-38/add-an-optional-claude-code-validator-model-to-probity) · [SPE-37](https://linear.app/spec-split-audit/issue/SPE-37/add-an-optional-github-copilot-validator-model-to-probity)
