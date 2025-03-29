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
    
    func loadTotalNutritionForToday(completion: @escaping () -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            completion() // Call completion immediately if the user is not authenticated
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
                    completion() // Call completion even if there's an error
                    return
                }

                let documents = snapshot.documents
                // Clear previous data before updating
                totalNutritionForToday = [:]
                
                // Process the fetched data
                for doc in documents {
                    let data = doc.data()
                    guard let foodListData = data["foodList"] as? [[String: Any]] else {
                        print("Error getting foodList from meal document")
                        continue
                    }
                    let foodList = foodListData.compactMap { Food.fromDictionary($0) }
                    for food in foodList {
                        // Update total nutrition
                        totalNutritionForToday["calories", default: 0] += food.calories
                        totalNutritionForToday["protein", default: 0] += food.protein
                        totalNutritionForToday["carbohydrates", default: 0] += food.carbohydrates
                        totalNutritionForToday["fat", default: 0] += food.fat
                        totalNutritionForToday["fiber", default: 0] += food.fiber
                        totalNutritionForToday["vitaminA", default: 0] += food.vitaminA
                        totalNutritionForToday["vitaminC", default: 0] += food.vitaminC
                    }
                }
                
                // Call the completion handler after data is fetched and totalNutritionForToday is updated
                completion()
            }
    }
}
