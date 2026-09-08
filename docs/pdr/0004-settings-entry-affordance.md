# 4. Settings entry affordance

- **Status**: Accepted
- **Date**: 2026-09-08
- **Supersedes**:
- **Superseded by**:
- **Affects**: REQ-UI-004

## Context

[PDR-0003](0003-settings-modal-presentation.md) decided that Settings is a modal overlay from Root, but left the entry affordance open (long-press, discreet gear control, etc.). Metrics pages should stay full-bleed for a mounted bike computer; persistent chrome was already rejected for the tab bar.

Alternatives considered:

1. **Navigation bar on Root with a gear toolbar item** — Rejected: persistent chrome shrinks the metrics surface for the same reason as Biker’s tab bar.
2. **Long-press (or other hidden gesture)** — Rejected for MVP: harder to discover and awkward with gloves; can revisit later if the gear is too easy to hit mid-ride.
3. **Discreet overlay gear on Root** — Small gear in a safe-area corner; metrics stay full-bleed; one deliberate tap opens Settings (chosen).

## Decision

Root presents a discreet overlay gear (system `gearshape` image) in the top-trailing safe area. Tapping it presents Settings via the existing modal flow. There is no navigation bar on the metrics surface. Dismiss (Done) returns to the same metrics page.

## Consequences

**Positive**: Full-bleed metrics; discoverable entry without a tab or nav bar; matches PDR-0003 presentation.

**Negative**: Gear occupies a small corner of the metrics surface and can be tapped accidentally while riding.

**Risks / follow-ups**: If accidental opens are a problem in practice, consider a longer-press or less prominent control later without changing modal presentation.
