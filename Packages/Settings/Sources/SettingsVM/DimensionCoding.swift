import Foundation

public enum SpeedUnitKey: String, CaseIterable, Sendable {
    case milesPerHour
    case kilometersPerHour

    public var unit: UnitSpeed {
        switch self {
        case .milesPerHour: .milesPerHour
        case .kilometersPerHour: .kilometersPerHour
        }
    }

    public init?(unit: UnitSpeed) {
        if unit == .milesPerHour {
            self = .milesPerHour
        } else if unit == .kilometersPerHour {
            self = .kilometersPerHour
        } else {
            return nil
        }
    }
}

public enum DistanceUnitKey: String, CaseIterable, Sendable {
    case miles
    case kilometers

    public var unit: UnitLength {
        switch self {
        case .miles: .miles
        case .kilometers: .kilometers
        }
    }

    public init?(unit: UnitLength) {
        if unit == .miles {
            self = .miles
        } else if unit == .kilometers {
            self = .kilometers
        } else {
            return nil
        }
    }
}
