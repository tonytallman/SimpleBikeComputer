# Simple Bike Computer

Simple Bike Computer is a native iOS/iPadOS app that functions as a simple bike computer. It can use various sources to read and display real-time bike metrics. It is not a ride-tracking app with start and stop buttons but more of an app to display instantaneous metrics. Time-bound metrics, like average speed and total distance, will be calculated for one of two time boxes: total (forever) and a manually resettable "trip".

## Metrics

The following metrics should be viewable in the app.

### Minimum Viable Product

- instantaneous speed
- instantaneous cadence (when available)
- time (total)
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

### Metrics Screens

#### Minimum Viable Product

There will be a single layout available in landscape and a single layout available in portrait. The landscape layout will display instantaneous speed in a large widget in the top center with distance, time (total), and instantaneous cadence in smaller widgets horizontally stacked along the bottom. The portrait layout will display instantaneous speed in a large widget in the top center with distance, time (total), and instantaneous cadence in smaller widgets vertically stacked along the bottom.

#### Future

The following will be added in future versions of the app.
- more layouts available (portrait and landscape)
- the ability to display multiple metrics in a single metric widget with the display cycling between configured metrics by periodic cycling, tapping, or swiping
- the ability to add and configure multiple instances of available layouts to be displayed full screen with cycling between layouts by periodic cycling, tapping or swiping

### Settings

Mostly take settings screens and architecture from [Biker](https://github.com/tonytallman/Biker) (../Biker) but eliminate FTMS.

## Architecture

- Use dependency injection with composition at the composition root.
- Independent software modules are local Swift packages.
- Code with dependencies defines its own dependencies, not coupling directly to other project types. For example, a hypothetical `class HeartRateService` will define an embedded `protocol Logger` and `protocol HeartRateSource` that the dependency container will satisfy with existing instances that might or might not need to adapted to fit the dependency protocols.
- I want to have AI work in smaller chunks so that I can steer the development before too much code is written.