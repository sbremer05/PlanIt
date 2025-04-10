//
//  PlanItApp.swift
//  PlanIt
//
//  Created by Sean Bremer on 4/5/25.
//

import SwiftUI

@main
struct PlanItApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        requestNotificationPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
//                .onChange(of: scenePhase) { phase, _ in
//                    if phase == .active {
//                        NotificationManager.shared.refreshAllNotifications()
//                    }
//                }
        }
        .modelContainer(for: [Event.self])
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
    }
}
