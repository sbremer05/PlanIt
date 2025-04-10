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
    
    @State private var repeatEnds: Bool = false
    
    @State private var showEmptyNameAlert = false
    
    init(event: Event, isNew: Bool = false) {
        self.event = event
        self.isNew = isNew
    }
    
    var body: some View {
        Form {
            TextField("Event Name", text: $event.name)
            
            DatePicker("Event Date", selection: $event.date, in: Date.now..., displayedComponents: [.date, .hourAndMinute])
            
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
                        repeatCount = min(repeatCount, getMaxValueForUnit(newValue))
                    }
                }
                .padding(.vertical, 8)
                
                Picker("End Repeat", selection: $repeatEnds) {
                    Text("None")
                        .tag(false)
                    Text("On Date")
                        .tag(true)
                }
                
                if repeatEnds {
                    DatePicker("End Date", selection: $event.repeatUntil, in: event.date..., displayedComponents: .date)
                }
            }
            
            Toggle("Notify 5 minutes before", isOn: $event.notify5MinutesBefore)
        }
        .navigationTitle(isNew ? "New Event" : "Edit Event")
        .toolbar {
            if isNew {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                    validateAndDismiss()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        context.delete(event)
                        dismiss()
                    }
                }
            } else {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        validateAndDismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Events")
                        }
                    }
                }
            }
        }.alert("Name Required", isPresented: $showEmptyNameAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enter a name for your event.")
        }
        .navigationBarBackButtonHidden(!isNew)
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
    
    private func validateAndDismiss() {
        if event.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showEmptyNameAlert = true
        } else {
            dismiss()
        }
    }
}

#Preview {
    EventDetail(event: SampleData.shared.event)
        .modelContainer(SampleData.shared.modelContainer)
}
