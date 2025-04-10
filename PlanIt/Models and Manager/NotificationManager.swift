//
//  NotificationManager.swift
//  PlanIt
//
//  Created by Sean Bremer on 4/10/25.
//

//  NotificationManager.swift
//  PlanIt
//
//  Created by Sean Bremer on 4/10/25.
//

//  NotificationManager.swift
//  PlanIt
//
//  Created by Sean Bremer on 4/10/25.
//

import SwiftUI
import SwiftData
import UserNotifications

class NotificationManager {
    @Query(sort: \Event.date) private var allEvents: [Event]
    
    static let shared = NotificationManager()
    private init() {}

    // This will update all notifications for events in the next 14 days
    func updateNotifications() {
        let events = getEventsWithinNext14Days()

        // Loop through each event and update notifications
        for event in events {
            addNotifications(for: event)
        }
    }

    private func getEventsWithinNext14Days() -> [Event] {
        let calendar = Calendar.current
        let today = Date()
        let fourteenDaysLater = calendar.date(byAdding: .day, value: 14, to: today)!
        
        return allEvents.filter { event in
            event.date >= today && event.date <= fourteenDaysLater
        }
    }

    // Add notifications for a single event
    func addNotifications(for event: Event) {
        // Remove existing notifications for this specific event
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let eventID = event.id.uuidString
            let matchingIDs = requests
                .map { $0.identifier }
                .filter { $0.contains(eventID) }

            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: matchingIDs)

            // Now schedule all relevant notifications
            self.scheduleNotificationsForNext14Days(for: event)
        }
    }

    private func scheduleNotificationsForNext14Days(for event: Event) {
        let calendar = Calendar.current
        let now = Date()
        let endDate = calendar.date(byAdding: .day, value: 14, to: now)!

        var occurrenceDate = event.date

        // Loop through every occurrence of the event within the next 14 days
        while occurrenceDate <= endDate {
            // Schedule notifications only if the occurrence is not in the past
            if occurrenceDate >= now {
                // If repeatEnds is true, consider repeatUntil
                if event.repeatEnds {
                    if occurrenceDate <= event.repeatUntil {
                        scheduleAllNotifications(for: event, at: occurrenceDate)
                    }
                } else {
                    scheduleAllNotifications(for: event, at: occurrenceDate)
                }
            }

            // If the event repeats, calculate the next occurrence
            guard event.repeats else { break }

            // Check if the repeat ends before the repeatUntil date
            if event.repeatEnds, occurrenceDate >= event.repeatUntil {
                break
            }

            // Get the next occurrence date based on the repeat interval
            guard let nextDate = getNextOccurrence(after: occurrenceDate, event: event) else { break }
            occurrenceDate = nextDate
        }
    }

    private func scheduleAllNotifications(for event: Event, at date: Date) {
        let baseID = "\(event.id.uuidString)_\(date.timeIntervalSince1970)"

        // 5 minutes before
        if event.notify5MinutesBefore {
            let fiveMinBefore = date.addingTimeInterval(-5 * 60)
            scheduleNotification(
                title: event.name,
                body: "\(event.name) in 5 minutes",
                date: fiveMinBefore,
                id: "\(baseID)_5minBefore"
            )
        }

        // At time and 1-5 minutes after
        for i in 0...5 {
            let notificationDate = date.addingTimeInterval(Double(i * 60))
            let title = event.name
            let suffix = i == 0 ? "atTime" : "minAfter_\(i)"

            scheduleNotification(
                title: title,
                body: "\(event.name)" + (i == 0 ? "" : " \(i)" + (i == 1 ? " minute ago" : " minutes ago")),
                date: notificationDate,
                id: "\(baseID)_\(suffix)"
            )
        }
    }

    private func scheduleNotification(title: String, body: String, date: Date, id: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date),
            repeats: false
        )

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification [\(id)]: \(error)")
            }
        }
    }

    private func getNextOccurrence(after date: Date, event: Event) -> Date? {
        let calendar = Calendar.current
        let count = event.repeatCount

        switch event.repeatUnit {
        case "days":
            return calendar.date(byAdding: .day, value: count, to: date)
        case "weeks":
            return calendar.date(byAdding: .day, value: 7 * count, to: date)
        case "months":
            return calendar.date(byAdding: .month, value: count, to: date)
        case "years":
            return calendar.date(byAdding: .year, value: count, to: date)
        default:
            return nil
        }
    }
}
