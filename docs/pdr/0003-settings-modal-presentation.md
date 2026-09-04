# 3. Settings as modal overlay

- **Status**: Accepted
- **Date**: 2026-09-04
- **Supersedes**:
- **Superseded by**:
- **Affects**: REQ-UI-003

## Context

The app has one to N full-screen metric pages during use and a settings screen used sparingly (sensors, units, layout configuration). Biker uses a tab bar (Dashboard + Settings), which works for a desk-side app but wastes glanceable area on a mounted bike computer and treats settings as a peer destination to metrics.

Alternatives considered:

1. **Tab bar** — Metrics and Settings as peer tabs (Biker). Rejected: persistent chrome competes with large metric fields; settings are rare.
2. **Settings as a page in the metrics pager** — swipe into settings mid-ride. Rejected: accidental navigation while riding.
3. **Modal overlay from Root** — metrics stay always visible; settings presented on demand and dismissed back to the same page (chosen).

## Decision

Metrics pages are the always-on primary surface. Settings is presented modally from Root (`fullScreenCover` with a `NavigationStack` inside for drill-downs). Dismiss returns to the exact page the rider left. Do not use a tab bar for Settings versus metrics.

Entry affordance for settings (long-press, discreet gear control, etc.) is a separate follow-up; this decision covers presentation only.

## Consequences

**Positive**: Full-bleed metrics UI; settings clearly separated from ride-time navigation; scales when multiple pages exist later.

**Negative**: Settings is not one tap away like a tab; requires a deliberate entry gesture.

**Risks / follow-ups**: Choose and implement a ride-safe settings entry affordance when the Settings screen is built. Root view model will own presentation state (`isSettingsPresented` or equivalent).
