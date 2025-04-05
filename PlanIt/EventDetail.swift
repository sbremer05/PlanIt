//
//  EventDetail.swift
//  PlanIt
//
//  Created by Sean Bremer on 4/5/25.
//

import SwiftUI

struct EventDetail: View {
    @Bindable var event: Event
    let isNew: Bool
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var repeatCount: Int = 1
    @State private var repeatUnit: String = "weeks"
    
    private let repeatUnits = ["days", "weeks", "months", "years"]
    
    init(event: Event, isNew: Bool = false) {
        self.event = event
        self.isNew = isNew
    }
    
    var body: some View {
        Form {
            TextField("Event Name", text: $event.name)
            
            DatePicker("Event Date", selection: $event.date, in: Date.now..., displayedComponents: .date)
            
            TextField("Location", text: Binding(
                get: { event.location ?? "" },
                set: { event.location = $0.isEmpty ? nil : $0 }
            ))
            
            Toggle("Repeats", isOn: $event.repeats)
            
            if event.repeats {
                HStack {
                    Text("Repeat every")
                    
                    Spacer()
                    
                    Picker("Count", selection: $repeatCount) {
                        ForEach(getRepeatCountRange(), id: \.self) { value in
                            Text("\(value)").tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 50)
                    .clipped()
                    
                    Picker("Unit", selection: $repeatUnit) {
                        ForEach(repeatUnits, id: \.self) { unit in
                            Text(unit).tag(unit)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)
                    .clipped()
                    .onChange(of: repeatUnit) { _, newValue in
                        // Ensure count is within valid range when unit changes
                        repeatCount = min(repeatCount, getMaxValueForUnit(newValue))
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle(isNew ? "New Event" : "Edit Event")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    // Save the repeat interval to your Event model
                    if event.repeats {
                        // You'll need to add properties to your Event model to store these values
                        // event.repeatCount = repeatCount
                        // event.repeatUnit = repeatUnit
                    }
                    dismiss()
                }
            }
        }
    }
    
    private func getMaxValueForUnit(_ unit: String) -> Int {
        switch unit {
            case "days": return 30
            case "weeks": return 3
            case "months": return 11
            case "years": return 99
            default: return 99
        }
    }
    
    private func getRepeatCountRange() -> [Int] {
        let maxValue = getMaxValueForUnit(repeatUnit)
        return Array(1...maxValue)
    }
}

#Preview {
    EventDetail(event: SampleData.shared.event)
        .modelContainer(SampleData.shared.modelContainer)
}
