//
//  LogDisplayViewController.swift
//  MealMentor
//
//  Created by by Yingting Cao on 3/9/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

enum MealCategory: String, CaseIterable {
    case breakfast = "Add Breakfast"
    case lunch = "Add Lunch"
    case dinner = "Add Dinner"
    case snack = "Add Snack"
    
    var headerText: String {
        return self.rawValue
    }
}



class LogDisplayViewController: DarkModeViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var breakfastTableView: UITableView!
    @IBOutlet weak var lunchTableView: UITableView!
    @IBOutlet weak var dinnerTableView: UITableView!
    @IBOutlet weak var snackTableView: UITableView!
    private var breakfastMeals: [Meal] = []
    private var lunchMeals: [Meal] = []
    private var dinnerMeals: [Meal] = []
    private var snackMeals: [Meal] = []
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
        
        lunchTableView.delegate = self
        lunchTableView.dataSource = self
        lunchTableView.register(UITableViewCell.self, forCellReuseIdentifier: "mealCell")
        lunchTableView.rowHeight = 65
        
        dinnerTableView.delegate = self
        dinnerTableView.dataSource = self
        dinnerTableView.register(UITableViewCell.self, forCellReuseIdentifier: "mealCell")
        dinnerTableView.rowHeight = 65
        
        snackTableView.delegate = self
        snackTableView.dataSource = self
        snackTableView.register(UITableViewCell.self, forCellReuseIdentifier: "mealCell")
        snackTableView.rowHeight = 65
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
            destinationVC.delegate = self
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == breakfastTableView {
            return breakfastMeals.flatMap { $0.foodList }.count
        } else if tableView == lunchTableView {
            return lunchMeals.flatMap { $0.foodList }.count
        } else if tableView == dinnerTableView {
            return dinnerMeals.flatMap { $0.foodList }.count
        } else if tableView == snackTableView {
            return snackMeals.flatMap { $0.foodList }.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mealCell", for: indexPath)
        cell.backgroundColor = UIColor(hex: "BADAAF")
        cell.contentView.backgroundColor = UIColor(hex: "BADAAF")
        var allFoods: [Food] = []
        
        if tableView == breakfastTableView {
            allFoods = breakfastMeals.flatMap { $0.foodList }
        } else if tableView == lunchTableView {
            allFoods = lunchMeals.flatMap { $0.foodList }
        } else if tableView == dinnerTableView {
            allFoods = dinnerMeals.flatMap { $0.foodList }
        } else if tableView == snackTableView {
            allFoods = snackMeals.flatMap { $0.foodList }
        }
        
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
        
        for category in MealCategory.allCases {
            db.collection("meals")
                .whereField("userID", isEqualTo: userID)
                .whereField("category", isEqualTo: category.rawValue)
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
                        self.updateMeals(for: category, with: [])
                        return
                    }
                    let meals = documents.compactMap { document in
                        try? self.parseMeal(document: document)
                    }
                    self.updateMeals(for: category, with: meals)
                }
        }
    }
    
    private func updateMeals(for category: MealCategory, with meals: [Meal]) {
        switch category {
        case .breakfast:
            breakfastMeals = meals
            DispatchQueue.main.async {
                self.breakfastTableView.reloadData()
            }
        case .lunch:
            lunchMeals = meals
            DispatchQueue.main.async {
                self.lunchTableView.reloadData()
            }
        case .dinner:
            dinnerMeals = meals
            DispatchQueue.main.async {
                self.dinnerTableView.reloadData()
            }
        case .snack:
            snackMeals = meals
            DispatchQueue.main.async {
                self.snackTableView.reloadData()
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
extension LogDisplayViewController: LogEntryViewControllerDelegate {
    func didSaveMeal() {
        fetchTodaysMeals()
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
