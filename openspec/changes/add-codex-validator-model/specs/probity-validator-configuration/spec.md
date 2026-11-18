# Probity Validator Configuration

## Purpose

Lets maintainers configure the model for a built-in validator independently of the host coding agent.

## ADDED Requirements

### Requirement: Optional Codex validator model

Probity SHALL accept an optional string at `validatorOptions.codex.model` for the built-in Codex validator.

#### Scenario: Explicit Codex model

- **WHEN** Probity runs with `--agent codex`, the configuration supplies a model ID, and no custom `ai` is configured
- **THEN** Probity requests that model for the validator session
- **AND** the host Codex session retains its own model

#### Scenario: Model is absent

- **WHEN** Probity uses the built-in Codex validator and the configuration omits the model
- **THEN** Probity starts the validator session without an explicit model and lets the SDK select its default

#### Scenario: Model is blank

- **WHEN** the built-in Codex validator would use an explicitly empty or whitespace-only model
- **THEN** Probity reports the invalid configuration and blocks the hook request

### Requirement: Built-in validator options apply to the selected host

Probity SHALL use only the built-in validator options for the host selected by `--agent`.

#### Scenario: Another host uses its default validator

- **WHEN** Probity runs with `--agent claude-code` and the configuration supplies only Codex validator options
- **THEN** Probity uses the built-in Claude Code validator with its current defaults

### Requirement: Custom validators take precedence

Probity SHALL use a configured `ai` validator in place of the built-in validator and its options. The CLI host still selects the hook adapter.

#### Scenario: Custom validator and Codex model are both configured

- **WHEN** Probity runs with `--agent codex` and the configuration supplies both `ai` and Codex validator options
- **THEN** Probity sends the rule prompt to the custom validator without creating a built-in validator session
- **AND** Probity reads the request and returns the decision in the Codex hook format
