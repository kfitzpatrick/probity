# Configuration

Probity loads its config from a `probity.config` file in your project. The file declares the active rules and can configure the AI validator.

## File location

Probity looks for a `probity.config` file at your project root, walking up from the current directory. Supported extensions are `.ts`, `.mts`, `.js`, and `.mjs`. If none is found, probity fails closed and the action is blocked.

```ts
// probity.config.ts
import { defineConfig, enforceTdd } from '@nizos/probity'

export default defineConfig({
  rules: [
    {
      files: ['src/**', 'test/**'],
      rules: [enforceTdd()],
    },
  ],
})
```

Globs inside a `files` array are anchored against the config file's directory, so `'src/**'` matches files under `<config-dir>/src/` regardless of where the agent's session is rooted. Two patterns are kept as-authored:

- `**`-prefixed globs (`'**/*.ts'`) are intentional "match anywhere" patterns and skip anchoring.
- Negations (`!src/legacy/**`) anchor the path inside the `!`; the leading `!` is preserved.

See [Rules](rules.md) for the built-in catalog.

## Codex validator model

Set `validatorOptions.codex.model` to choose the model for the built-in Codex validator.

```ts
// probity.config.ts
import { defineConfig, enforceTdd } from '@kfitzpatrick/probity'

export default defineConfig({
  rules: [enforceTdd()],
  validatorOptions: {
    codex: { model: 'your-model-id' },
  },
})
```

The `--agent` flag selects the host adapter and its built-in validator. Probity reads `validatorOptions.codex` only for the built-in validator selected by `--agent codex`. The host Codex session uses its own model.

If you omit the model, the Codex SDK chooses its default. If the built-in Codex validator receives an empty or whitespace-only model, Probity blocks the request before it starts a validator session.

## The `ai` override

Set `ai` in the config to use a custom validator. The value must implement `{ reason: (prompt: string) => Promise<Verdict> }`.

If you set `ai`, Probity uses the custom validator and skips the built-in validator options. The `--agent` flag still selects the host adapter.

## Overriding the file location

Pass `--config` to point probity at a specific file instead of using walk-up resolution:

```
probity --agent claude-code --config ./tooling/probity.config.ts < payload.json
```

The path is resolved against the current working directory.

## Custom rules

A rule is a function from action and context to result. Listed flat in `rules`, it runs against every action (writes and commands) and self-filters; wrapped in a `{ files, rules }` block, the `files` glob narrows writes by path.

```ts
// probity.config.ts
import { defineConfig, type Rule } from '@nizos/probity'

const noTodoComments: Rule = (action) => {
  if (action.kind !== 'write') return { kind: 'pass' }
  if (!action.content.includes('TODO')) return { kind: 'pass' }
  return {
    kind: 'violation',
    reason: 'Open a tracking issue instead of leaving a TODO.',
  }
}

export default defineConfig({
  rules: [noTodoComments],
})
```

Action shapes:

- `{ kind: 'write'; path: string; content: string }` — `path` is absolute POSIX.
- `{ kind: 'command'; command: string }` — shell command text.

Return shapes:

- `{ kind: 'pass' }` to allow the action.
- `{ kind: 'violation'; reason: string }` to block. The reason is surfaced back to the agent.

The optional second argument carries the engine's context:

- `ctx.agent?.reason(prompt)` — the AI validator the engine wired up (the `ai` override or the vendor's default). Use this for LLM-judged rules. Returns `Promise<Verdict>`.
- `ctx.history?()` — an async function returning the recent session as a list of canonical `SessionEvent`s (`prompt`, `command`, `write`, or `other`). May be undefined when the vendor adapter doesn't supply transcript access. Call it on demand, since reading the transcript can be slow.
- `ctx.rawHistory?()` — same shape but vendor-faithful: `RawSessionEvent`s preserve the original tool name and input. Use this when a rule needs vendor fidelity (e.g. AI-judged rules that build a transcript-like prompt).
- `ctx.readFile?(path)` — an async function returning a `FileContent`: `present` with content, `absent` for missing files, or `unknown` when the engine couldn't safely read (symlink, oversize, or I/O error).

Rules can be sync or async; the engine awaits the result either way.
