import Foundation
import SettingsVM
import Testing

@Suite("InMemorySettingsStorage Tests")
struct InMemorySettingsStorageTests {
    @Test("get returns nil for missing key")
    func getMissingKey() {
        let storage = InMemorySettingsStorage()
        #expect(storage.get(forKey: "missing") == nil)
    }

    @Test("set and get round-trip string")
    func setGetString() {
        let storage = InMemorySettingsStorage()
        storage.set(value: "value", forKey: "key")
        #expect(storage.get(forKey: "key") as? String == "value")
    }

    @Test("set nil removes value")
    func setNilRemoves() {
        let storage = InMemorySettingsStorage()
        storage.set(value: "value", forKey: "key")
        storage.set(value: nil, forKey: "key")
        #expect(storage.get(forKey: "key") == nil)
    }
}

@Suite("DefaultMetricsSettings Tests")
struct DefaultMetricsSettingsTests {
    @Test("Default values are mph and miles")
    func defaultValues() async {
        let settings = DefaultMetricsSettings(storage: InMemorySettingsStorage())

        var speedValues: [UnitSpeed] = []
        var distanceValues: [UnitLength] = []

        let speedTask = Task {
            for await value in settings.speedUnits {
                speedValues.append(value)
                if speedValues.count == 1 { break }
            }
        }
        let distanceTask = Task {
            for await value in settings.distanceUnits {
                distanceValues.append(value)
                if distanceValues.count == 1 { break }
            }
        }

        await speedTask.value
        await distanceTask.value

        #expect(speedValues == [.milesPerHour])
        #expect(distanceValues == [.miles])
    }

    @Test("setSpeedUnits publishes new value")
    func setSpeedUnits() async {
        let settings = DefaultMetricsSettings(storage: InMemorySettingsStorage())

        var receivedValues: [UnitSpeed] = []
        let task = Task {
            for await value in settings.speedUnits {
                receivedValues.append(value)
                if receivedValues.count == 2 { break }
            }
        }

        settings.setSpeedUnits(.kilometersPerHour)
        await task.value

        #expect(receivedValues == [.milesPerHour, .kilometersPerHour])
    }

    @Test("setDistanceUnits publishes new value")
    func setDistanceUnits() async {
        let settings = DefaultMetricsSettings(storage: InMemorySettingsStorage())

        var receivedValues: [UnitLength] = []
        let task = Task {
            for await value in settings.distanceUnits {
                receivedValues.append(value)
                if receivedValues.count == 2 { break }
            }
        }

        settings.setDistanceUnits(.kilometers)
        await task.value

        #expect(receivedValues == [.miles, .kilometers])
    }

    @Test("Settings restores speed units from storage")
    func restoresSpeedUnitsFromStorage() async {
        let storage = InMemorySettingsStorage()
        storage.set(value: SpeedUnitKey.kilometersPerHour.rawValue, forKey: "speedUnits")

        let settings = DefaultMetricsSettings(storage: storage)
        var received: [UnitSpeed] = []
        let task = Task {
            for await value in settings.speedUnits {
                received.append(value)
                break
            }
        }
        await task.value

        #expect(received == [.kilometersPerHour])
    }

    @Test("Settings persists speed units when value changes")
    func persistsSpeedUnits() async {
        let storage = InMemorySettingsStorage()
        let settings1 = DefaultMetricsSettings(storage: storage)
        settings1.setSpeedUnits(.kilometersPerHour)

        let settings2 = DefaultMetricsSettings(storage: storage)
        var received: [UnitSpeed] = []
        let task = Task {
            for await value in settings2.speedUnits {
                received.append(value)
                break
            }
        }
        await task.value

        #expect(received == [.kilometersPerHour])
    }

    @Test("Settings persists distance units when value changes")
    func persistsDistanceUnits() async {
        let storage = InMemorySettingsStorage()
        let settings1 = DefaultMetricsSettings(storage: storage)
        settings1.setDistanceUnits(.kilometers)

        let settings2 = DefaultMetricsSettings(storage: storage)
        var received: [UnitLength] = []
        let task = Task {
            for await value in settings2.distanceUnits {
                received.append(value)
                break
            }
        }
        await task.value

        #expect(received == [.kilometers])
    }

    @Test("Default autoPauseThreshold is 3 mph")
    func defaultAutoPauseThreshold() async {
        let settings = DefaultMetricsSettings(storage: InMemorySettingsStorage())

        var received: [Measurement<UnitSpeed>] = []
        let task = Task {
            for await value in settings.autoPauseThreshold {
                received.append(value)
                if received.count == 1 { break }
            }
        }
        await task.value

        #expect(received.count == 1)
        let threshold = received[0].converted(to: .milesPerHour)
        #expect(abs(threshold.value - 3) <= 0.001)
    }

