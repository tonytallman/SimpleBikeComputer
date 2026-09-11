import Foundation
import Metrics
import Testing

@Suite("InUnits AsyncSequence Tests")
struct InUnitsAsyncSequenceTests {
    @Test("Converts UnitSpeed measurements correctly")
    func speedConversion() async throws {
        let (speedStream, speedContinuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)
        let (unitsStream, unitsContinuation) = AsyncStream.makeStream(of: UnitSpeed.self)

        speedContinuation.yield(Measurement(value: 20, unit: .milesPerHour))
        unitsContinuation.yield(.kilometersPerHour)

        let converted = speedStream.inUnits(unitsStream)
        var iterator = converted.makeAsyncIterator()
        let result = try #require(await iterator.next())

        #expect(result.unit == .kilometersPerHour)
        #expect(abs(result.value - 32.1869) <= 0.1)

        speedContinuation.finish()
        unitsContinuation.finish()
    }

    @Test("Updates UnitSpeed measurements when units change")
    func speedConversionUpdates() async throws {
        let (speedStream, speedContinuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)
        let (unitsStream, unitsContinuation) = AsyncStream.makeStream(of: UnitSpeed.self)

        speedContinuation.yield(Measurement(value: 10, unit: .metersPerSecond))
        unitsContinuation.yield(.kilometersPerHour)

        let converted = speedStream.inUnits(unitsStream)
        var iterator = converted.makeAsyncIterator()

        let firstValue = try #require(await iterator.next())
        #expect(firstValue.unit == .kilometersPerHour)
        #expect(abs(firstValue.value - 36.0) <= 0.1)

        unitsContinuation.yield(.milesPerHour)

        let secondValue = try #require(await iterator.next())
        #expect(secondValue.unit == .milesPerHour)
        #expect(abs(secondValue.value - 22.3694) <= 0.1)

        speedContinuation.finish()
        unitsContinuation.finish()
    }

    @Test("Converts UnitLength measurements correctly")
    func lengthConversion() async throws {
        let (distanceStream, distanceContinuation) = AsyncStream.makeStream(of: Measurement<UnitLength>.self)
        let (unitsStream, unitsContinuation) = AsyncStream.makeStream(of: UnitLength.self)

        distanceContinuation.yield(Measurement(value: 10, unit: .miles))
        unitsContinuation.yield(.kilometers)

        let converted = distanceStream.inUnits(unitsStream)
        var iterator = converted.makeAsyncIterator()
        let result = try #require(await iterator.next())

        #expect(result.unit == .kilometers)
        #expect(abs(result.value - 16.0934) <= 0.01)

        distanceContinuation.finish()
        unitsContinuation.finish()
    }

    @Test("Updates UnitLength measurements when units change")
    func lengthConversionUpdates() async throws {
        let (distanceStream, distanceContinuation) = AsyncStream.makeStream(of: Measurement<UnitLength>.self)
        let (unitsStream, unitsContinuation) = AsyncStream.makeStream(of: UnitLength.self)

        distanceContinuation.yield(Measurement(value: 5, unit: .kilometers))
        unitsContinuation.yield(.meters)

        let converted = distanceStream.inUnits(unitsStream)
        var iterator = converted.makeAsyncIterator()

        let firstValue = try #require(await iterator.next())
        #expect(firstValue.unit == .meters)
        #expect(abs(firstValue.value - 5000.0) <= 0.1)

        unitsContinuation.yield(.miles)

        let secondValue = try #require(await iterator.next())
        #expect(secondValue.unit == .miles)
        #expect(abs(secondValue.value - 3.10686) <= 0.01)

        distanceContinuation.finish()
        unitsContinuation.finish()
    }

