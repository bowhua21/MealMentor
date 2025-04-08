//
//  Notifications.swift
//  MealMentor
//
//  Created by Huyen Nguyen on 4/8/25.
//

import UIKit
import UserNotifications
import FirebaseAuth
import FirebaseFirestore

class Notifications {
    static let shared = Notifications()
    private init() {}
    let center = UNUserNotificationCenter.current()

    func requestNotificationAuth() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, error in
            if let error = error {
                print("Error requesting permission: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleMealNotifications() {
        guard let _ = Auth.auth().currentUser else {
            return
        }
        
        requestNotificationAuth()
        
        getLoggedFoodToday { breakfastExists, lunchExists, dinnerExists in
            if !breakfastExists {
                self.scheduleBreakfastNotification()
            }
            if !lunchExists {
                self.scheduleLunchNotification()
            }
            if !dinnerExists {
                self.scheduleDinnerNotification()
            }
        }
    }
    
    func getLoggedFoodToday(completion: @escaping (_ breakfastExists: Bool, _ lunchExists: Bool, _ dinnerExists: Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(false, false, false)
            return
        }

        let today = Date()
        let startOfDay = Calendar.current.startOfDay(for: today)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else {
            completion(false, false, false)
            return
        }

        db.collection("meals")
            .whereField("userID", isEqualTo: userID)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .getDocuments { (querySnapshot, error) in
                var breakfastExists = false
                var lunchExists = false
                var dinnerExists = false

                if let error = error {
                    print("Error getting meals for today: \(error.localizedDescription)")
                } else if let snapshot = querySnapshot {
                    for document in snapshot.documents {
                        let data = document.data()
                        if let mealType = data["mealType"] as? String {
                            switch mealType.lowercased() {
                                case "breakfast":
                                    breakfastExists = true
                                case "lunch":
                                    lunchExists = true
                                case "dinner":
                                    dinnerExists = true
                                default:
                                    break
                            }
                        }
                    }
                }
                // Call completion with flags for each meal type
                completion(breakfastExists, lunchExists, dinnerExists)
            }
    }
    
    func scheduleBreakfastNotification() {
        let content = UNMutableNotificationContent()
        content.title = "What's for breakfast?"
        content.body = "You haven't recorded your breakfast yet."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "breakfastNotification", content: content, trigger: trigger)
        center.add(request) { error in
            if let error = error {
                print("Error scheduling breakfast notification: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleLunchNotification() {
        let content = UNMutableNotificationContent()
        content.title = "What's for lunch?"
        content.body = "You haven't recorded your lunch yet."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 13 // 1pm
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "lunchNotification", content: content, trigger: trigger)
        center.add(request) { error in
            if let error = error {
                print("Error scheduling lunch notification: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleDinnerNotification() {
        let content = UNMutableNotificationContent()
        content.title = "What's for dinner?"
        content.body = "You haven't recorded your dinner yet."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 19 // 7pm
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "dinnerNotification", content: content, trigger: trigger)
        center.add(request) { error in
            if let error = error {
                print("Error scheduling dinner notification: \(error.localizedDescription)")
            }
        }
    }
}
