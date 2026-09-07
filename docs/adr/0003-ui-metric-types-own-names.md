# 3. LayoutsModel factories own UI metric display names

- **Status**: Accepted
- **Date**: 2026-09-07
- **Supersedes**:
- **Superseded by**:

## Context

The app has two `Metric` types: domain streams in `Metrics` (no display name) and UI presentation in `LayoutsModel` (`name` / `value` / `units`). The composition root bridges them.

Initially `DependencyContainer` passed `name: "Speed"` when constructing `LayoutsModel.RuntimeMetric`. Display names are UI copy; the composition root should bind domain streams to UI metrics, not choose labels.

Alternatives considered:

1. **Static factories on `RuntimeMetric`** (chosen) — e.g. `RuntimeMetric.speedMetric(values:)` returns `RuntimeMetric(name: "Speed", values:)`. `RuntimeMetric` stays `final`.
2. **Name at the composition root** — rejected; container owns UI concerns.
3. **`MetricType` enum** — names live in Layouts, but a catalog type is premature before page/field configuration exists.
4. **`SpeedMetric` subclass** — would require dropping `final` on `RuntimeMetric`.
5. **`SpeedMetric` wrapping `RuntimeMetric`** — composition of two `@Observable` types does not notify views when inner `value`/`units` change without extra Observation plumbing.

Product language (PDR-0001): a **metric** is a kind of ride data independent of UI; a **field** is a slot that shows a metric. Domain `Metrics.Metric` stays nameless.

## Decision

Keep `LayoutsModel.RuntimeMetric` **`final`**. Add static factories on `RuntimeMetric` that own display names for each MVP metric kind. The composition root calls the appropriate factory and passes only the domain stream.

Cadence, distance, and time get their own factories later (`cadenceMetric`, `distanceMetric`, `timeMetric`) or a dedicated type if formatting diverges (e.g. clock display for time).

`init(name:values:)` remains public for previews, tests, and one-off metrics.

## Consequences

**Positive**: Composition root stays free of UI copy; names colocate with LayoutsModel formatting; `RuntimeMetric` stays `final`; Observation continues to work because views bind the same `RuntimeMetric` instance that owns `value`/`units`.

**Negative**: Factories are naming conventions, not distinct types — layout VMs still hold `RuntimeMetric`, not `SpeedMetric`. Distinct types can be added later if per-metric behavior warrants them.

**Risks / follow-ups**: When multi-field layouts land, page/field configuration may reference metric kind; factories or a small catalog enum may evolve then. Do not put display names on `Metrics.Metric`.