    @Test("Updates UnitSpeed when source measurement changes")
    func speedMeasurementUpdate() async throws {
        let (speedStream, speedContinuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)
        let (unitsStream, unitsContinuation) = AsyncStream.makeStream(of: UnitSpeed.self)

        speedContinuation.yield(Measurement(value: 10, unit: .kilometersPerHour))
        unitsContinuation.yield(.milesPerHour)

        let converted = speedStream.inUnits(unitsStream)
        var iterator = converted.makeAsyncIterator()

        let firstValue = try #require(await iterator.next())
        #expect(abs(firstValue.value - 6.21371) <= 0.01)

        speedContinuation.yield(Measurement(value: 20, unit: .kilometersPerHour))

        let secondValue = try #require(await iterator.next())
        #expect(abs(secondValue.value - 12.4274) <= 0.01)

        speedContinuation.finish()
        unitsContinuation.finish()
    }

    @Test("Converts available snapshot values correctly")
    func snapshotSpeedConversion() async throws {
        let (snapshotsStream, snapshotsContinuation) = AsyncStream.makeStream(
            of: MetricSnapshot<Measurement<UnitSpeed>>.self,
        )
        let (unitsStream, unitsContinuation) = AsyncStream.makeStream(of: UnitSpeed.self)

        snapshotsContinuation.yield(.available(
            value: Measurement(value: 20, unit: .milesPerHour),
            source: .phone,
        ))
        unitsContinuation.yield(.kilometersPerHour)

        let converted = snapshotsStream.inUnits(unitsStream)
        var iterator = converted.makeAsyncIterator()
        let result = try #require(await iterator.next())

        guard case .available(let value, let source) = result else {
            Issue.record("Expected available snapshot")
            return
        }
        #expect(value.unit == .kilometersPerHour)
        #expect(abs(value.value - 32.1869) <= 0.1)
        #expect(source == .phone)

        snapshotsContinuation.finish()
        unitsContinuation.finish()
    }

    @Test("Snapshot inUnits re-emits when units change")
    func snapshotSpeedConversionUpdates() async throws {
        let (snapshotsStream, snapshotsContinuation) = AsyncStream.makeStream(
            of: MetricSnapshot<Measurement<UnitSpeed>>.self,
        )
        let (unitsStream, unitsContinuation) = AsyncStream.makeStream(of: UnitSpeed.self)

        snapshotsContinuation.yield(.available(
            value: Measurement(value: 10, unit: .metersPerSecond),
            source: .bluetooth,
        ))
        unitsContinuation.yield(.kilometersPerHour)

        let converted = snapshotsStream.inUnits(unitsStream)
        var iterator = converted.makeAsyncIterator()

        let firstValue = try #require(await iterator.next())
        guard case .available(let firstMeasurement, let firstSource) = firstValue else {
            Issue.record("Expected available snapshot")
            return
        }
        #expect(firstMeasurement.unit == .kilometersPerHour)
        #expect(abs(firstMeasurement.value - 36.0) <= 0.1)
        #expect(firstSource == .bluetooth)

        unitsContinuation.yield(.milesPerHour)

        let secondValue = try #require(await iterator.next())
        guard case .available(let secondMeasurement, let secondSource) = secondValue else {
            Issue.record("Expected available snapshot")
            return
        }
        #expect(secondMeasurement.unit == .milesPerHour)
        #expect(abs(secondMeasurement.value - 22.3694) <= 0.1)
        #expect(secondSource == .bluetooth)

        snapshotsContinuation.finish()
        unitsContinuation.finish()
    }

    @Test("Snapshot inUnits passes unavailable through")
    func snapshotUnavailablePassesThrough() async throws {
        let (snapshotsStream, snapshotsContinuation) = AsyncStream.makeStream(
            of: MetricSnapshot<Measurement<UnitSpeed>>.self,
        )
        let (unitsStream, unitsContinuation) = AsyncStream.makeStream(of: UnitSpeed.self)

        snapshotsContinuation.yield(.unavailable)
        unitsContinuation.yield(.milesPerHour)

        let converted = snapshotsStream.inUnits(unitsStream)
        var iterator = converted.makeAsyncIterator()
        let result = try #require(await iterator.next())

        #expect(result == .unavailable)

        snapshotsContinuation.finish()
        unitsContinuation.finish()
    }
}
