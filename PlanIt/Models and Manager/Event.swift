//
//  Event.swift
//  PlanIt
//
//  Created by Sean Bremer on 4/5/25.
//

import Foundation
import SwiftData

@Model
class Event {
    var id : UUID
    var name: String
    var date: Date
    var repeats: Bool = false
    var repeatCount: Int = 1
    var repeatUnit: String = "days"
    var repeatEnds: Bool = false
    var repeatUntil: Date = Date.now
    var notify5MinutesBefore: Bool = false
    
    init(name: String, date: Date) {
        self.id = UUID()
        self.name = name
        self.date = date
    }
    
    static let sampleData = [
        Event(name: "Soccer", date: .now),
        Event(name: "Hockey", date: Date(timeIntervalSinceReferenceDate: 1_628_361_600))
    ]
}
