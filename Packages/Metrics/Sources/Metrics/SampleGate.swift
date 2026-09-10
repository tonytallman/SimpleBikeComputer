import AsyncAlgorithms
import Foundation

extension AsyncSequence where Failure == Never, Element: Sendable, Self: Sendable {
    /// Forwards elements only while motion state is `.moving`.
    /// When paused, samples are dropped. Activity-only changes do not re-emit the last sample.
    public func gated<Activity: AsyncSequence>(
        by activity: Activity,
    ) -> AsyncStream<Element>
    where
        Activity.Element == MotionState,
        Activity.Failure == Never,
        Activity: Sendable
    {
        AsyncStream { continuation in
            let task = Task {
                let (taggedStream, taggedContinuation) = AsyncStream.makeStream(of: Tagged<Element>.self)

                let taggingTask = Task {
                    var seq = 0
                    for await value in self {
                        guard !Task.isCancelled else { return }

                        seq += 1
                        taggedContinuation.yield(Tagged(seq: seq, value: value))
                    }
                    taggedContinuation.finish()
                }

                let combined = combineLatest(taggedStream, activity)
                var lastSeq = 0

                for await (tagged, motionState) in combined {
                    guard !Task.isCancelled else { return }

                    if motionState == .moving, tagged.seq != lastSeq {
                        continuation.yield(tagged.value)
                    }
                    lastSeq = tagged.seq
                }

                taggingTask.cancel()
                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}

private struct Tagged<Element: Sendable>: Sendable {
    let seq: Int
    let value: Element
}
