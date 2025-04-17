//
//  AppDelegate.swift
//  PlanIt
//
//  Created by Sean Bremer on 4/10/25.
//

import SwiftUI
import UIKit
import BackgroundTasks
import SwiftData

class AppDelegate: UIResponder, UIApplicationDelegate {
    // We'll need a reference to the modelContainer
    var modelContainer: ModelContainer?
    
    // Set up background fetch
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerBackgroundTask()
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
        
        // Initialize the model container
        do {
            modelContainer = try ModelContainer(for: Event.self)
        } catch {
            print("Failed to create model container: \(error)")
        }
        
        return true
    }

    // Ensure background tasks are scheduled when app comes to foreground
    func applicationWillEnterForeground(_ application: UIApplication) {
        scheduleBackgroundFetch()
    }
    
    // Schedule background tasks when the app goes into the background
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleBackgroundFetch()
    }
    
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.planit.updateNotifications", using: nil) { task in
            self.handleUpdateNotificationsTask(task: task)
        }
    }
    
    // Create a BGTaskRequest for updating notifications
    func scheduleBackgroundFetch() {
        let request = BGProcessingTaskRequest(identifier: "com.planit.updateNotifications")
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 15)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background task scheduled successfully")
        } catch {
            print("Failed to submit background task: \(error)")
        }
    }
    
    func handleUpdateNotificationsTask(task: BGTask) {
        // Ensure we have a valid model container
        guard let container = modelContainer else {
            print("Model container not available, cannot update notifications")
            task.setTaskCompleted(success: false)
            return
        }
        
        // Create a background context
        let context = ModelContext(container)
        
        // Schedule the next background task first
        scheduleBackgroundFetch()
        
        // Update notifications with the context
        NotificationManager.shared.updateNotifications(context: context)
        
        task.expirationHandler = {
            print("Background task expired.")
        }
        
        task.setTaskCompleted(success: true)
        print("Background task completed successfully")
    }
}
