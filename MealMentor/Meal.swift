//
//  Meal.swift
//  MealMentor
//
//  Created by Yingting Cao on 3/8/25.
//

import Foundation

class Meal {
    var foodList: [Food] = []
    var date: Date
    var userID: String
    var category: String // Breakfast, Lunch, Dinner, Snack
    
    init(date: Date, userID: String, category: String, foodList: [Food] = []) {
        self.date = date
        self.userID = userID
        self.category = category
        self.foodList = foodList
    }
    
    func addFood(_ food: Food) {
        foodList.append(food)
    }
    

}

