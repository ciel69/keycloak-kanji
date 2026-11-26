---
name: obsidian-maintenance
description: Updates the shared Kanji Flow Obsidian documentation after verified development and a change to business behavior, contracts, architecture or local implementation.
---

# Documenting changes in Obsidian

Current repository: `keycloak-kanji` — the ready-to-run Keycloak image (the kanji-flow login theme, the Telegram identity provider, the realm export).

## Preconditions

1. Run `obsidian-context` for the area you touched.
2. Check the actual diff and the verification result.
3. Separate the implemented fact from a proposal or a plan.
4. Choose the root by the routing rule below, not by remembered paths.

## Where to write

- Business meaning and user behaviour → `Wiki/`, as `draft` / `needs-review` when the product
  owner has not confirmed it. Absence of approval does not block the draft write.
- A business entity with no note at all → create the atomic note, not a paragraph inside a
  repository card.
- A cross-system contract → `Engineering/20-Contracts/`; data, integrations, infrastructure and
  operations → the matching `Engineering/` section.
- Local implementation of `keycloak-kanji` → `Repositories/keycloak-kanji/`.
- A rule applying to several repositories → `Standards/`.

A README is an index. Put the knowledge in a uniquely named note; update the README only when a link
changed.

## What the note must contain

Follow `Standards/Knowledge-Management/Note-Schema.md` in the vault. The minimum:

- frontmatter: `type`, `description`, `status`, `owner`, `verified`, `sources`;
- `description` — one sentence, at most 200 characters, ending with a period, **never `…`**;
- the skeleton for the note's type (business entity, contract, module card, decision, standard);
- uncertainty in `status` / `status_note`, not in a preamble above the answer;
- a new version as a `supersedes:` link, not `-v2` in the filename.

## Rules

Prefer a targeted edit over a new note. Keep the existing Obsidian links and the metadata. Describe
purpose, contract and limits; do not paste large code fragments. Never record secrets, tokens,
personal data or real environment values. Do not delete a historical decision — mark it
`superseded` and link the replacement. Do not move, rename or delete files or directories, and do
not add a top-level section, without an explicit user request.

## Validation after writing — both checks

1. **The linter.** `node tools/kb-lint.mjs` in the vault. Zero errors is the bar; it catches a
   truncated description, an unparseable frontmatter block, a broken or ambiguous link and a status
   outside the enum. A red lint means the base is less readable than before your edit.
2. **The validator.** Call the `knowledge-base-validator` subagent with the paths of every note you
   changed or created. It performs the structural and factual check, reconciles with the code where
   needed, and assigns `confirmed-by-agent` or records the discrepancy. The write to the vault is
   not complete without this step.

Then re-read the changed notes, confirm the links resolve, confirm the fact is not duplicated in two
canonical places, and list the changed paths in the report.

## When not to write

Formatting and linting; mechanical refactoring that changes no behaviour; a temporary experiment; a
change already fully described by a current note.

A **contradiction** between sources is not resolved by the agent — record it and ask. A **gap** (no
note describes an implemented capability) is not a reason to stay silent — write the draft from the
observable behaviour and mark it as unconfirmed.
