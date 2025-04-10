//
//  EventList.swift
//  PlanIt
//
//  Created by Sean Bremer on 4/5/25.
//

import SwiftUI
import SwiftData

struct EventList: View {
    @Query(sort: \Event.date) private var events: [Event]
    @Environment(\.modelContext) private var context
    @State private var newEvent: Event?

    var body: some View {
        NavigationStack {
            VStack {
                if events.isEmpty {
                    ContentUnavailableView("No Events", systemImage: "calendar.badge.exclamationmark")
                } else {
                    List {
                        ForEach(events) { event in
                            NavigationLink {
                                EventDetail(event: event)
                            } label: {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(event.name)
                                            .font(.headline)
                                        
                                        Spacer()
                                        
                                        Text(formattedDate(event.date)) // Show formatted date
                                            .foregroundColor(.secondary)
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
            .navigationBarTitleDisplayMode(.inline) // No title at top
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
        }
    }

    private func addEvent() {
        let event = Event(name: "", date: .now)
        context.insert(event)
        newEvent = event
    }

    private func deleteEvents(at offsets: IndexSet) {
        for index in offsets {
            context.delete(events[index])
        }
        try? context.save()
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
