# 1. Page and Field terminology

- **Status**: Accepted
- **Date**: 2026-09-02
- **Supersedes**:
- **Superseded by**:
- **Affects**: (none yet; add `REQ-UI-*` links when UI requirements are written)

## Context

The app needs stable names for full-screen metric surfaces and the metric display slots on them. Alternatives considered included Dashboard (used in Biker), Screen, Display, Face, and Panel. Bike computers commonly use **pages** and **fields**. Dashboard implies a single overview home rather than 1…N peer surfaces that can cycle. Widget is easy to confuse with system widgets and with Biker’s naming.

## Decision

Use this vocabulary for metrics UI:

| Term | Meaning |
|------|---------|
| **Page** | One full-screen configured metrics surface (1…N, cycleable later) |
| **Field** | One metric display slot on a page (large or small) |
| **Layout** | Arrangement template for a page (e.g. large top field + three small fields) |

Do not use Dashboard, metrics screen, or widget for these concepts. Settings remains a settings screen; it is not a Page.

Product language is also recorded under UI → Terminology in [`abstract.md`](../../abstract.md).

## Consequences

**Positive**: Shared language for humans and agents; type and symbol names can prefer `Page`, `Field`, and `Layout`; aligns with bike-computer domain terms.

**Negative**: Differs from Biker’s Dashboard / Widget naming; readers of both codebases must not assume the same terms.

**Risks / follow-ups**: When UI requirements are added to [`docs/requirements.md`](../requirements.md), update **Affects** on this PDR with the relevant IDs. Agent guidance lives in [`.cursor/rules/ui-terminology.mdc`](../../.cursor/rules/ui-terminology.mdc).
