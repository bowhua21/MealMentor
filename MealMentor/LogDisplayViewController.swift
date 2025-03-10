//
//  LogDisplayViewController.swift
//  MealMentor
//
//  Created by [Your Name]
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

enum MealCategory: String, CaseIterable {
    case breakfast = "Add Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    
    var headerText: String {
        return self.rawValue
    }
}

class LogDisplayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var breakfastTableView: UITableView!
    private var meals: [Meal] = []
    private var selectedCategory: MealCategory = .breakfast {
        didSet {
            fetchTodaysMeals()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchTodaysMeals()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTodaysMeals()
    }
    
    private func setupTableView() {
        breakfastTableView.delegate = self
        breakfastTableView.dataSource = self
        breakfastTableView.register(UITableViewCell.self, forCellReuseIdentifier: "mealCell")
        breakfastTableView.rowHeight = 65
    }
    
    @IBAction func addMealClicked(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text,
              let category = MealCategory(rawValue: buttonTitle) else {
            showError(message: "Invalid meal category selection")
            return
        }
        selectedCategory = category
        performSegue(withIdentifier: "showMealEntry", sender: category)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMealEntry",
           let destinationVC = segue.destination as? LogEntryViewController,
           let category = sender as? MealCategory {
            destinationVC.selectedCategory = category
        }
    }
    
    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.flatMap { $0.foodList }.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mealCell", for: indexPath)
        let allFoods = meals.flatMap { $0.foodList }
        let food = allFoods[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = "\(food.name) (\(food.quantity)g)"
        content.secondaryText = "Calories: \(food.calories)"
        cell.contentConfiguration = content
        return cell
    }
    
    private func fetchTodaysMeals() {
        guard let userID = Auth.auth().currentUser?.uid else {
            showError(message: "User not authenticated")
            return
        }
        
        let db = Firestore.firestore()
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        db.collection("meals")
            .whereField("userID", isEqualTo: userID)
            .whereField("category", isEqualTo: selectedCategory.rawValue)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .order(by: "date", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    self.showError(message: "Fetch error: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else {
                    self.meals = []
                    DispatchQueue.main.async {
                        self.breakfastTableView.reloadData()
                    }
                    return
                }
                self.meals = documents.compactMap { document in
                    do {
                        return try self.parseMeal(document: document)
                    } catch {
                        print("Error parsing meal: \(error)")
                        return nil
                    }
                }
                print("Fetched \(self.meals.count) meals") 
                DispatchQueue.main.async {
                    self.breakfastTableView.reloadData()
                }
            }
    }
    private func parseMeal(document: QueryDocumentSnapshot) throws -> Meal {
        let data = document.data()
        guard let date = data["date"] as? Timestamp,
              let userID = data["userID"] as? String,
              let category = data["category"] as? String,
              let foodListData = data["foodList"] as? [[String: Any]] else {
            throw NSError(domain: "MealParsing", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid meal data"])
        }
        
        let foodList = foodListData.compactMap { Food.fromDictionary($0) }
        return Meal(
            date: date.dateValue(),
            userID: userID,
            category: category,
            foodList: foodList
        )
    }
    private func showError(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
