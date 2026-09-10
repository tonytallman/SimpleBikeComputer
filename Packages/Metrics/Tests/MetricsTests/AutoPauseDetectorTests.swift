import Foundation
import Metrics
import Testing

@Suite("AutoPauseDetector Tests")
struct AutoPauseDetectorTests {
    @Test("Emits moving when speed is above threshold")
    func movingWhenSpeedAboveThreshold() async throws {
        let (speedStream, speedContinuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)
        let (thresholdStream, thresholdContinuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)

        speedContinuation.yield(Measurement(value: 5, unit: .milesPerHour))
        thresholdContinuation.yield(Measurement(value: 3, unit: .milesPerHour))

        let detector = AutoPauseDetector(speed: speedStream, threshold: thresholdStream)
        var iterator = detector.states.makeAsyncIterator()
        let state = try #require(await iterator.next())

        #expect(state == .moving)

        speedContinuation.finish()
        thresholdContinuation.finish()
    }

    @Test("Emits moving when speed equals threshold")
    func movingWhenSpeedEqualsThreshold() async throws {
        let (speedStream, speedContinuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)
        let (thresholdStream, thresholdContinuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)

        speedContinuation.yield(Measurement(value: 3, unit: .milesPerHour))
        thresholdContinuation.yield(Measurement(value: 3, unit: .milesPerHour))

        let detector = AutoPauseDetector(speed: speedStream, threshold: thresholdStream)
        var iterator = detector.states.makeAsyncIterator()
        _ = await iterator.next()
        let state = try #require(await iterator.next())

        #expect(state == .moving)

        speedContinuation.finish()
        thresholdContinuation.finish()
    }

    @Test("Emits paused when speed is below threshold")
    func pausedWhenSpeedBelowThreshold() async throws {
        let (speedStream, speedContinuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)
        let (thresholdStream, thresholdContinuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)

        speedContinuation.yield(Measurement(value: 2, unit: .milesPerHour))
        thresholdContinuation.yield(Measurement(value: 3, unit: .milesPerHour))

        let detector = AutoPauseDetector(speed: speedStream, threshold: thresholdStream)
        var iterator = detector.states.makeAsyncIterator()
        _ = await iterator.next()
        let state = try #require(await iterator.next())

        #expect(state == .paused)

        speedContinuation.finish()
        thresholdContinuation.finish()
    }

    @Test("Transitions from moving to paused when speed drops")
    func transitionMovingToPaused() async throws {
        let (speedStream, speedContinuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)
        let (thresholdStream, thresholdContinuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)

        speedContinuation.yield(Measurement(value: 5, unit: .milesPerHour))
        thresholdContinuation.yield(Measurement(value: 3, unit: .milesPerHour))

        let detector = AutoPauseDetector(speed: speedStream, threshold: thresholdStream)
        var iterator = detector.states.makeAsyncIterator()
        _ = await iterator.next()
        let initial = try #require(await iterator.next())
        #expect(initial == .moving)

        speedContinuation.yield(Measurement(value: 2, unit: .milesPerHour))
        let updated = try #require(await iterator.next())
        #expect(updated == .paused)

        speedContinuation.finish()
        thresholdContinuation.finish()
    }

    @Test("Transitions from paused to moving when speed rises")
    func transitionPausedToMoving() async throws {
        let (speedStream, speedContinuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)
        let (thresholdStream, thresholdContinuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)

        speedContinuation.yield(Measurement(value: 2, unit: .milesPerHour))
        thresholdContinuation.yield(Measurement(value: 3, unit: .milesPerHour))

        let detector = AutoPauseDetector(speed: speedStream, threshold: thresholdStream)
        var iterator = detector.states.makeAsyncIterator()
        _ = await iterator.next()
        let first = try #require(await iterator.next())
        #expect(first == .paused)

        speedContinuation.yield(Measurement(value: 5, unit: .milesPerHour))
        let second = try #require(await iterator.next())
        #expect(second == .moving)

        speedContinuation.finish()
        thresholdContinuation.finish()
    }

    @Test("Handles threshold changes correctly")
    func thresholdChanges() async throws {
        let (speedStream, speedContinuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)
        let (thresholdStream, thresholdContinuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)

        speedContinuation.yield(Measurement(value: 4, unit: .milesPerHour))
        thresholdContinuation.yield(Measurement(value: 3, unit: .milesPerHour))

        let detector = AutoPauseDetector(speed: speedStream, threshold: thresholdStream)
        var iterator = detector.states.makeAsyncIterator()
        _ = await iterator.next()
        let initial = try #require(await iterator.next())
        #expect(initial == .moving)

        thresholdContinuation.yield(Measurement(value: 5, unit: .milesPerHour))
        let second = try #require(await iterator.next())
        #expect(second == .paused)

        thresholdContinuation.yield(Measurement(value: 2, unit: .milesPerHour))
        let third = try #require(await iterator.next())
        #expect(third == .moving)

        speedContinuation.finish()
        thresholdContinuation.finish()
    }

    @Test("Works with different speed units")
    func differentSpeedUnits() async throws {
        let (speedStream, speedContinuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)
        let (thresholdStream, thresholdContinuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)

        speedContinuation.yield(Measurement(value: 10, unit: .kilometersPerHour))
        thresholdContinuation.yield(Measurement(value: 3, unit: .milesPerHour))

        let detector = AutoPauseDetector(speed: speedStream, threshold: thresholdStream)
        var iterator = detector.states.makeAsyncIterator()
        _ = await iterator.next()
        let state = try #require(await iterator.next())

        #expect(state == .moving)

        speedContinuation.finish()
        thresholdContinuation.finish()
    }

    @Test("Does not emit duplicate states")
    func noDuplicateStates() async throws {
        let (speedStream, speedContinuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)
        let (thresholdStream, thresholdContinuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)

        speedContinuation.yield(Measurement(value: 5, unit: .milesPerHour))
        thresholdContinuation.yield(Measurement(value: 3, unit: .milesPerHour))

        let detector = AutoPauseDetector(speed: speedStream, threshold: thresholdStream)
        var iterator = detector.states.makeAsyncIterator()
        _ = await iterator.next()
        let initial = try #require(await iterator.next())
        #expect(initial == .moving)

        speedContinuation.yield(Measurement(value: 5, unit: .milesPerHour))
        speedContinuation.yield(Measurement(value: 5, unit: .milesPerHour))
        speedContinuation.yield(Measurement(value: 5, unit: .milesPerHour))
        speedContinuation.finish()
        thresholdContinuation.finish()

        let next = await iterator.next()
        #expect(next == nil)
    }

    @Test("Seeds paused before first speed and threshold pair")
    func seedsPaused() async throws {
        let (speedStream, speedContinuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)
        let (thresholdStream, thresholdContinuation) = AsyncStream.makeStream(of: Measurement<UnitSpeed>.self)

        let detector = AutoPauseDetector(speed: speedStream, threshold: thresholdStream)
        var iterator = detector.states.makeAsyncIterator()
        let state = try #require(await iterator.next())

        #expect(state == .paused)

        speedContinuation.finish()
        thresholdContinuation.finish()
    }
}
