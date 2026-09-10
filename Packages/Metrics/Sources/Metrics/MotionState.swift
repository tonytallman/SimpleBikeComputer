import Foundation

/// Whether ride accumulation is active (moving) or paused.
public enum MotionState: Sendable, Equatable {
    case moving
    case paused
}
