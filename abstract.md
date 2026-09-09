# Simple Bike Computer

Simple Bike Computer is a native iOS/iPadOS app that functions as a simple bike computer. It can use various sources to read and display real-time bike metrics. It is not a ride-tracking app with start and stop buttons but more of an app to display instantaneous metrics. Time-bound metrics, like average speed and total distance, will be calculated for one of two time boxes: total (forever) and a manually resettable "trip".

## Product docs

| Document | Role |
|----------|------|
| This file (`abstract.md`) | Vision: why the app exists, MVP vs later, non-goals, product language |
| [`docs/requirements.md`](docs/requirements.md) | Living product requirements (edit in place) |
| [`docs/pdr/`](docs/pdr/) | Product decision records (why a requirement looks like this) |
| [`docs/adr/`](docs/adr/) | Architecture decision records (how we build it) |
| [`docs/metrics-model.md`](docs/metrics-model.md) | Metrics mental model and code model (design reference) |

Architecture decisions (how we build it) belong in `docs/adr/` when needed, not in PDRs.

## Metrics

The following metrics should be viewable in the app.

### Minimum Viable Product

- instantaneous speed
- instantaneous cadence (when available)
- time (total) — moving time; accrues only while speed is at or above the autopause threshold ([PDR-0008](docs/pdr/0008-autopause-moving-time.md))
- distance (total)

### Future

- average speed (total)
- average speed (trip)
- maximum speed (total)
- maximum speed (trip)
- average cadence (total)
- average cadence (trip)
- maximum cadence (total)
- maximum cadence (trip)
- instantaneous heart rate
- average heart rate (total)
- average heart rate (trip)
- instantaneous power
- average power (total)
- average power (trip)
- maximum power (total)
- maximum power (trip)

### Sources

Bike metrics can come from Location Manager, CSCS BLE sensors, or Apple Watch if possible. Heart-rate metrics can come from HRS BLE sensors, or Apple Watch if possible.

## UI

The UI will support all four orientations to accomodate any possible mounting to the bike.

### Terminology

| Term | Meaning |
|------|---------|
| **Page** | One full-screen configured metrics surface (1…N, cycleable later); a configured instance of a layout |
| **Field** | One display slot on a page (large or small) that shows a metric; later a field may be configured with several metrics and cycle among them |
| **Layout** | Arrangement template for a page (e.g. large top field + three small fields) |
| **Metric** | A kind of ride data (e.g. instantaneous speed, total distance), independent of UI |

A **field** is a slot; a **metric** is the data shown in that slot. When a field cycles, the rotating things are metrics, not nested fields.

Do not use *Dashboard*, *metrics screen*, or *widget* for these concepts. Settings remains a *settings screen*; it is not a Page.

See [PDR-0001](docs/pdr/0001-page-field-terminology.md).

### Pages

#### Minimum Viable Product

There will be a single page with one layout available in landscape and one layout available in portrait. The landscape layout will display instantaneous speed in a large field in the top center with distance, time (total), and instantaneous cadence in smaller fields horizontally stacked along the bottom. The portrait layout will display instantaneous speed in a large field in the top center with distance, time (total), and instantaneous cadence in smaller fields vertically stacked along the bottom.

#### Future

The following will be added in future versions of the app.
- more layouts available (portrait and landscape)
- the ability to display multiple metrics in a single field, cycling between those metrics by tapping the field or an optional timer
- the ability to add and configure multiple pages (configured layout instances) to be displayed full screen, with swipe between pages (page-control style)

Ride-time inputs are orthogonal: swipe changes page; tap and optional timer cycle metrics within a field. See [PDR-0002](docs/pdr/0002-page-field-navigation.md).

### Settings

Mostly take settings screens and architecture from [Biker](https://github.com/tonytallman/Biker) (../Biker) but eliminate FTMS.

## Architecture

- Use dependency injection with composition at the composition root.
- Independent software modules are local Swift packages.
- Code with dependencies defines its own dependencies, not coupling directly to other project types. For example, a hypothetical `class HeartRateService` will define an embedded `protocol Logger` and `protocol HeartRateSource` that the dependency container will satisfy with existing instances that might or might not need to adapted to fit the dependency protocols.
- Prefer `AsyncSequence` over Combine for streaming APIs; see [ADR-0001](docs/adr/0001-asyncsequence-not-combine.md).
- Metrics use reducers, projections, delta samples, and snapshot streams; see [ADR-0004](docs/adr/0004-metrics-reducers-projections-snapshots.md) and [`docs/metrics-model.md`](docs/metrics-model.md).
- I want to have AI work in smaller chunks so that I can steer the development before too much code is written.