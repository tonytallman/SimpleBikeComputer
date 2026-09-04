# 1. Page and Field terminology

- **Status**: Accepted
- **Date**: 2026-09-02
- **Supersedes**:
- **Superseded by**:
- **Affects**: REQ-UI-001

## Context

The app needs stable names for full-screen metric surfaces and the metric display slots on them. Alternatives considered included Dashboard (used in Biker), Screen, Display, Face, and Panel. Bike computers commonly use **pages** and **fields**. Dashboard implies a single overview home rather than 1…N peer surfaces that can cycle. Widget is easy to confuse with system widgets and with Biker’s naming.

**Metric** was used throughout the vision without a formal definition, which left the Field–Metric relationship ambiguous (whether a field *is* a metric, or a slot that *shows* one).

## Decision

Use this vocabulary for metrics UI:

| Term | Meaning |
|------|---------|
| **Page** | One full-screen configured metrics surface (1…N, cycleable later) |
| **Field** | One display slot on a page (large or small) that shows a metric; later a field may be configured with several metrics and cycle among them |
| **Layout** | Arrangement template for a page (e.g. large top field + three small fields) |
| **Metric** | A kind of ride data (e.g. instantaneous speed, total distance), independent of UI |

A **field** is a slot; a **metric** is the data shown in that slot. When a field cycles, the rotating things are metrics, not nested fields. A **page** is a configured instance of a **layout** (layout chosen, metrics assigned to fields).

Do not use Dashboard, metrics screen, or widget for these concepts. Settings remains a settings screen; it is not a Page.

Product language is also recorded under UI → Terminology in [`abstract.md`](../../abstract.md).

## Consequences

**Positive**: Shared language for humans and agents; type and symbol names can prefer `Page`, `Field`, `Layout`, and `Metric`; aligns with bike-computer domain terms; Field vs Metric is unambiguous.

**Negative**: Differs from Biker’s Dashboard / Widget naming; readers of both codebases must not assume the same terms.

**Risks / follow-ups**: Agent guidance lives in [`.cursor/rules/ui-terminology.mdc`](../../.cursor/rules/ui-terminology.mdc). Ride-time navigation between pages and metrics in a field is recorded in [PDR-0002](0002-page-field-navigation.md).
