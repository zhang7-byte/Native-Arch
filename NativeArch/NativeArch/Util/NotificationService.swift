import Foundation
import UserNotifications

/// Local deadline reminders via UserNotifications. Reschedules on launch and
/// whenever tasks or settings change.
enum NotificationService {
    static func requestAuthorization() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    /// Clear and re-create pending reminders for open tasks with a future due
    /// date (fired at 09:00 local on the due day), plus an optional daily
    /// "today's schedule" summary. `notifyFrequency == "off"` cancels everything.
    static func reschedule(tasks: [Task], settings: AppSettings) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        guard settings.notifyFrequency != "off" else { return }

        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        for t in tasks where t.status != .done {
            guard let due = t.dueDate, due >= today else { continue }
            var comps = cal.dateComponents([.year, .month, .day], from: due)
            comps.hour = 9
            let content = UNMutableNotificationContent()
            content.title = "Task due"
            content.body = t.title
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            center.add(UNNotificationRequest(identifier: "task-\(t.id)",
                                             content: content, trigger: trigger))
        }

        if settings.scheduleNotify {
            let content = UNMutableNotificationContent()
            content.title = "Today's schedule"
            content.body = "Review today's tasks and deadlines."
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: DateComponents(hour: 8), repeats: true)
            center.add(UNNotificationRequest(identifier: "daily-summary",
                                             content: content, trigger: trigger))
        }
    }
}
