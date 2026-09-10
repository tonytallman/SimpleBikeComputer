# 5. Preferred speed and distance units

- **Status**: Accepted
- **Date**: 2026-09-08
- **Supersedes**:
- **Superseded by**:
- **Affects**: REQ-SET-001, REQ-MET-001

## Context

Riders expect to choose speed and distance units (imperial vs metric) rather than rely on locale alone. Biker exposes explicit Speed (`mph`, `km/h`) and Distance (`mi`, `km`) pickers in Settings and applies the choice at the composition root so metric fields show converted values immediately when the picker changes.

Alternatives considered:

1. **Explicit pickers** — Speed and Distance unit choices in Settings; defaults imperial (`mph`, `miles`) to match Biker (chosen).
2. **Locale-only** — Use `Locale.current` measurement system with no Settings UI. Rejected: riders may prefer units that differ from locale.
3. **Temperature and other dimensions** — Not in Biker’s Units section; deferred.

## Decision

Settings includes a **Units** section with Speed and Distance pickers. Preferences persist across launches. Default speed unit is miles per hour; default distance unit is miles. Displayed speed (and distance when that metric exists) uses the preferred unit; changing a picker updates the current displayed value without waiting for a new sensor sample.

## Consequences

**Positive**: Matches Biker behavior; explicit rider control; conversion centralized at the composition root.

**Negative**: Two pickers to maintain; distance picker has no visible effect until a distance metric is implemented.

**Risks / follow-ups**: Wire distance conversion when total-distance metric lands. The Autopause threshold slider displays and edits in the rider's current speed units from the Units section.
