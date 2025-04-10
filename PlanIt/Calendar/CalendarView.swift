//
//  CalendarView.swift
//  PlanIt
//
//  Created by Sean Bremer on 4/5/25.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var events: [Event]

    @State private var selectedDate: Date = Date()
    @State private var showingEventSheet = false
    @State private var currentMonth = Date()

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                Spacer()
                Text(monthYearFormatter.string(from: currentMonth))
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)

            HStack {
                ForEach(weekdaySymbols, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)

            ScrollView {
                let days = daysInMonth()
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(days.indices, id: \.self) { i in
                        let date = days[i]
                        if let date = date {
                            let dayEvents = eventsFor(date: date)
                            DayView(
                                date: date,
                                isSelected: isSameDay(date, selectedDate),
                                events: dayEvents
                            )
                            .onTapGesture {
                                selectedDate = date
                            }
                        } else {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(height: 50)
                        }
                    }
                }
                .padding(.horizontal)
            }

            Divider()

            DayEventsView(date: selectedDate, events: eventsFor(date: selectedDate))
        }
    }

    private func changeMonth(by amount: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: amount, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    private func daysInMonth() -> [Date?] {
        var days = [Date?]()
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month], from: currentMonth)
        let startOfMonth = calendar.date(from: dateComponents)!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let numberOfEmptyCells = firstWeekday - 1
        for _ in 0..<numberOfEmptyCells { days.append(nil) }
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        for day in range {
            if let date = calendar.date(bySettingHour: 12, minute: 0, second: 0,
                                        of: calendar.date(bySetting: .day, value: day, of: startOfMonth)!) {
                days.append(date)
            }
        }
        let remainingCells = (7 - (days.count % 7)) % 7
        for _ in 0..<remainingCells { days.append(nil) }
        return days
    }

    private func eventsFor(date: Date) -> [Event] {
        let calendar = Calendar.current
        var eventsForDay: [Event] = []
        
        // Add direct events for this day
        let directEvents = events.filter { isSameDay($0.date, date) }
        eventsForDay.append(contentsOf: directEvents)
        
        // Find and add repeating events
        let repeatingEvents = events.filter { $0.repeats && $0.date <= date && ($0.repeatEnds == false || $0.repeatUntil >= date) }
        
        for event in repeatingEvents {
            // Skip if it's already included as a direct event
            if directEvents.contains(where: { $0.id == event.id }) {
                continue
            }
            
            let repeatCount = event.repeatCount
            let repeatUnit = event.repeatUnit
            
            // Calculate days between the event's start date and the target date
            let daysBetween = calendar.dateComponents([.day], from: calendar.startOfDay(for: event.date), to: calendar.startOfDay(for: date)).day ?? 0
            
            // Handle different repetition types
            switch repeatUnit {
            case "days":
                // Check if the days between is divisible by repeatCount
                if daysBetween % repeatCount == 0 {
                    eventsForDay.append(event)
                }
                
            case "weeks":
                // For weekly repetition:
                // 1. Check if the weekday matches
                // 2. Check if the weeks between is divisible by repeatCount
                if calendar.component(.weekday, from: event.date) == calendar.component(.weekday, from: date) {
                    let weeksBetween = daysBetween / 7
                    if weeksBetween % repeatCount == 0 {
                        eventsForDay.append(event)
                    }
                }
                
            case "months":
                // For monthly repetition, check day of month and proper interval
                if calendar.component(.day, from: event.date) == calendar.component(.day, from: date) {
                    let monthsBetween = calendar.dateComponents([.month], from: event.date, to: date).month ?? 0
                    if monthsBetween % repeatCount == 0 {
                        eventsForDay.append(event)
                    }
                }
                
            case "years":
                // For yearly repetition, check month and day, and proper interval
                if calendar.component(.month, from: event.date) == calendar.component(.month, from: date),
                   calendar.component(.day, from: event.date) == calendar.component(.day, from: date) {
                    let yearsBetween = calendar.dateComponents([.year], from: event.date, to: date).year ?? 0
                    if yearsBetween % repeatCount == 0 {
                        eventsForDay.append(event)
                    }
                }
                
            default:
                break
            }
        }
        
        return eventsForDay
    }
    
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        return Calendar.current.isDate(date1, inSameDayAs: date2)
    }

    private var monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    private var weekdaySymbols: [String] = {
        return Calendar.current.shortWeekdaySymbols
    }()
}

#Preview {
    CalendarView()
        .modelContainer(SampleData.shared.modelContainer)
}
