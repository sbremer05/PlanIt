//
//  AppDelegate.swift
//  PlanIt
//
//  Created by Sean Bremer on 4/10/25.
//

import UIKit
import BackgroundTasks

class AppDelegate: UIResponder, UIApplicationDelegate {
 
    // Set up background fetch
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerBackgroundTask()
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
        } catch {
            print("Failed to submit background task: \(error)")
        }
    }
    
    func handleUpdateNotificationsTask(task: BGTask) {
        NotificationManager.shared.updateNotifications()
        
        task.expirationHandler = {
            print("Background task expired.")
        }
        
        task.setTaskCompleted(success: true)
    }
}
