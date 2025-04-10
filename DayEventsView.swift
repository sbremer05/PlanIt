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
                            VStack(alignment: .leading) {
                                Text(event.name)
                                    .font(.headline)

                                Text(timeFormatter.string(from: event.date))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                if event.repeats {
                                    HStack {
                                        Image(systemName: "repeat")
                                        Text("Repeats \(repeatText(for: event))")
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
                        .onDelete(perform: deleteEvents)
                    }
                }
            }
            .navigationTitle("Events")
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
        // If event does not repeat, return an empty string
        guard event.repeats else {
            return ""
        }

        // Event repeats, so we handle it
        guard let count = event.repeatCount, let unit = event.repeatUnit else {
            return "" // No repeat count or unit, so nothing to show
        }

        // If the event repeats indefinitely (no repeatUntil)
        if event.repeatEnds == false {
            return "Repeats every \(count) \(unit)s"  // "Repeats every 2 days", etc.
        }
        
        // If the event has an end date
        return "Repeats every \(count) \(unit)s until \(shortDateFormatter.string(from: event.repeatUntil))"
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
