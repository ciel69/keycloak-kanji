---
inclusion: always
---

# Shared knowledge base — Kanji Flow

The shared knowledge base is an Obsidian vault that agents write as well as read. Its rules are
canonical there, not here: this note routes, the vault decides.

Current repository: `keycloak-kanji` — the ready-to-run Keycloak image (the kanji-flow login theme, the Telegram identity provider, the realm export).

## Read before changing behaviour

Read the base before: a new feature or spec, a change to user behaviour, an API, event, data,
integration, auth or security change, a migration, a cross-repository decision, or when the
documentation disagrees with the code.

Not needed for: formatting, linting, or a refactor that changes no behaviour.

Use the `obsidian-context` skill. It searches first (`search_hybrid`) and navigates only when
search fails — walking the README tree is the slowest and least reliable path in a base of 450+
notes.

## Write after the change is verified

Writing to the base is part of the task, not a separate approval. After tests or a build pass, use
the `obsidian-maintenance` skill when the change affects:

- the business description of a feature;
- an API, DTO, event, status or guard;
- a cross-system dependency;
- a discrepancy between a note and the code.

Where it goes:

| The change is | It goes to |
|---|---|
| the local implementation of `keycloak-kanji` (a login theme template, an identity provider, a realm attribute) | `Repositories/keycloak-kanji/` |
| a contract several systems share | `Engineering/20-Contracts/` |
| data, integrations, infrastructure, operations | the matching `Engineering/` section |
| the business meaning or a user scenario | `Wiki/` |
| a rule that applies to several repositories | `Standards/` |

Local implementation details live in the theme templates, the providers, the realm export.

The note contract is `Standards/Knowledge-Management/Note-Schema.md` in the vault. In short:
frontmatter with `type`, `description`, `status`, `owner`, `verified`, `sources`; a one-sentence
description of at most 200 characters that never ends in `…`; one entity per file; uncertainty in
`status_note`, not in a preamble above the answer.

## Statuses

`confirmed` is assigned only by the owner, never by an agent. `confirmed-by-agent` is assigned after
an autonomous reconciliation with code or sources, by `knowledge-base-curator` **or**
`knowledge-base-validator` — the right is tied to the type of check, not to one agent.

## Done means

1. The change is implemented and verified.
2. The affected notes are updated or created, and every business entity the change touched has a
   current `Wiki/` note.
3. `node tools/kb-lint.mjs` in the vault reports zero errors.
4. `knowledge-base-validator` has checked the changed notes.

Never store secrets, tokens, personal data or real environment values in the base. If the vault is
unreachable, say so — do not invent rules from code.

## Operon

The Operon queue of this repository is every vault task with `repo=keycloak-kanji`; use the
`operon-queue` skill only when the user asks for it.
