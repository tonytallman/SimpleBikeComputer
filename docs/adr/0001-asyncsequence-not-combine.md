# 1. Prefer AsyncSequence over Combine

- **Status**: Accepted
- **Date**: 2026-09-04
- **Supersedes**:
- **Superseded by**:

## Context

Simple Bike Computer is a greenfield Swift 6 app that streams long-lived bike metrics (location, CSCS/HRS BLE, clocks). UI state already follows Observation (`@Observable` view models), not Combine’s `@Published`.

The related [Biker](https://github.com/tonytallman/Biker) app wires metrics as `AnyPublisher` and tests with CombineSchedulers. Product guidance tells agents to take settings and architecture from Biker, so without an explicit policy Combine pipelines would be copied here.

Alternatives considered:

1. **AsyncSequence / AsyncStream** as the app’s stream model (chosen).
2. **Combine** throughout, matching Biker.
3. **Dual-stack** — Combine internally, AsyncSequence only at edges. Rejected: two concurrency models and a path back to Biker-style `AnyPublisher` APIs.

Apple already exposes several relevant sources as `AsyncSequence` (for example `CLLocationUpdate.liveUpdates()`, `NotificationCenter.notifications(named:)`). Bridging the rest with `AsyncStream` keeps one model.

## Decision

App-owned streaming APIs use `AsyncSequence` (including `AsyncStream`). Do not `import Combine` and do not expose `Publisher`, `AnyPublisher`, `Subject`, or `@Published` in this app’s modules.

- UI latest values live on Observation view models, not `CurrentValueSubject`.
- Compose streams with Swift concurrency (`Task`, `for await`, cancellation). When operators such as merge / combineLatest / throttle are first needed, add [swift-async-algorithms](https://github.com/apple/swift-async-algorithms); do not add that package until then.
- If an Apple or third-party API only offers Combine, adapt at the boundary (`publisher.values` or `AsyncStream`) and do not leak Combine types across this app’s public or package APIs.
- Do not copy Combine metric wiring from Biker.

## Consequences

**Positive**: One Swift 6–friendly concurrency model; natural cancellation via `Task`; aligns with Observation UI; reduces risk of importing Biker’s Combine style by default.

**Negative**: Multi-consumer fan-out and some operators need more explicit design than Combine. Multicast requires an explicit broadcast (`AsyncStream` per subscriber, or a store of the latest value).

**Risks / follow-ups**: When stream composition operators are first required, add swift-async-algorithms rather than reintroducing Combine. Agent enforcement lives in [`.cursor/rules/asyncsequence.mdc`](../../.cursor/rules/asyncsequence.mdc).
