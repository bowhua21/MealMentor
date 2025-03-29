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
        print("start of week", startOfWeek, "end of week", endOfWeek)

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
                        let normalizedDate = calendar.startOfDay(for: mealDate) // Normalize to remove time
                        trackedDaysSet.insert(normalizedDate)
                    }
                }
                
                // convert set to sorted array
                let trackedDays = trackedDaysSet.sorted()
                completion(trackedDays)
            }
    }
}
