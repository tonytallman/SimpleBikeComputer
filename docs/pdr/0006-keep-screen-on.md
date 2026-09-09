# 6. Keep screen on

- **Status**: Accepted
- **Date**: 2026-09-08
- **Supersedes**:
- **Superseded by**:
- **Affects**: REQ-SET-002

## Context

Riders mount the phone on the bike and need the display to stay awake while riding. Biker exposes a **Keep screen on** toggle in a System section of Settings (default on). The preference persists and disables the system idle timer for the app session.

Simple Bike Computer presents Settings modally rather than as a persistent tab, so applying the idle timer only when the settings screen opens would leave the screen sleeping until the rider opens Settings. The composition root must own the persisted setting and a separate applier that observes it from launch.

Biker’s System section also includes Location in Background and Bluetooth in Background permission status rows. At the time of this decision the app did not yet have background location or Bluetooth sensors; those rows were deferred (location permission row landed in [PDR-0007](0007-location-in-background.md)).

Alternatives considered:

1. **Toggle in System section with composition-root applier** — Persist in SettingsVM; DependencyContainer owns the setting and a lifetime observer that sets `isIdleTimerDisabled` (chosen).
2. **Apply only in settings view model** — Rejected: modal presentation means the rider would not benefit until opening Settings.
3. **Port full Biker System section including permission rows now** — Rejected: misleading status until BLE and background location exist.

## Decision

Settings includes a **System** section with a **Keep screen on** toggle. Default is on. The choice persists across launches. The composition root owns `DefaultSystemSettings` (shared with settings view models, like units) and a separate idle-timer applier that observes `keepScreenOn` from app launch. The Location permission row was deferred here and added in [PDR-0007](0007-location-in-background.md). Bluetooth permission row remains deferred.

## Consequences

**Positive**: Matches Biker’s primary System behavior; screen stays on during rides without opening Settings; clear separation between persistence (SettingsVM) and UIKit side effect (composition root).

**Negative**: One more long-lived object in DependencyContainer; Bluetooth permission row still to port later.

**Risks / follow-ups**: Location permission row added in [PDR-0007](0007-location-in-background.md). Add Bluetooth permission row when BLE sensors land.
