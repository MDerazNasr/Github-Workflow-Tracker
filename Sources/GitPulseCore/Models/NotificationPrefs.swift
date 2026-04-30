import Foundation
import SwiftData

@Model
final class NotificationPrefs {
    @Attribute(.unique) var eventTypeRaw: String
    var banner: Bool
    var badge: Bool
    var sound: Bool

    init(eventTypeRaw: String, banner: Bool = true, badge: Bool = true, sound: Bool = false) {
        self.eventTypeRaw = eventTypeRaw
        self.banner = banner
        self.badge = badge
        self.sound = sound
    }

    var eventType: EventType? {
        EventType(rawValue: eventTypeRaw)
    }

    static func defaultFor(_ type: EventType) -> NotificationPrefs {
        NotificationPrefs(eventTypeRaw: type.rawValue)
    }

    static func ensureDefaults(in context: ModelContext) {
        let descriptor = FetchDescriptor<NotificationPrefs>()
        let existing = (try? context.fetch(descriptor)) ?? []
        let existingTypes = Set(existing.map(\.eventTypeRaw))

        for type in EventType.allNotifiableCases where !existingTypes.contains(type.rawValue) {
            context.insert(NotificationPrefs.defaultFor(type))
        }

        try? context.save()
    }
}