    @Test("setAutoPauseThreshold publishes new value")
    func setAutoPauseThresholdPublishes() async {
        let settings = DefaultMetricsSettings(storage: InMemorySettingsStorage())
        let newThreshold = Measurement<UnitSpeed>(value: 5, unit: .milesPerHour)

        var received: [Measurement<UnitSpeed>] = []
        let task = Task {
            for await value in settings.autoPauseThreshold {
                received.append(value)
                if received.count == 2 { break }
            }
        }

        settings.setAutoPauseThreshold(newThreshold)
        await task.value

        let latest = received[1].converted(to: .milesPerHour)
        #expect(abs(latest.value - 5) <= 0.001)
    }

    @Test("Settings restores autoPauseThreshold from storage")
    func restoresAutoPauseThresholdFromStorage() async {
        let storage = InMemorySettingsStorage()
        let threshold = Measurement<UnitSpeed>(value: 4, unit: .milesPerHour)
        storage.set(
            value: threshold.converted(to: .metersPerSecond).value,
            forKey: "autoPauseThresholdBaseValue",
        )
        storage.set(value: SpeedUnitKey.milesPerHour.rawValue, forKey: "autoPauseThresholdUnit")

        let settings = DefaultMetricsSettings(storage: storage)
        var received: [Measurement<UnitSpeed>] = []
        let task = Task {
            for await value in settings.autoPauseThreshold {
                received.append(value)
                break
            }
        }
        await task.value

        let restored = received[0].converted(to: .milesPerHour)
        #expect(abs(restored.value - 4) <= 0.001)
    }

    @Test("Settings persists autoPauseThreshold when value changes")
    func persistsAutoPauseThreshold() async {
        let storage = InMemorySettingsStorage()
        let settings1 = DefaultMetricsSettings(storage: storage)
        let threshold = Measurement<UnitSpeed>(value: 6, unit: .kilometersPerHour)
        settings1.setAutoPauseThreshold(threshold)

        let settings2 = DefaultMetricsSettings(storage: storage)
        var received: [Measurement<UnitSpeed>] = []
        let task = Task {
            for await value in settings2.autoPauseThreshold {
                received.append(value)
                break
            }
        }
        await task.value

        let restored = received[0].converted(to: .kilometersPerHour)
        #expect(abs(restored.value - 6) <= 0.001)
    }

    @Test("Falls back to default autoPauseThreshold when storage is invalid")
    func fallsBackToDefaultAutoPauseThreshold() async {
        let storage = InMemorySettingsStorage()
        storage.set(value: 1.0, forKey: "autoPauseThresholdBaseValue")
        storage.set(value: "invalid", forKey: "autoPauseThresholdUnit")

        let settings = DefaultMetricsSettings(storage: storage)
        var received: [Measurement<UnitSpeed>] = []
        let task = Task {
            for await value in settings.autoPauseThreshold {
                received.append(value)
                break
            }
        }
        await task.value

        let threshold = received[0].converted(to: .milesPerHour)
        #expect(abs(threshold.value - 3) <= 0.001)
    }
}

@MainActor
@Suite("RuntimeAutopauseSettingsViewModel Tests")
struct RuntimeAutopauseSettingsViewModelTests {
    @Test("setAutoPauseThreshold updates currentAutoPauseThreshold")
    func setAutoPauseThresholdUpdatesState() async {
        let settings = DefaultMetricsSettings(storage: InMemorySettingsStorage())
        let viewModel = RuntimeAutopauseSettingsViewModel(metricsSettings: settings)

        try? await Task.sleep(for: .milliseconds(50))

        let mph = Measurement<UnitSpeed>(value: 5, unit: .milesPerHour)
        viewModel.setAutoPauseThreshold(mph)

        try? await Task.sleep(for: .milliseconds(50))

        let current = viewModel.currentAutoPauseThreshold.converted(to: .milesPerHour)
        #expect(abs(current.value - 5) <= 0.001)
    }

    @Test("external metricsSettings change updates currentAutoPauseThreshold")
    func externalAutoPauseThresholdChangeUpdatesState() async {
        let settings = DefaultMetricsSettings(storage: InMemorySettingsStorage())
        let viewModel = RuntimeAutopauseSettingsViewModel(metricsSettings: settings)

        try? await Task.sleep(for: .milliseconds(50))

        let kph = Measurement<UnitSpeed>(value: 8, unit: .kilometersPerHour)
        settings.setAutoPauseThreshold(kph)

        try? await Task.sleep(for: .milliseconds(50))

        let current = viewModel.currentAutoPauseThreshold.converted(to: .kilometersPerHour)
        #expect(abs(current.value - 8) <= 0.001)
    }
}

