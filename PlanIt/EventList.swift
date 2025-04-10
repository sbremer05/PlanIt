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
            List {
                ForEach(events) { event in
                    NavigationLink {
                        EventDetail(event: event)
                    } label: {
                        HStack {
                            Text(event.name)
                            
                            Spacer()
                            
                            Text(formattedDate(event.date))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteEvents(indexes:))
            }
            .navigationTitle("Events")
            .toolbar {
                ToolbarItem {
                    Button("Add Event", systemImage: "plus", action: addEvent)
                }
                
                ToolbarItem {
                    EditButton()
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
        let newEvent = Event(name: "", date: .now)
        context.insert(newEvent)
        self.newEvent = newEvent
    }
    
    private func deleteEvents(indexes: IndexSet) {
        for index in indexes {
            context.delete(events[index])
        }
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

    private var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    EventList()
        .modelContainer(SampleData.shared.modelContainer)
}
