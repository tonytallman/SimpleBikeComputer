import Foundation
import Metrics
import Testing

@Suite("SampleGate Tests")
struct SampleGateTests {
    @Test("Forwards samples while moving")
    func forwardsWhileMoving() async throws {
        let (sampleStream, sampleContinuation) = AsyncStream.makeStream(of: Int.self)
        let (activityStream, activityContinuation) = AsyncStream.makeStream(of: MotionState.self)

        activityContinuation.yield(.moving)
        sampleContinuation.yield(1)

        let gated = sampleStream.gated(by: activityStream)
        var iterator = gated.makeAsyncIterator()
        let value = try #require(await iterator.next())

        #expect(value == 1)

        sampleContinuation.finish()
        activityContinuation.finish()
    }

    @Test("Drops samples while paused")
    func dropsWhilePaused() async throws {
        let (sampleStream, sampleContinuation) = AsyncStream.makeStream(of: Int.self)
        let (activityStream, activityContinuation) = AsyncStream.makeStream(of: MotionState.self)

        activityContinuation.yield(.paused)
        sampleContinuation.yield(1)
        sampleContinuation.finish()
        activityContinuation.finish()

        let gated = sampleStream.gated(by: activityStream)
        var iterator = gated.makeAsyncIterator()
        let result = await iterator.next()

        #expect(result == nil)
    }

    @Test("Pauses forwarding when activity becomes paused")
    func pausesWhenActivityPaused() async throws {
        let (sampleStream, sampleContinuation) = AsyncStream.makeStream(of: Measurement<UnitLength>.self)
        let (activityStream, activityContinuation) = AsyncStream.makeStream(of: MotionState.self)

        activityContinuation.yield(.moving)
        sampleContinuation.yield(Measurement(value: 1, unit: .meters))

        let gated = sampleStream.gated(by: activityStream)
        var iterator = gated.makeAsyncIterator()
        let first = try #require(await iterator.next())
        #expect(first.value == 1)

        activityContinuation.yield(.paused)
        sampleContinuation.yield(Measurement(value: 2, unit: .meters))
        sampleContinuation.finish()
        activityContinuation.finish()

        let second = await iterator.next()
        #expect(second == nil)
    }

    @Test("Does not re-emit on state changes without a new sample")
    func noReemitOnStateChange() async throws {
        let (sampleStream, sampleContinuation) = AsyncStream.makeStream(of: Int.self)
        let (activityStream, activityContinuation) = AsyncStream.makeStream(of: MotionState.self)

        activityContinuation.yield(.moving)
        sampleContinuation.yield(1)

        let gated = sampleStream.gated(by: activityStream)
        var iterator = gated.makeAsyncIterator()
        let first = try #require(await iterator.next())
        #expect(first == 1)

        activityContinuation.yield(.paused)
        activityContinuation.yield(.moving)
        sampleContinuation.finish()
        activityContinuation.finish()

        let second = await iterator.next()
        #expect(second == nil)
    }

    @Test("Resumes forwarding the next new sample after pause")
    func resumesAfterPause() async throws {
        let (sampleStream, sampleContinuation) = AsyncStream.makeStream(of: Int.self)
        let (activityStream, activityContinuation) = AsyncStream.makeStream(of: MotionState.self)

        activityContinuation.yield(.moving)
        sampleContinuation.yield(1)

        let gated = sampleStream.gated(by: activityStream)
        var iterator = gated.makeAsyncIterator()
        let first = try #require(await iterator.next())
        #expect(first == 1)

        activityContinuation.yield(.paused)
        sampleContinuation.yield(2)

        activityContinuation.yield(.moving)
        sampleContinuation.yield(3)

        let third = try #require(await iterator.next())
        #expect(third == 3)

        sampleContinuation.finish()
        activityContinuation.finish()
    }
}
