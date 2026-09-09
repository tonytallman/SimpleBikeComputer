import Foundation

public protocol SystemSettings: Sendable {
    var keepScreenOn: AsyncStream<Bool> { get }
    func setKeepScreenOn(_ keepOn: Bool)
}

public final class DefaultSystemSettings: SystemSettings, @unchecked Sendable {
    private let storage: SettingsStorage
    private let keepScreenOnBroadcaster: CurrentValueBroadcaster<Bool>

    private static let keepScreenOnKey = "keepScreenOn"

    public var keepScreenOn: AsyncStream<Bool> {
        keepScreenOnBroadcaster.makeStream()
    }

    public init(storage: SettingsStorage) {
        self.storage = storage

        let keepScreenOn = (storage.get(forKey: Self.keepScreenOnKey) as? Bool) ?? true
        keepScreenOnBroadcaster = CurrentValueBroadcaster(initial: keepScreenOn)
    }

    public func setKeepScreenOn(_ keepOn: Bool) {
        keepScreenOnBroadcaster.send(keepOn)
        storage.set(value: keepOn, forKey: Self.keepScreenOnKey)
    }
}
