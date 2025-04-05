//
//  SampleData.swift
//  PlanIt
//
//  Created by Sean Bremer on 4/5/25.
//

import Foundation
import SwiftData

@MainActor
class SampleData {
    static let shared = SampleData()
    
    let modelContainer: ModelContainer
    
    var context: ModelContext {
        modelContainer.mainContext
    }
    
    var event: Event {
        Event.sampleData.first!
    }
    
    private init() {
        let schema = Schema([
            Event.self
        ])
        
        let modelConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: modelConfig)
            insertSampleData()
            try context.save()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    private func insertSampleData() {
        for event in Event.sampleData {
            context.insert(event)
        }
    }
}
