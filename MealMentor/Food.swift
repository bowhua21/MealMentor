import Foundation

class Food {
    let name: String
    var calories: Int
    var protein: Int
    var carbohydrates: Int
    var fat: Int
    var fiber: Int
    var vitaminA: Int
    var vitaminC: Int
    var quantity: Int
    
    init(name: String, quantity: Int, calories: Int, protein: Int = 0, carbohydrates: Int = 0, fat: Int = 0, fiber: Int = 0, vitaminA: Int = 0, vitaminC: Int = 0) {
        self.name = name
        self.quantity = quantity
        self.calories = calories
        self.protein = protein
        self.carbohydrates = carbohydrates
        self.fat = fat
        self.fiber = fiber
        self.vitaminA = vitaminA
        self.vitaminC = vitaminC
    }
    
    // Convert Food object to Firestore dictionary
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "quantity": quantity,
            "calories": calories,
            "protein": protein,
            "carbohydrates": carbohydrates,
            "fat": fat,
            "fiber": fiber,
            "vitaminA": vitaminA,
            "vitaminC": vitaminC
        ]
    }
    
    // Initialize Food object from Firestore document
    static func fromDictionary(_ dict: [String: Any]) -> Food? {
        guard let name = dict["name"] as? String,
              let quantity = dict["quantity"] as? Int,
              let calories = dict["calories"] as? Int else {
            return nil
        }

        let protein = dict["protein"] as? Int ?? 0
        let carbohydrates = dict["carbohydrates"] as? Int ?? 0
        let fat = dict["fat"] as? Int ?? 0
        let fiber = dict["fiber"] as? Int ?? 0
        let vitaminA = dict["vitaminA"] as? Int ?? 0
        let vitaminC = dict["vitaminC"] as? Int ?? 0
        
        return Food(name: name, quantity: quantity, calories: calories, protein: protein, carbohydrates: carbohydrates, fat: fat, fiber: fiber, vitaminA: vitaminA, vitaminC: vitaminC)
    }
}
