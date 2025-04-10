//
//  NotificationManager.swift
//  PlanIt
//
//  Created by Sean Bremer on 4/10/25.
//

import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // This function schedules a notification for an event.
    func scheduleNotification(for event: Event) {
        // Create the notification content for the initial event
        let content = UNMutableNotificationContent()
        content.title = "Event Reminder"
        content.body = event.name
        content.sound = .default
        
        // Create the notification trigger for the event time
        let trigger = UNCalendarNotificationTrigger(dateMatching: getDateComponents(for: event.date), repeats: false)
        
        let request = UNNotificationRequest(identifier: event.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
        
        // If notify5MinutesBefore is true, schedule a notification 5 minutes before the event
        if event.notify5MinutesBefore {
            scheduleNotification5MinutesBefore(for: event)
        }
        
        // Schedule notifications for 1 minute after the event time, up to 5 minutes after
        scheduleNotificationsAfterEvent(for: event)
        
        // If the event repeats, schedule future notifications
        if event.repeats {
            scheduleRepeatingNotifications(for: event, startingAt: event.date)
        }
    }
    
    // Schedules a notification 5 minutes before the event time
    private func scheduleNotification5MinutesBefore(for event: Event) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder: 5 minutes left"
        content.body = event.name
        content.sound = .default
        
        // 5 minutes before the event
        let fiveMinutesBefore = event.date.addingTimeInterval(-5 * 60)
        let trigger = UNCalendarNotificationTrigger(dateMatching: getDateComponents(for: fiveMinutesBefore), repeats: false)
        
        let request = UNNotificationRequest(identifier: "\(event.id.uuidString)_5minBefore", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule 5 minutes before notification: \(error)")
            }
        }
    }
    
    // Schedules notifications at the time of and every minute after the event time
    private func scheduleNotificationsAfterEvent(for event: Event) {
        let calendar = Calendar.current
        var nextTriggerDate = event.date
        
        // Schedule at the event time
        let content = UNMutableNotificationContent()
        content.title = "Event Started"
        content.body = event.name
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: getDateComponents(for: nextTriggerDate), repeats: false)
        
        let request = UNNotificationRequest(identifier: "\(event.id.uuidString)_atTime", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule at time notification: \(error)")
            }
        }
        
        // Schedule every minute for the next 5 minutes after the event time
        for i in 1...5 {
            let minuteAfterEvent = event.date.addingTimeInterval(Double(i * 60))
            let contentAfterEvent = UNMutableNotificationContent()
            contentAfterEvent.title = "Event Ongoing"
            contentAfterEvent.body = event.name
            contentAfterEvent.sound = .default
            
            let triggerAfterEvent = UNCalendarNotificationTrigger(dateMatching: getDateComponents(for: minuteAfterEvent), repeats: false)
            
            let requestAfterEvent = UNNotificationRequest(identifier: "\(event.id.uuidString)_minuteAfter_\(i)", content: contentAfterEvent, trigger: triggerAfterEvent)
            UNUserNotificationCenter.current().add(requestAfterEvent) { error in
                if let error = error {
                    print("Failed to schedule minute after notification: \(error)")
                }
            }
        }
    }
    
    // Schedules repeating notifications for an event
    private func scheduleRepeatingNotifications(for event: Event, startingAt startDate: Date) {
        let calendar = Calendar.current
        var nextTriggerDate = startDate
        var repeatCount = event.repeatCount
        
        // Loop through future events based on recurrence
        while (event.repeatEnds && repeatCount > 0) || !event.repeatEnds {
            nextTriggerDate = getNextOccurrence(after: nextTriggerDate, repeatInterval: event.repeatCount)
            
            // Stop scheduling if we reach the repeatUntil date
            if nextTriggerDate > event.repeatUntil {
                break
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Repeating Event Reminder"
            content.body = event.name
            content.sound = .default
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: getDateComponents(for: nextTriggerDate), repeats: false)
            
            let request = UNNotificationRequest(identifier: "\(event.id.uuidString)_\(nextTriggerDate)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule repeating notification: \(error)")
                }
            }
            
            // If repeatEnds is true, decrease repeatCount
            if event.repeatEnds {
                repeatCount -= 1
            }
        }
    }
    
    // Determine the next occurrence based on the repeat interval
    private func getNextOccurrence(after date: Date, repeatInterval: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: repeatInterval, to: date)!
    }
    
    // Converts a date to DateComponents
    private func getDateComponents(for date: Date) -> DateComponents {
        let calendar = Calendar.current
        return calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
    }
}
