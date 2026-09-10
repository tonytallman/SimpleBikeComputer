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

### REQ-UI-003 Settings presentation

Metrics pages are the always-on primary surface. Settings is presented modally from Root (not as a tab or as a page in the metrics pager). Dismiss returns to the same metrics page. Do not use a persistent tab bar for Settings versus metrics.

- **Status**: Accepted
- **See**: [PDR-0003](pdr/0003-settings-modal-presentation.md)

### REQ-UI-004 Settings entry affordance

A discreet overlay gear on Root (not a navigation bar on the metrics surface) opens Settings. Dismiss returns to the same metrics page.

- **Status**: Accepted
- **See**: [PDR-0004](pdr/0004-settings-entry-affordance.md)

### REQ-SET-001 Settings units

Settings includes a Units section with Speed (`mph`, `km/h`) and Distance (`mi`, `km`) pickers. Choices persist across launches. Default speed unit is miles per hour; default distance unit is miles.

- **Status**: Accepted
- **See**: [PDR-0005](pdr/0005-preferred-units.md)

### REQ-SET-002 Keep screen on

Settings includes a System section with a **Keep screen on** toggle. Default is on. The choice persists across launches and disables the system idle timer for the app session from launch, not only when Settings is open.

- **Status**: Accepted
- **See**: [PDR-0006](pdr/0006-keep-screen-on.md)

### REQ-SET-003 Location permission status

Settings includes a System section **Location permission** row showing the current iOS Location authorization status (for example Always, While Using, Denied) and a control that opens the app’s page in iOS Settings. Status refreshes when Settings appears and when the app returns to the foreground.

- **Status**: Accepted
- **See**: [PDR-0007](pdr/0007-location-in-background.md)

### REQ-SRC-001 Phone location in background

The phone location source requests Always authorization at launch and continues sampling while the app is temporarily backgrounded so derived ride metrics (speed now; max speed, accumulated time, accumulated distance, and similar when present) do not lose data during brief interruptions.

- **Status**: Accepted
- **See**: [PDR-0007](pdr/0007-location-in-background.md)

### REQ-MET-001 Preferred units on display

Displayed speed (and distance when that metric exists) uses the rider’s preferred unit from Settings. Changing a unit picker updates the current displayed value without waiting for a new sensor sample.

- **Status**: Accepted
- **See**: [PDR-0005](pdr/0005-preferred-units.md)

### REQ-MET-002 Moving time

Accumulated time is **moving time**: it accrues only while instantaneous speed is at or above the autopause speed threshold. Stopped time (for example at traffic lights) does not increase total or trip time.

- **Status**: Accepted
- **See**: [PDR-0008](pdr/0008-autopause-moving-time.md)

### REQ-MET-003 Autopause

When instantaneous speed is below the autopause speed threshold, all time-boxed reductions pause (distance, time, maxima, averages when present). There is no hysteresis in v1. Default threshold is 3 mph until the rider changes it in Settings.

- **Status**: Accepted
- **See**: [PDR-0008](pdr/0008-autopause-moving-time.md)

### REQ-MET-004 Time boxes

Time-bound metrics are calculated for one of two time boxes: **total** (forever, never reset) and **trip** (manually resettable). There is no ride start/stop; the app does not model ride sessions.

- **Status**: Accepted

### REQ-SET-004 Autopause threshold

Settings includes an Autopause section with a speed-threshold slider (0–10 in the rider's current speed units). The choice persists across launches. Default is 3 mph.

- **Status**: Accepted
- **See**: [PDR-0008](pdr/0008-autopause-moving-time.md)
