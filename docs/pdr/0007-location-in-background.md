# 7. Location in background

- **Status**: Accepted
- **Date**: 2026-09-09
- **Supersedes**:
- **Superseded by**:
- **Affects**: REQ-SRC-001, REQ-SET-003

## Context

Keep screen on keeps the display awake while the app is in front. It does not stop iOS from suspending location when the rider briefly leaves the app (music, a call, Control Center, the lock screen). Without background location, location updates pause for that interval and derived ride data is wrong or incomplete: max speed can miss a sprint, accumulated time and accumulated distance (when those metrics exist) skip the gap, and any later average or similar rollup is off.

The app currently uses `CLLocationUpdate.liveUpdates(.fitness)` with When In Use authorization only. Biker requests Always authorization, enables the location background mode, and shows a permission status row in System Settings (labeled **Location in Background** there).

Alternatives considered:

1. **When In Use only** — Rejected: samples stop during brief backgrounding; ride metrics lose data.
2. **Always + background mode at launch** — Request Always via `CLServiceSession`, retain `CLBackgroundActivitySession` for riders who stay on While Using, enable `UIBackgroundModes` location (chosen).
3. **Separate Location in Foreground and Location in Background rows** — Rejected: iOS has one Location permission; both rows would show the same status and open the same Settings page.

## Decision

Request Always location at app launch so ride samples continue when the app is temporarily backgrounded. Enable the location background mode and add the Always usage description. Settings includes a **Location permission** row in the System section (Biker’s row, retitled) showing current authorization status and a link to change it in iOS Settings. Do not add a separate foreground row. Bluetooth permission row remains deferred until BLE sensors exist.

## Consequences

**Positive**: Ride metrics stay complete across brief backgrounding; riders can see and fix permission problems without guessing; row title matches the single iOS permission ladder.

**Negative**: Always prompt at launch may feel heavy before distance/time metrics exist; blue background-location indicator when rider stays on While Using.

**Risks / follow-ups**: Add Bluetooth permission row when BLE sensors land; revisit usage strings if product language changes.