@MainActor
@Suite("RuntimeUnitSettingsViewModel Tests")
struct RuntimeUnitSettingsViewModelTests {
    @Test("setSpeedUnits updates currentSpeedUnits")
    func setSpeedUnitsUpdatesState() async {
        let settings = DefaultMetricsSettings(storage: InMemorySettingsStorage())
        let viewModel = RuntimeUnitSettingsViewModel(metricsSettings: settings)

        try? await Task.sleep(for: .milliseconds(50))

        viewModel.setSpeedUnits(.kilometersPerHour)

        try? await Task.sleep(for: .milliseconds(50))

        #expect(viewModel.currentSpeedUnits == .kilometersPerHour)
    }

    @Test("external metricsSettings change updates currentSpeedUnits")
    func externalSpeedUnitsChangeUpdatesState() async {
        let settings = DefaultMetricsSettings(storage: InMemorySettingsStorage())
        let viewModel = RuntimeUnitSettingsViewModel(metricsSettings: settings)

        try? await Task.sleep(for: .milliseconds(50))

        settings.setSpeedUnits(.kilometersPerHour)

        try? await Task.sleep(for: .milliseconds(50))

        #expect(viewModel.currentSpeedUnits == .kilometersPerHour)
    }

    @Test("setDistanceUnits updates currentDistanceUnits")
    func setDistanceUnitsUpdatesState() async {
        let settings = DefaultMetricsSettings(storage: InMemorySettingsStorage())
        let viewModel = RuntimeUnitSettingsViewModel(metricsSettings: settings)

        try? await Task.sleep(for: .milliseconds(50))

        viewModel.setDistanceUnits(.kilometers)

        try? await Task.sleep(for: .milliseconds(50))

        #expect(viewModel.currentDistanceUnits == .kilometers)
    }
}

@Suite("DefaultSystemSettings Tests")
struct DefaultSystemSettingsTests {
    @Test("Default keepScreenOn is true")
    func defaultKeepScreenOn() async {
        let settings = DefaultSystemSettings(storage: InMemorySettingsStorage())

        var receivedValues: [Bool] = []
        let task = Task {
            for await value in settings.keepScreenOn {
                receivedValues.append(value)
                if receivedValues.count == 1 { break }
            }
        }

        await task.value

        #expect(receivedValues == [true])
    }

    @Test("setKeepScreenOn publishes new value")
    func setKeepScreenOnPublishes() async {
        let settings = DefaultSystemSettings(storage: InMemorySettingsStorage())

        var receivedValues: [Bool] = []
        let task = Task {
            for await value in settings.keepScreenOn {
                receivedValues.append(value)
                if receivedValues.count == 2 { break }
            }
        }

        settings.setKeepScreenOn(false)
        await task.value

        #expect(receivedValues == [true, false])
    }

    @Test("Settings restores keepScreenOn from storage")
    func restoresKeepScreenOnFromStorage() async {
        let storage = InMemorySettingsStorage()
        storage.set(value: false, forKey: "keepScreenOn")

        let settings = DefaultSystemSettings(storage: storage)
        var received: [Bool] = []
        let task = Task {
            for await value in settings.keepScreenOn {
                received.append(value)
                break
            }
        }
        await task.value

        #expect(received == [false])
    }

    @Test("Settings persists keepScreenOn when value changes")
    func persistsKeepScreenOn() async {
        let storage = InMemorySettingsStorage()
        let settings1 = DefaultSystemSettings(storage: storage)
        settings1.setKeepScreenOn(false)

        let settings2 = DefaultSystemSettings(storage: storage)
        var received: [Bool] = []
        let task = Task {
            for await value in settings2.keepScreenOn {
                received.append(value)
                break
            }
        }
        await task.value

        #expect(received == [false])
    }
}

@MainActor
@Suite("RuntimeSystemSettingsViewModel Tests")
struct RuntimeSystemSettingsViewModelTests {
    @Test("setKeepScreenOn updates keepScreenOn")
    func setKeepScreenOnUpdatesState() async {
        let settings = DefaultSystemSettings(storage: InMemorySettingsStorage())
        let viewModel = RuntimeSystemSettingsViewModel(systemSettings: settings)

        try? await Task.sleep(for: .milliseconds(50))

        viewModel.setKeepScreenOn(false)

        try? await Task.sleep(for: .milliseconds(50))

        #expect(viewModel.keepScreenOn == false)
    }

    @Test("external systemSettings change updates keepScreenOn")
    func externalKeepScreenOnChangeUpdatesState() async {
        let settings = DefaultSystemSettings(storage: InMemorySettingsStorage())
        let viewModel = RuntimeSystemSettingsViewModel(systemSettings: settings)

        try? await Task.sleep(for: .milliseconds(50))

        settings.setKeepScreenOn(false)

        try? await Task.sleep(for: .milliseconds(50))

        #expect(viewModel.keepScreenOn == false)
    }
}
