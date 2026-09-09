# 4. Metrics: reducers, projections, and snapshot streams

- **Status**: Accepted
- **Date**: 2026-09-09
- **Supersedes**:
- **Superseded by**:

## Context

Simple Bike Computer is building metrics beyond instantaneous speed: accumulated distance and moving time (MVP), then averages and maximums. Time-boxed metrics use two **time boxes** — total (forever) and trip (manually resettable) — with no ride start/stop. Sources deliver data in different native shapes: phone location exposes Doppler speed and timestamped fixes; CSC BLE sensors expose cumulative wheel/crank counters with event timestamps ([BluetoothBikeSensorSwift](https://github.com/tonytallman/BluetoothBikeSensorSwift)).

The related [Biker](https://github.com/tonytallman/Biker) app models metrics with Combine publishers and a shared ride context. This app forbids Combine in its modules ([ADR-0001](0001-asyncsequence-not-combine.md)). Domain metrics today expose three independent streams (`values`, `isAvailable`, `source`) on `Metrics.Metric`; UI display names stay in `LayoutsModel` ([ADR-0003](0003-ui-metric-types-own-names.md)).

Product rules for moving time and autopause live in [PDR-0008](../pdr/0008-autopause-moving-time.md); this ADR records *how* metrics are built, not *what* pause semantics mean.

The full mental and code model is in [`docs/metrics-model.md`](../metrics-model.md).

Alternatives considered:

1. **Metric families** (`SpeedMetrics` with `.speed` and `.average`) — Rejected: conflates stateless instantaneous metrics with per-timespan state; awkward for multiple timespans.
2. **Whole-timespan snapshot god object** — One accumulator holds all scalars for a timespan. Rejected: every new sensor kind touches one type; Biker demonstrated the maintenance cost. **Consistency groups** (minimal state per projection) keep atomicity without a god object.
3. **Independent scalar accumulators + downstream join** for averages (latest distance ÷ latest time) — Rejected: the two folds can sit at different positions in the event sequence; bias is worst when the denominator is small. Unfixable downstream.
4. **`Timespan` holds metric state** — Rejected: timespan becomes a god class; reducers own and persist their own state.
5. **App-level speed from Δd/Δt** (source-agnostic integration) — Rejected: each source has a strictly better method (Doppler; CSC event timestamps). Never re-derive what a source publishes.

## Decision

Adopt the model in [`docs/metrics-model.md`](../metrics-model.md):

- **Three metric kinds**: instantaneous (stateless relay), reduction (`state′ = f(state, sample)` plus reset), projection (pure function of reduction state).
- **Delta samples**: `WheelSample` / `CrankSample` carry Δquantity and **source-measured** Δt as `Measurement<UnitDuration>`. No app clock on the accumulation path. Each consistency group uses its own Δt stream.
- **Consistency-group reducers**: state grouped by what a projection must read atomically (e.g. `DistanceTimeReducer` for distance, time, and average speed). Max speed and crank groups are separate reducers.
- **Timespan**: identity (`total`, `trip`) plus reset signal only; no metric state. Persistence keys: `Metrics.<Reducer>.<TimespanID>`.
- **`MetricSnapshot`**: domain metrics emit one `AsyncStream<MetricSnapshot<Value>>` (`value`, `isAvailable`, `source`) instead of three independent properties. `shared()` multicasts snapshots. Domain metrics stay nameless; `LayoutsModel` factories unchanged.
- **Source arbitration**: ranked, availability-driven selector (CSC over phone location) upstream of reducers and autopause gate. `source` on a snapshot is the *currently feeding* source.
- **Autopause**: gate on sample streams per [PDR-0008](../pdr/0008-autopause-moving-time.md); implementation in a later phase.

Sources publish instantaneous values and delta samples by each source's best method. The app ranks sources, not integration methods.

## Consequences

**Positive**: Averages from (Σquantity, Σt) are sample-rate unbiased; distance/time/average speed cannot mispair; timespan and reducer boundaries stay stable as metrics grow; source failover is safe on delta streams; snapshot streams keep value and metadata consistent for UI source icons.

**Negative**: More types than a single god accumulator; domain `Metric` protocol will change in a later phase (snapshot refactor before reducers land); first stream merge/throttle operators require adding swift-async-algorithms.

**Risks / follow-ups**: Implement `MetricSnapshot` refactor while only speed is wired. Port autopause from Biker as `AsyncStream`. Add `wheelSamples` to location source and BluetoothBikeSensorSwift. Does not supersede ADR-0003.
