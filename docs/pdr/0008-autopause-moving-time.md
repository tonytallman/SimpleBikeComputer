# 8. Autopause and moving time

- **Status**: Accepted
- **Date**: 2026-09-09
- **Supersedes**:
- **Superseded by**:
- **Affects**: REQ-MET-002, REQ-MET-003, REQ-SET-004

## Context

MVP includes **time (total)** and **distance (total)**. Without a pause rule, stopped time (traffic lights, café stops) inflates accumulated time and deflates average speed when those metrics arrive. Riders expect a bike computer to measure **moving** time, not elapsed wall-clock time since the app launched.

The related [Biker](https://github.com/tonytallman/Biker) app already auto-pauses: when instantaneous speed is below a threshold, ride activity is `.paused`; at or above the threshold, `.active` (`AutoPauseService` in Biker's CoreLogic package). Biker defaults the threshold to **3 mph**, exposes a Settings picker, and persists the choice. Accumulating metrics consult a shared ride context and accrue only while active.

Alternatives considered:

1. **Elapsed time, no autopause** — Rejected: time and averages are wrong whenever the bike is stopped.
2. **Moving time via autopause, user-configurable threshold, no hysteresis** (chosen) — Matches Biker's detector; the rider chooses a threshold that does not chatter at their typical crawl speed.
3. **Hysteresis** (enter pause only after speed stays below X for Y seconds; resume only above X + δ) — Deferred. Can be added later without changing the moving-time definition.
4. **Pedaling-based pause for cadence only** — Deferred. "Average cadence while pedaling" can be a second gated crank reducer later (gate when Δrevolutions == 0); not required for v1.

## Decision

- Accumulated **time is moving time**: time-boxed reductions accrue only while instantaneous speed is **at or above** the autopause speed threshold.
- When speed is below the threshold, **all** time-boxed reductions **pause** together — distance, time, maxima, and averages (when present). This includes max speed: a fresh max stays zero if the rider never exceeds the threshold (accepted edge case).
- **Average cadence** (when present) means **while moving** (same gate as distance and time), not while pedaling.
- The autopause **threshold is user-configurable**, persisted across launches, with default **3 mph** (matching Biker). A Settings control for the threshold is **Later** ([REQ-SET-004](requirements.md)); a stored default suffices until then.
- **No hysteresis** in v1.

Architecture (sample gate upstream of reducers) is in [ADR-0004](../adr/0004-metrics-reducers-projections-snapshots.md) and [`docs/metrics-model.md`](../metrics-model.md).

## Consequences

**Positive**: Time and distance match rider expectations; one gate gives consistent pause behavior across all reductions; threshold tuning deferred to Settings without blocking infrastructure; aligns with Biker behavior riders may already know.

**Negative**: No hysteresis may cause pause/resume flicker at crawl speeds until the rider raises the threshold or hysteresis is added later; max speed below threshold never records (accepted).

**Risks / follow-ups**: Port autopause from Biker as `AsyncStream` (ADR-0001). Add Settings threshold picker when UI work allows. Revisit hysteresis if field testing shows chatter. "Average cadence while pedaling" remains a future optional reducer behind a separate gate.
