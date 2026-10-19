# Probity — internal build

**Internal package:** `@kfitzpatrick/probity@1.10.1-kfitzpatrick.1`
**Registry:** GitHub Packages (`https://npm.pkg.github.com`)
**Visibility:** intended to be private; verify package access settings after first publication.

This internal build carries the selected Codex SDK/CLI 0.163.0 update on top of upstream Probity. It is installed directly under its own package name. Do not install it through an npm dependency alias. The existing upstream configuration-loader alias is preserved; no custom loader alias is added.

[Upstream project](https://github.com/nizos/probity) · [MIT license](https://github.com/nizos/probity/blob/main/LICENSE)

Probity forces AI coding agents to follow your rules. It hooks into your agent and checks every file write and shell command before it happens. When an action breaks a rule, Probity blocks it and tells the agent why.

You can use it to enforce Test-Driven Development with the built-in rule, block destructive commands, or keep unwanted patterns out of your code. Writing your own rules takes a few lines of TypeScript, and one config works across most coding agents.

The upstream project is featured on the [Modern Software Engineering channel](https://www.youtube.com/watch?v=bDLdZIAjH5Y), where Emily Bache and Nizar Selander discuss what TDD looks like when an agent writes the code. A separate [Q&A with factor10's Jimmy Nilsson](https://factor10.com/news/using-probity-to-enforce-tdd-guardrails-for-ai-coding-agents-q-and-a-with-nizar-selander/) covers using Probity on real projects and links the full kata run. The [upstream demo](https://github.com/nizos/probity/blob/main/docs/assets/probity-tdd-demo.gif) shows Probity enforcing TDD in a live agent session.

## How it works

When a rule is broken, the agent sees a reason and a path forward:

```text
Probity: you're adding production code before a failing test has been
observed.

The next TDD-legal step is to add one focused test in src/cart.test.ts
and run it to a clean assertion failure before implementing only the
minimum code to pass it.
```

The agent corrects course and continues.

Rules can be deterministic, matching commands or file content by string or regex, or AI-validated using official SDKs. Both kinds can read recent session activity, so actions are judged in context.

## Quick start

Configure npm to use GitHub Packages for this scope and the public npm registry for ordinary dependencies. For example, in the project `.npmrc`:

```ini
registry=https://registry.npmjs.org/
@kfitzpatrick:registry=https://npm.pkg.github.com
//npm.pkg.github.com/:_authToken=${NODE_AUTH_TOKEN}
```

Provide `NODE_AUTH_TOKEN` through your secret store using a classic GitHub PAT with `read:packages`. Do not commit the token or place it directly in `.npmrc`. Then install the exact version:

```bash
npm install --save-dev --save-exact @kfitzpatrick/probity@1.10.1-kfitzpatrick.1
```

Create `probity.config.ts` at your project root:

```ts
import { defineConfig, enforceTdd } from '@kfitzpatrick/probity'

export default defineConfig({
  rules: [
    {
      files: ['src/**', 'test/**'],
      rules: [enforceTdd()],
    },
  ],
})
```

Wire it into your agent using the [upstream setup guide](https://github.com/nizos/probity/blob/main/docs/setup.md). Your project scripts can invoke the locally installed `probity` executable:

```json
{
  "scripts": {
    "probity:claude": "probity --agent claude-code"
  }
}
```

Use `npm run --silent probity:claude` in the hook command so npm does not add output to the protocol. Replace upstream setup commands that invoke `npx @nizos/probity` with this local script.

The agent integration should pass its hook payload to `probity` on standard input. See the [upstream configuration guide](https://github.com/nizos/probity/blob/main/docs/configuration.md) and [rule reference](https://github.com/nizos/probity/blob/main/docs/rules.md).

## Built-in rules

- [`enforceTdd()`](https://github.com/nizos/probity/blob/main/docs/rules.md#enforcetdd): failing test first, minimal implementation, refactor on green
- [`forbidCommandPattern()`](https://github.com/nizos/probity/blob/main/docs/rules.md#forbidcommandpattern): block shell commands by pattern
- [`requireCommand()`](https://github.com/nizos/probity/blob/main/docs/rules.md#requirecommand): require a prior command (e.g. tests before commit)
- [`forbidContentPattern()`](https://github.com/nizos/probity/blob/main/docs/rules.md#forbidcontentpattern): block writes containing a pattern
- [`enforceFilenameCasing()`](https://github.com/nizos/probity/blob/main/docs/rules.md#enforcefilenamecasing): enforce a filename casing style

## FAQ

**Does it work with my agent?**
Probity currently works with Claude Code, Codex, and GitHub Copilot CLI, with more coming.

**Does it work with my language?**
Probity reads each agent's session transcript directly, so there are no per-framework reporters to install. It works with any language and test runner that your agent can work with.

**Does Probity need its own API key or subscription?**
No. AI-validated rules use each vendor's official SDK and reuse whatever authentication your agent already has, so Probity doesn't require its own access or billing.

**Does this cost extra tokens?**
AI-validated rules add a turn each time they check an action, so yes, some. Working in small TDD steps adds turns of its own, with or without Probity. Pattern-based rules add none.

**Does enforcing TDD with an agent guarantee good design?**
Not on its own. Probity keeps the agent on track: a failing test before the code, the minimum to pass it, refactoring on green. That removes a lot of handholding and prompt fatigue. The shape the implementation and the tests take is still yours to steer.

**I'm already using TDD Guard. Should I switch?**
Yes. Probity handles refactors and multi-step edits more reliably, is safe with parallel sessions, and supports more agents. See [Migrating from TDD Guard](https://github.com/nizos/probity/blob/main/docs/migrating-from-tdd-guard.md).

## Documentation and contributing

The upstream repository contains the [setup guide](https://github.com/nizos/probity/blob/main/docs/setup.md), [configuration guide](https://github.com/nizos/probity/blob/main/docs/configuration.md), [rule reference](https://github.com/nizos/probity/blob/main/docs/rules.md), [migration guide](https://github.com/nizos/probity/blob/main/docs/migrating-from-tdd-guard.md), and [contributing guidelines](https://github.com/nizos/probity/blob/main/CONTRIBUTING.md).

## License and attribution

Probity is an open-source project by Nizar Selander. This internal build preserves upstream attribution and is distributed under the [MIT license](https://github.com/nizos/probity/blob/main/LICENSE).
