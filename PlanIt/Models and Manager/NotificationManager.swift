//
//  NotificationManager.swift
//  PlanIt
//
//  Created by Sean Bremer on 4/10/25.
//

import Foundation
import UserNotifications
import BackgroundTasks

class NotificationManager {
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()

    private init() {
        // Register the background task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.planit.refreshNotifications", using: nil) { task in
            self.handleBackgroundRefresh(task: task)
        }
    }

    // Function to schedule notifications for events
    func scheduleNotifications(for event: Event) {
        removeNotifications(for: event)

        let baseDates = upcomingOccurrences(for: event)
        for date in baseDates {
            scheduleNotifications(for: event, at: date)
        }

        // Schedule background task to refresh notifications in the future
        scheduleBackgroundTask()
    }

    // Remove existing notifications
    func removeNotifications(for event: Event) {
        let identifiers = (0...5).flatMap { i in
            upcomingOccurrences(for: event).map { occurrenceDate in
                notificationIdentifier(for: event, date: occurrenceDate, offsetMinutes: i == 0 ? -5 : i - 1)
            }
        }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // Schedule notifications for a specific date
    private func scheduleNotifications(for event: Event, at date: Date) {
        let calendar = Calendar.current

        // Notify 5 minutes before the event if enabled
        if event.notify5MinutesBefore {
            let beforeDate = calendar.date(byAdding: .minute, value: -5, to: date)!
            scheduleNotification(event: event, date: beforeDate, offsetMinutes: -5)
        }

        // Notify at the event time and every minute after for 5 minutes
        for minuteOffset in 0...5 {
            let notifyDate = calendar.date(byAdding: .minute, value: minuteOffset, to: date)!
            scheduleNotification(event: event, date: notifyDate, offsetMinutes: minuteOffset)
        }
    }

    // Helper function to schedule an individual notification
    private func scheduleNotification(event: Event, date: Date, offsetMinutes: Int) {
        let content = UNMutableNotificationContent()
        content.title = event.name
        content.body = offsetMinutes == -5
            ? "\(event.name) in 5 minutes" :
            offsetMinutes == 0 ? "\(event.name)" :
            "\(event.name) \(offsetMinutes) minutes ago"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        ), repeats: false)

        let request = UNNotificationRequest(
            identifier: notificationIdentifier(for: event, date: date, offsetMinutes: offsetMinutes),
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    // Helper function to generate a unique identifier for the notification
    private func notificationIdentifier(for event: Event, date: Date, offsetMinutes: Int) -> String {
        let formatter = ISO8601DateFormatter()
        return "\(event.id.uuidString)_\(formatter.string(from: date))_\(offsetMinutes)"
    }

    // Get upcoming occurrences for a repeating event
    private func upcomingOccurrences(for event: Event) -> [Date] {
        var dates: [Date] = []

        let calendar = Calendar.current
        var nextDate = event.date
        let now = Date()
        let endDate = event.repeatEnds ? event.repeatUntil : calendar.date(byAdding: .day, value: 30, to: now)!

        while nextDate <= endDate {
            if nextDate >= now {
                dates.append(nextDate)
            }

            // Calculate next occurrence based on repeat unit and count
            var dateComponent = DateComponents()
            switch event.repeatUnit {
            case "days": dateComponent.day = event.repeatCount
            case "weeks": dateComponent.day = event.repeatCount * 7
            case "months": dateComponent.month = event.repeatCount
            case "years": dateComponent.year = event.repeatCount
            default: break
            }

            guard let updatedDate = calendar.date(byAdding: dateComponent, to: nextDate) else { break }
            nextDate = updatedDate
        }

        return dates
    }

    // Schedule the background task for notification refresh
    private func scheduleBackgroundTask() {
        let request = BGProcessingTaskRequest(identifier: "com.planit.refreshNotifications")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60 * 24 * 1) // 1 day from now
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to submit background task: \(error)")
        }
    }

    // Handle the background task for refreshing notifications
    private func handleBackgroundRefresh(task: BGTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        // Perform the background refresh
        refreshAllNotifications()

        // Mark the background task as completed
        task.setTaskCompleted(success: true)
    }

    // Refresh all notifications for all events
    func refreshAllNotifications() {
        let events = getAllEvents() // Fetch your events from Core Data or your data source
        for event in events {
            scheduleNotifications(for: event)
        }
    }

    // Get all events (replace with your actual data fetching logic)
    private func getAllEvents() -> [Event] {
        // Fetch events from Core Data or another data source
        return [] // Return the actual events here
    }
}
