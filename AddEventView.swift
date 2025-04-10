//
//  AddEventView.swift
//  PlanIt
//
//  Created by Sean Bremer on 4/10/25.
//

import SwiftUI
import SwiftData

struct AddEventView: View {
    let date: Date
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var eventName = ""
    @State private var eventDate: Date
    @State private var repeats = false
    @State private var repeatCount = 1
    @State private var repeatUnit = "day"
    @State private var repeatUntil: Date
    @State private var notify5MinutesBefore = false

    init(date: Date) {
        self._eventDate = State(initialValue: date)
        self._repeatUntil = State(initialValue: Calendar.current.date(byAdding: .month, value: 1, to: date) ?? date)
        self.date = date
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Event Name", text: $eventName)
                    DatePicker("Date & Time", selection: $eventDate)
                }

                Section(header: Text("Repeat")) {
                    Toggle("Repeats", isOn: $repeats)

                    if repeats {
                        HStack {
                            Stepper(value: $repeatCount, in: 1...99) {
                                Text("Every \(repeatCount)")
                            }
                            Spacer()
                            Text("\(repeatCount)")
                                .foregroundColor(.secondary)
                        }

                        Picker("Frequency", selection: $repeatUnit) {
                            Text("day").tag("day")
                            Text("week").tag("week")
                            Text("month").tag("month")
                            Text("year").tag("year")
                        }
                        .pickerStyle(.menu)

                        DatePicker("Until", selection: $repeatUntil, displayedComponents: .date)
                    }
                }

                Section(header: Text("Notifications")) {
                    Toggle("5 Minutes Before", isOn: $notify5MinutesBefore)
                }
            }
            .navigationTitle("Add Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveEvent()
                        dismiss()
                    }
                    .disabled(eventName.isEmpty)
                }
            }
        }
    }

    private func saveEvent() {
        let newEvent = Event(name: eventName, date: eventDate)
        newEvent.repeats = repeats

        if repeats {
            newEvent.repeatCount = repeatCount
            newEvent.repeatUnit = repeatUnit
            newEvent.repeatUntil = repeatUntil
        }

        newEvent.notify5MinutesBefore = notify5MinutesBefore

        modelContext.insert(newEvent)
        try? modelContext.save()
    }
}
