# 2. Page and field navigation

- **Status**: Accepted
- **Date**: 2026-09-04
- **Supersedes**:
- **Superseded by**:
- **Affects**: REQ-UI-002

## Context

Future versions will support multiple pages and multiple metrics configured in a single field. Early vision text offered the same three cycling mechanisms—periodic timer, tap, and swipe—for both layers. That creates nested pagers: a swipe or tap means different things depending on where it started, which is unreliable on a handlebar mount (gloves, bounce, coarse gestures).

Alternatives considered:

1. **Same three mechanisms at both layers** — maximum flexibility; ambiguous gestures and settings explosion.
2. **Orthogonal mapping** — each input owns one layer (e.g. swipe for pages; tap and optional timer for field metrics).
3. **Pages-only cycling** — no in-field metric rotation; more pages, one metric per field (Garmin-like simplicity).

## Decision

Use an orthogonal mapping as the default product:

| Input | Owns | Notes |
|-------|------|-------|
| **Swipe** | **Pages** | Whole-surface, page-control style; no hit-test for which field was under the finger |
| **Tap** | **That field’s metrics** | Targeted; advances only the field that was tapped |
| **Optional timer** | **Field metrics** | Hands-free rotation within a field; does **not** auto-flip pages by default |

Do not use swipe to cycle metrics in a field, or tap/timer to change page, as the default product.

MVP is unchanged: one page, one metric per field, no cycling.

Vocabulary for Page, Field, Layout, and Metric remains [PDR-0001](0001-page-field-terminology.md).

## Consequences

**Positive**: Predictable ride-time input; swipe and tap do not fight; timer does not steal the page the rider chose.

**Negative**: Less per-user remapping of gestures than “all three everywhere”; riders who want tap-to-change-page need a different future decision.

**Risks / follow-ups**: Reflect this in [`abstract.md`](../../abstract.md) Future bullets and [`docs/requirements.md`](../requirements.md). Agent guidance lives in [`.cursor/rules/ui-terminology.mdc`](../../.cursor/rules/ui-terminology.mdc).
