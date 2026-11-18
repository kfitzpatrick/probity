# Design

## Context

Probity's CLI selects a vendor from `--agent`. It loads the configuration and chooses the validator with `config.ai ?? entry.agent()`. The Codex factory creates an SDK thread for each call to `reason(prompt)`. The pinned SDK, `0.163.0`, accepts an optional `ThreadOptions.model` and forwards it to the Codex CLI.

## Goals / Non-Goals

**Goals**

- Keep host selection separate from options for the validator.
- Preserve the built-in Codex validator's SDK defaults and sandbox options.
- Use the same configuration shape for later vendor extensions.

**Non-Goals**

- Vendor settings for Claude Code or GitHub Copilot, changes to the TDD prompt, and a shared model-selection policy are outside this change.
- SPE-36 owns the permanent dependency, hook pin, and configuration changes in spec-split-audit.

## Decisions

### Key validator options by host

```ts
validatorOptions: {
  codex: { model: "your-model-id" },
}
```

Add this shape to the public `Config` type. The CLI still requires `--agent` to select the hook adapter and transcript reader. Keep the `ai` short circuit before looking up built-in options. If the selected host has no applicable options, use its existing factory with its defaults.

A top-level `codexValidator` field gives Codex a short path. A vendor map gives future SDK options a common location. An exported factory such as `ai: codexValidator({ model })` gives the user direct control over which validator runs across hosts. This change keeps Probity's existing host-based selection.

### Forward the model at the SDK boundary

Pass the selected model to the existing Codex factory and include it in `startThread()` only when supplied. Leave the existing thread fields in place. Let the SDK handle model availability and use the existing violation path for SDK errors. A local list of supported model IDs would require updates as availability changes.

Planning assumption for explicit blanks. Reject an empty or whitespace-only string when the built-in Codex validator would start a thread with it. Use the existing violation path. Skip this check for unused vendor options and when `ai` takes precedence.

### Validator selection matrix

| `validatorOptions.codex.model` | `--agent codex` without `ai`                          | Other host without `ai`                  | Any valid host with `ai`   |
| ------------------------------ | ----------------------------------------------------- | ---------------------------------------- | -------------------------- |
| Omitted                        | Built-in Codex validator uses the SDK default         | Host uses its built-in default validator | Custom `ai` validator runs |
| Nonblank model ID              | Built-in Codex validator requests the model           | Host uses its built-in default validator | Custom `ai` validator runs |
| Empty or whitespace-only       | Probity blocks when the built-in Codex validator runs | Host uses its built-in default validator | Custom `ai` validator runs |

### Exercise TDD in the consuming project

Build and pack the fork. Prepare two identical copies of a disposable `spec-split-audit` checkout. In both copies, seed a Ruby stub under `lib/` that returns `nil` and an RSpec example that expects `add(2, 3)` to return `5`. Use the same Probity build, rules, host model, and explicit validator model.

In Trial A, leave the example unrun. In Trial B, run it in the Codex session and observe the assertion fail. Then submit the same patch in both sessions with the following request.

> Submit the supplied patch once for normal Probity review. Report the hook result.

Confirm that both submissions reach the real `PreToolUse` hook. Confirm that the validator prompt contains the failed assertion only in Trial B. Expect Probity to block Trial A and leave the stub unchanged. Expect Probity to allow Trial B, then rerun the example and confirm it passes.

A test double at `startThread()` proves forwarding. The live hook exercise supplies evidence of the resulting behavior.

### Match each hook verdict to its validator session

1. Enable Probity's `--debug` log in the trial hook. Run the trials one at a time. List the existing Codex session IDs immediately before each patch submission.
2. Find the `apply_patch` request in the Probity log for that trial. Record the TDD verdict, validator duration, and input and output token totals.
3. Search only the new Codex sessions. Match the target file path and exact patch section under `## Pending action` in the validator prompt.
4. Record the matched session ID, model, and cached input count with the hook verdict. If no session matches or several sessions match, mark the evidence incomplete and repeat the trial.

## Risks / Trade-offs

- A model alias can resolve differently from its configured name. Record both the requested model and the model in the validator session.
- A setup failure cannot demonstrate a TDD block. Record the hook response and verify that it came from the TDD validator.
- The OpenSpec root is in Probity. Run the implementation there and use a separate disposable spec-split-audit checkout for the live trial.

## Migration Plan

Prepare a consumable build from the fork and try it in the disposable checkout. Existing consumers can continue to omit `validatorOptions`. To restore the SDK default in a consumer, remove the model setting. Bring the working configuration and hook results upstream after using the feature in spec-split-audit.
