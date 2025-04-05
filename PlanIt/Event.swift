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
    var name: String
    var date: Date
    var location: String?
    var repeats: Bool
    var repeatCount: Int?
    var repeatUnit: String?
    var repeatEnds: Bool?
    var repeatUntil: Date?
    
    init(name: String, date: Date, repeats: Bool) {
        self.name = name
        self.date = date
        self.repeats = repeats
    }
    
    static let sampleData = [
        Event(name: "Soccer", date: .now, repeats: false),
        Event(name: "Hockey", date: Date(timeIntervalSinceReferenceDate: 1_628_361_600)
, repeats: true)
    ]
}
