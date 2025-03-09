import Foundation
import FirebaseFirestore

class Meal {
    var foodList: [Food]
    var date: Date
    var userID: String
    var category: String  // Breakfast, Lunch, Dinner, Snack
    
    init(date: Date, userID: String, category: String, foodList: [Food] = []) {
        self.date = date
        self.userID = userID
        self.category = category
        self.foodList = foodList
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "date": Timestamp(date: date),
            "userID": userID,
            "category": category,
            "foodList": foodList.map { $0.toDictionary() } // Convert each Food object to a dictionary
        ]
    }
}
