//
//  DayView.swift
//  PlanIt
//
//  Created by Sean Bremer on 4/10/25.
//

import SwiftUI

struct DayView: View {
    let date: Date
    let isSelected: Bool
    let events: [Event]

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    private var eventSummary: String? {
        switch events.count {
        case 0: return nil
        case 1: return "1 event"
        default: return "\(events.count) events"
        }
    }

    var body: some View {
        VStack(spacing: 6) {
            // Date number
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.headline)
                .foregroundStyle(isToday && !isSelected ? .blue : isSelected ? .white : .primary)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(isSelected ? Color.blue : Color.clear)
                )

            // Event summary
            if let summary = eventSummary {
                Text(summary)
                    .font(.caption2)
                    .foregroundColor(.blue)
            } else {
                // Invisible placeholder to maintain alignment
                Text(" ")
                    .font(.caption2)
                    .hidden()
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 55)
        .padding(.vertical, 1)
    }
}
