//
//  EventsSheetView.swift
//  PlanIt
//
//  Created by Sean Bremer on 4/10/25.
//

import SwiftUI
import SwiftData

struct DayEventsView: View {
    let date: Date
    let events: [Event]
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var newEvent: Event?
    @State private var selectedEvent: Event?

    init(date: Date, events: [Event]) {
        self.date = date
        self.events = events
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text(dateFormatter.string(from: date))
                    .font(.headline)
                    .padding(.top)

                if events.isEmpty {
                    ContentUnavailableView("No Events", systemImage: "calendar.badge.exclamationmark")
                } else {
                    List {
                        ForEach(events) { event in
                            Button {
                                selectedEvent = event  // Set selected event to trigger the sheet
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(event.name)
                                        .font(.headline)

                                    Text(timeFormatter.string(from: event.date))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    if event.repeats {
                                        HStack {
                                            Image(systemName: "repeat")
                                            Text(repeatText(for: event))
                                        }
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    }

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
            .sheet(item: $selectedEvent) { event in
                // This will open a sheet when an event is tapped
                NavigationStack {
                    EventDetail(event: event, isNew: false)
                }
                .interactiveDismissDisabled()
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
        let event = Event(name: "", date: date)
        modelContext.insert(event)
        newEvent = event
    }

    private func deleteEvents(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(events[index])
        }
        try? modelContext.save()
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

    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()

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
