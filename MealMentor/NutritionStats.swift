//
//  NutritionStats.swift
//  MealMentor
//
//  Created by Gina Jeon on 3/28/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

var totalNutritionForToday: [String: Int] = [:]

class NutritionStats {
    static let shared = NutritionStats()
    private init() {}
    
    // get total calories, protein, etc. for current day
    func loadTotalNutritionForToday(completion: @escaping () -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            completion() // call completion immediately if the user is not authenticated
            return
        }

        let today = Date()
        let startOfDay = Calendar.current.startOfDay(for: today)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        db.collection("meals")
            .whereField("userID", isEqualTo: userID)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .order(by: "date", descending: false)
            .getDocuments() { (querySnapshot, err) in
                guard let snapshot = querySnapshot else {
                    print("Error getting snapshot: \(String(describing: err))")
                    completion() // call completion even if there's an error
                    return
                }

                let documents = snapshot.documents
                // clear previous data before updating
                totalNutritionForToday = [:]
                
                for doc in documents {
                    let data = doc.data()
                    guard let foodListData = data["foodList"] as? [[String: Any]] else {
                        print("Error getting foodList from meal document")
                        continue
                    }
                    let foodList = foodListData.compactMap { Food.fromDictionary($0) }
                    for food in foodList {
                        // update total nutrition
                        totalNutritionForToday["calories", default: 0] += food.calories
                        totalNutritionForToday["protein", default: 0] += food.protein
                        totalNutritionForToday["carbohydrates", default: 0] += food.carbohydrates
                        totalNutritionForToday["fat", default: 0] += food.fat
                        totalNutritionForToday["fiber", default: 0] += food.fiber
                        totalNutritionForToday["vitaminA", default: 0] += food.vitaminA
                        totalNutritionForToday["vitaminC", default: 0] += food.vitaminC
                    }
                }
                completion()
            }
    }
    
    // get a list of dates from this week that have tracked meals
    func getTrackedDaysOfWeek(completion: @escaping ([Date]) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            completion([]) // return empty array if no user is authenticated
            return
        }
        let today = Date()
        let startOfWeek = Calendar.current.startOfWeek(for: today)
        let endOfWeek = Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek)!
        let startTimestamp = Timestamp(date: startOfWeek)
        let endTimestamp = Timestamp(date: Calendar.current.date(byAdding: .day, value: 1, to: endOfWeek)!)

        db.collection("meals")
            .whereField("userID", isEqualTo: userID)
            .whereField("date", isGreaterThanOrEqualTo: startTimestamp)
            .whereField("date", isLessThanOrEqualTo: endTimestamp)
            .order(by: "date", descending: false)
            .getDocuments { (querySnapshot, err) in
                guard let snapshot = querySnapshot else {
                    print("Error fetching weekly meals: \(String(describing: err))")
                    completion([])
                    return
                }
                
                var trackedDaysSet = Set<Date>()
                let calendar = Calendar.current
                
                for doc in snapshot.documents {
                    if let timestamp = doc.data()["date"] as? Timestamp {
                        let mealDate = timestamp.dateValue()
                        let normalizedDate = calendar.startOfDay(for: mealDate) // normalize to remove time
                        trackedDaysSet.insert(normalizedDate)
                    }
                }
                
                // convert set to sorted array
                let trackedDays = trackedDaysSet.sorted()
                completion(trackedDays)
            }
    }
    
    // get number of days this month that have meals logged
    func getTrackedDaysOfMonth(completion: @escaping (Int) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            completion(0)
            return
        }

        let today = Date()
        let calendar = Calendar.current
        
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
        let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!

        let startTimestamp = Timestamp(date: startOfMonth)
        let endTimestamp = Timestamp(date: startOfNextMonth)
        
        db.collection("meals")
            .whereField("userID", isEqualTo: userID)
            .whereField("date", isGreaterThanOrEqualTo: startTimestamp)
            .whereField("date", isLessThan: endTimestamp)
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("getTrackedDaysOfMonth Error fetching tracked days: \(err)")
                    completion(0)
                    return
                }
                guard let documents = querySnapshot?.documents else {
                    print("getTrackedDaysOfMonth No tracked days found.")
                    completion(0)
                    return
                }
                let uniqueTrackedDays: Set<Date> = Set(documents.compactMap { doc in
                    if let timestamp = doc.data()["date"] as? Timestamp {
                        return calendar.startOfDay(for: timestamp.dateValue())
                    }
                    return nil
                })
                completion(uniqueTrackedDays.count)
            }
    }
    
    // get the number of days in a row user has meals tracked from current day
    func getTrackedDaysStreak(completion: @escaping (Int) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            completion(0)
            return
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // fetch all tracked days up to today
        db.collection("meals")
            .whereField("userID", isEqualTo: userID)
            .whereField("date", isLessThanOrEqualTo: Timestamp(date: today))
            .order(by: "date", descending: true) // Get the most recent dates first
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("getTrackedDaysStreak Error fetching tracked days: \(err)")
                    completion(0)
                    return
                }
                guard let documents = querySnapshot?.documents else {
                    print("getTrackedDaysStreak No tracked days found.")
                    completion(0)
                    return
                }

                // get tracked days, sort in descending order
                let trackedDays: [Date] = documents.compactMap { doc in
                    if let timestamp = doc.data()["date"] as? Timestamp {
                        return calendar.startOfDay(for: timestamp.dateValue())
                    }
                    return nil
                }.sorted(by: { $0 > $1 }) // sort from most recent to oldest

                var streak = 0
                var previousDay = today
                for day in trackedDays {
                    if calendar.isDate(day, inSameDayAs: previousDay) ||
                       calendar.isDate(day, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: previousDay)!) {
                        streak += 1
                        previousDay = day
                    } else {
                        break // streak ends
                    }
                }
                completion(streak)
            }
    }
    
    // gets total nutrition for each day of this week
    func getWeeklyNutrition(completion: @escaping ([[String: Int]]) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            completion([]) // return an empty array if the user is not authenticated
            return
        }

        let today = Date()
        let startOfWeek = Calendar.current.startOfWeek(for: today)
        let endOfWeek = Calendar.current.date(byAdding: .day, value: 7, to: startOfWeek)!
        db.collection("meals")
            .whereField("userID", isEqualTo: userID)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfWeek))
            .whereField("date", isLessThan: Timestamp(date: endOfWeek))
            .order(by: "date", descending: false)
            .getDocuments { (querySnapshot, err) in
                guard let snapshot = querySnapshot else {
                    print("Error getting snapshot: \(String(describing: err))")
                    // return an empty array for each day
                    completion(Array(repeating: [:], count: 7))
                    return
                }

                var weeklyNutrition = Array(repeating: [String: Int](), count: 7)

                // for each meal, add the nutrition for the corresponding day
                for doc in snapshot.documents {
                    let data = doc.data()
                    guard let timestamp = data["date"] as? Timestamp else { continue }
                    let mealDate = timestamp.dateValue()
                    // since it's 0-based indexing 
                    let dayIndex = Calendar.current.component(.weekday, from: mealDate) - 1

                    guard let foodListData = data["foodList"] as? [[String: Any]] else { continue }
                    let foodList = foodListData.compactMap { Food.fromDictionary($0) }

                    for food in foodList {
                        // Aggregate total nutrition for each day
                        weeklyNutrition[dayIndex]["calories", default: 0] += food.calories
                        weeklyNutrition[dayIndex]["protein", default: 0] += food.protein
                        weeklyNutrition[dayIndex]["carbohydrates", default: 0] += food.carbohydrates
                        weeklyNutrition[dayIndex]["fat", default: 0] += food.fat
                        weeklyNutrition[dayIndex]["fiber", default: 0] += food.fiber
                        weeklyNutrition[dayIndex]["vitaminA", default: 0] += food.vitaminA
                        weeklyNutrition[dayIndex]["vitaminC", default: 0] += food.vitaminC
                    }
                }
                completion(weeklyNutrition)
            }
    }
    
}
