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
                    NavigationLink(event.name) {
                        EventDetail(event: event)
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
            }
        }
    }
    
    private func addEvent() {
        let newEvent = Event(name: "New Event", date: .now, repeats: false)
        context.insert(newEvent)
        self.newEvent = newEvent
    }
    
    private func deleteEvents(indexes: IndexSet) {
        for index in indexes {
            context.delete(events[index])
        }
    }
}

#Preview {
    EventList()
        .modelContainer(SampleData.shared.modelContainer)
}
