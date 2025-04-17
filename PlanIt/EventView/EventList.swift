//
//  EventList.swift
//  PlanIt
//
//  Created by Sean Bremer on 4/5/25.
//

import SwiftUI
import SwiftData

struct EventList: View {
    @Query(sort: \Event.date) private var allEvents: [Event]
    @Environment(\.modelContext) private var context
    @State private var newEvent: Event?
    @State private var nextOccurrences: [UUID: Date] = [:]

    var body: some View {
        NavigationStack {
            VStack {
                let validEvents = getValidEvents(from: allEvents)
                
                if validEvents.isEmpty {
                    ContentUnavailableView("No Future Events", systemImage: "calendar.badge.exclamationmark")
                } else {
                    List {
                        ForEach(validEvents) { event in
                            NavigationLink {
                                EventDetail(event: event)
                            } label: {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(event.name)
                                            .font(.headline)
                                        
                                        Spacer()
                                        
                                        // Show original date or next occurrence
                                        if let nextDate = nextOccurrences[event.id] {
                                            Text(formattedDate(nextDate))
                                                .foregroundColor(.secondary)
                                        } else {
                                            Text(formattedDate(event.date))
                                                .foregroundColor(.secondary)
                                        }
                                    }

                                    // Show "Next occurrence" if the original date has passed
                                    if let nextDate = nextOccurrences[event.id],
                                       event.date < Date() {
                                        Text("Next: \(formattedDate(nextDate))")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }

                                    // Repeat info (if applicable)
                                    if event.repeats {
                                        HStack {
                                            Image(systemName: "repeat")
                                            Text(repeatText(for: event))
                                        }
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    }

                                    // 5-minute reminder info (if applicable)
                                    if event.notify5MinutesBefore {
                                        HStack {
                                            Image(systemName: "bell.fill")
                                            Text("5 minute reminder")
                                        }
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .onDelete(perform: deleteEvents)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: addEvent) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $newEvent) { event in
                NavigationStack {
                    EventDetail(event: event, isNew: true)
                }
                .interactiveDismissDisabled()
            }
            .onAppear {
                calculateNextOccurrences(for: allEvents)
            }
        }
    }

    private func addEvent() {
        let event = Event(name: "", date: .now)
        context.insert(event)
        newEvent = event
    }

    private func deleteEvents(at offsets: IndexSet) {
        let validEvents = getValidEvents(from: allEvents)
        
        // Retrieve the event IDs for the events being deleted
        let deletedEventIDs = offsets.compactMap { validEvents[$0].id }

        // Delete events
        for index in offsets {
            context.delete(validEvents[index])
        }
        
        // Remove notifications related to the deleted events
        NotificationManager.shared.removeNotifications(forEventIDs: deletedEventIDs)

        // Save the context after deleting the events
        try? context.save()
    }


    private func getValidEvents(from events: [Event]) -> [Event] {
        return events.filter { event in
            // Non-repeating events - show if date is in the future
            if !event.repeats {
                return event.date >= Date()
            }
            
            // Repeating events - check if we have a next occurrence
            if let _ = nextOccurrences[event.id] {
                // If there's a next occurrence within valid period, include it
                return true
            }
            
            // Default case - include original events that haven't passed
            return event.date >= Date()
        }.sorted { first, second in
            // Sort by next occurrence date or original date
            let firstDate = nextOccurrences[first.id] ?? first.date
            let secondDate = nextOccurrences[second.id] ?? second.date
            return firstDate < secondDate
        }
    }

    private func calculateNextOccurrences(for events: [Event]) {
        let now = Date()
        var updatedOccurrences: [UUID: Date] = [:]
        
        for event in events {
            if event.repeats && event.date < now {
                // Only calculate for repeating events that have already passed
                if let nextDate = calculateNextOccurrence(for: event, after: now) {
                    updatedOccurrences[event.id] = nextDate
                }
            }
        }
        
        nextOccurrences = updatedOccurrences
    }

    private func calculateNextOccurrence(for event: Event, after date: Date) -> Date? {
        let calendar = Calendar.current
        let originalDate = event.date
        
        // If event doesn't repeat, there's no next occurrence
        if !event.repeats {
            return nil
        }
        
        // If repeat has an end date and it's already passed, there's no next occurrence
        if event.repeatEnds && event.repeatUntil < date {
            return nil
        }
        
        var nextDate = originalDate
        let repeatCount = event.repeatCount
        
        // Keep adding repeat intervals until we find the next occurrence after the given date
        while nextDate < date {
            var dateComponents = DateComponents()
            
            switch event.repeatUnit {
            case "days":
                dateComponents.day = repeatCount
            case "weeks":
                dateComponents.day = repeatCount * 7
            case "months":
                dateComponents.month = repeatCount
            case "years":
                dateComponents.year = repeatCount
            default:
                dateComponents.day = repeatCount
            }
            
            if let newDate = calendar.date(byAdding: dateComponents, to: nextDate) {
                nextDate = newDate
            } else {
                // If calculation fails, break to avoid infinite loop
                break
            }
            
            // Check if we've gone beyond the repeat until date
            if event.repeatEnds && nextDate > event.repeatUntil {
                return nil
            }
        }
        
        return nextDate
    }

    private func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            return "Today, " + timeFormatter.string(from: date)
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow, " + timeFormatter.string(from: date)
        } else {
            let eventYear = calendar.component(.year, from: date)
            let currentYear = calendar.component(.year, from: now)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = eventYear == currentYear ? "MMM d, h:mm a" : "MMM d, yyyy, h:mm a"
            return dateFormatter.string(from: date)
        }
    }

    private func repeatText(for event: Event) -> String {
        // Handle repeat info (if applicable)
        let count = event.repeatCount
        let unit = event.repeatUnit
        
        let formattedUnit: String
        switch unit {
            case "days":
                formattedUnit = count == 1 ? "day" : "days"
            case "weeks":
                formattedUnit = count == 1 ? "week" : "weeks"
            case "months":
                formattedUnit = count == 1 ? "month" : "months"
            case "years":
                formattedUnit = count == 1 ? "year" : "years"
            default:
                formattedUnit = unit
        }

        if event.repeatEnds == false {
            if count == 1 {
                return "Repeats every \(formattedUnit)"
            } else {
                return "Repeats every \(count) \(formattedUnit)"
            }
        }

        if count == 1 {
            return "Repeats every \(formattedUnit) until \(shortDateFormatter.string(from: event.repeatUntil))"
        } else {
            return "Repeats every \(count) \(formattedUnit) until \(shortDateFormatter.string(from: event.repeatUntil))"
        }
    }

    private var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()

    private var shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

#Preview {
    EventList()
        .modelContainer(SampleData.shared.modelContainer)
}
