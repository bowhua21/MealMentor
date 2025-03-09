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
    
    func printNutrition() {
        print("\(quantity) x \(name):")
        print("  - Calories: \(calories)")
        print("  - Protein: \(protein)g")
        print("  - Carbohydrates: \(carbohydrates)g")
        print("  - Fat: \(fat)g")
        print("  - Fiber: \(fiber)g")
        print("  - Vitamin A: \(vitaminA) IU")
        print("  - Vitamin C: \(vitaminC) mg")
    }
}
