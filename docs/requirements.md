# Requirements

Living product specification for Simple Bike Computer. This file is the **current** set of accepted (and proposed/later) requirements. Edit it in place; git history is the changeset log.

Product vision and non-goals live in [`abstract.md`](../abstract.md). Rationale for contested product choices lives in [`docs/pdr/`](pdr/). How we build software lives in ADRs under `docs/adr/` when those exist.

## When to write a PDR

Write a [product decision record](pdr/) when there were real alternatives and the rationale would otherwise be lost the next time this file is edited. Routine clarifications and obvious refinements need only a requirements edit (spec-only). A PDR is not the spec; after acceptance, update this file and link the PDR → requirement IDs under **Affects**.

## Conventions

### IDs

Format: `REQ-<AREA>-<NNN>` (zero-padded), stable once assigned. Do not reuse IDs.

Suggested areas (extend as needed):

| Area | Use for |
|------|---------|
| `UI` | Pages, fields, layouts, navigation chrome |
| `MET` | Metrics definitions and time boxes |
| `SRC` | Metric / sensor sources |
| `SET` | Settings behavior |

### Status

| Status | Meaning |
|--------|---------|
| `Proposed` | Under discussion; not yet binding |
| `Accepted` | Current product requirement (includes MVP) |
| `Later` | Agreed for a future version; not MVP |
| `Deprecated` | No longer required; keep for history |

MVP versus later is expressed with status on each requirement, not with a second requirements file.

### Entry shape

```markdown
### REQ-AREA-NNN Title

Statement of the requirement in plain language.

- **Status**: Proposed | Accepted | Later | Deprecated
- **See**: (optional) link to a PDR that motivated this requirement
```

## Requirements

### REQ-UI-001 Metrics UI vocabulary

Use **Page**, **Field**, **Layout**, and **Metric** as defined in the product language: a page is a configured layout instance; a field is a slot that displays a metric (later, possibly several metrics that cycle); a metric is a kind of ride data independent of UI.

- **Status**: Accepted
- **See**: [PDR-0001](pdr/0001-page-field-terminology.md)

### REQ-UI-002 Page and field navigation

When multiple pages and multi-metric fields exist: swipe (whole surface) changes page; tap on a field cycles that field’s configured metrics; an optional timer may cycle field metrics. Do not use swipe to cycle metrics in a field, or tap/timer to change page, as the default product. MVP remains one page and one metric per field with no cycling.

- **Status**: Later
- **See**: [PDR-0002](pdr/0002-page-field-navigation.md)
