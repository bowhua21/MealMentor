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

enum NutritionType: String {
    case calories = "Calories"
    case fat = "Fat"
    case protein = "Protein"
}

class LogDisplayViewController: DarkModeViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var nutritionMenuButton: UIButton!
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
    
    private var selectedNutritionType: NutritionType = .calories {
        didSet {
            [breakfastTableView, lunchTableView, dinnerTableView, snackTableView].forEach { $0?.reloadData() }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenu()
        setupTableView()
        setupTableViewConstraints()
        fetchTodaysMeals()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTodaysMeals()
    }
    
    private func setupMenu() {
        let calorieOption = UIAction(title: "Calories") { action in
            self.nutritionMenuButton.setTitle(action.title, for: .normal)
            self.selectedNutritionType = .calories
        }
        let fatOption = UIAction(title: "Fat") { action in
            self.nutritionMenuButton.setTitle(action.title, for: .normal)
            self.selectedNutritionType = .fat
        }
        let proteinOption = UIAction(title: "Protein") { action in
            self.nutritionMenuButton.setTitle(action.title, for: .normal)
            self.selectedNutritionType = .protein
        }
        let nutritionMenu = UIMenu(title: "Nutrition choices", children: [calorieOption, fatOption, proteinOption])
        nutritionMenuButton.menu = nutritionMenu
        nutritionMenuButton.showsMenuAsPrimaryAction = true
    }
    
    private func setupTableView() {
        [breakfastTableView, lunchTableView, dinnerTableView, snackTableView].forEach {
            $0?.delegate = self
            $0?.dataSource = self
            $0?.register(UITableViewCell.self, forCellReuseIdentifier: "mealCell")
            $0?.rowHeight = 65
            $0?.layer.cornerRadius = 12
        }
    }
    
    private func setupTableViewConstraints() {
        let tablesStackView = UIStackView(arrangedSubviews: [
            breakfastTableView, lunchTableView, dinnerTableView, snackTableView
        ])
        tablesStackView.axis = .vertical
        tablesStackView.distribution = .fillEqually
        tablesStackView.spacing = 16
        tablesStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tablesStackView)
        NSLayoutConstraint.activate([
            tablesStackView.topAnchor.constraint(equalTo: nutritionMenuButton.bottomAnchor, constant: 20),
            tablesStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tablesStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tablesStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            breakfastTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            lunchTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            dinnerTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            snackTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
        ])
        
        [breakfastTableView, lunchTableView, dinnerTableView, snackTableView].forEach {
            $0?.backgroundColor = UIColor(hex: "BADAAF")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case breakfastTableView: return breakfastMeals.flatMap { $0.foodList }.count
        case lunchTableView: return lunchMeals.flatMap { $0.foodList }.count
        case dinnerTableView: return dinnerMeals.flatMap { $0.foodList }.count
        case snackTableView: return snackMeals.flatMap { $0.foodList }.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mealCell", for: indexPath)
        cell.backgroundColor = UIColor(hex: "BADAAF")
        cell.contentView.backgroundColor = UIColor(hex: "BADAAF")
        let food = getFoodItem(for: tableView, at: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = "\(food.name) (\(food.quantity)g)"
        switch selectedNutritionType {
        case .calories: content.secondaryText = "Calories: \(food.calories)"
        case .fat: content.secondaryText = "Fat: \(food.fat)g"
        case .protein: content.secondaryText = "Protein: \(food.protein)g"
        }
        
        cell.contentConfiguration = content
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let (meal, foodIndex) = getMealAndFoodIndex(for: tableView, at: indexPath)
        guard let meal = meal, let foodIndex = foodIndex else {
            showError(message: "Could not find item to delete")
            return
        }
        
        var updatedMeal = meal
        updatedMeal.foodList.remove(at: foodIndex)
        
        if updatedMeal.foodList.isEmpty {
            deleteMealDocument(meal) { [weak self] success in
                self?.handleDeletionResult(success: success, tableView: tableView, indexPath: indexPath)
            }
        } else {
            updateMealFoodList(meal, newFoodList: updatedMeal.foodList) { [weak self] success in
                self?.handleDeletionResult(success: success, tableView: tableView, indexPath: indexPath)
            }
        }
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
                    
                    let meals = snapshot?.documents.compactMap { try? self.parseMeal(document: $0) } ?? []
                    self.updateMeals(for: category, with: meals)
                }
        }
    }
    
    private func deleteMealDocument(_ meal: Meal, completion: @escaping (Bool) -> Void) {
        guard let documentID = meal.documentID else {
            completion(false)
            return
        }
        
        Firestore.firestore().collection("meals").document(documentID).delete { error in
            completion(error == nil)
        }
    }
    
    private func updateMealFoodList(_ meal: Meal, newFoodList: [Food], completion: @escaping (Bool) -> Void) {
        guard let documentID = meal.documentID else {
            completion(false)
            return
        }
        
        Firestore.firestore().collection("meals").document(documentID).updateData([
            "foodList": newFoodList.map { $0.toDictionary() }
        ]) { error in
            completion(error == nil)
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
            documentID: document.documentID,
            date: date.dateValue(),
            userID: userID,
            category: category,
            foodList: foodList
        )
    }
    
    private func getFoodItem(for tableView: UITableView, at indexPath: IndexPath) -> Food {
        let meals: [Meal]
        switch tableView {
        case breakfastTableView: meals = breakfastMeals
        case lunchTableView: meals = lunchMeals
        case dinnerTableView: meals = dinnerMeals
        case snackTableView: meals = snackMeals
        default: meals = breakfastMeals
        }
        
        return meals.flatMap { $0.foodList }[indexPath.row]
    }
    
    private func getMealAndFoodIndex(for tableView: UITableView, at indexPath: IndexPath) -> (Meal?, Int?) {
        var meals: [Meal]
        switch tableView {
        case breakfastTableView: meals = breakfastMeals
        case lunchTableView: meals = lunchMeals
        case dinnerTableView: meals = dinnerMeals
        case snackTableView: meals = snackMeals
        default: return (nil, nil)
        }
        
        var cumulativeCount = 0
        for meal in meals {
            for (foodIndex, _) in meal.foodList.enumerated() {
                if cumulativeCount == indexPath.row {
                    return (meal, foodIndex)
                }
                cumulativeCount += 1
            }
        }
        return (nil, nil)
    }
    
    private func handleDeletionResult(success: Bool, tableView: UITableView, indexPath: IndexPath) {
        DispatchQueue.main.async {
            if success {
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.fetchTodaysMeals()
            } else {
                self.showError(message: "Failed to delete item")
                tableView.reloadData()
            }
        }
    }
    
    private func updateMeals(for category: MealCategory, with meals: [Meal]) {
        switch category {
        case .breakfast:
            breakfastMeals = meals
            breakfastTableView.reloadData()
        case .lunch:
            lunchMeals = meals
            lunchTableView.reloadData()
        case .dinner:
            dinnerMeals = meals
            dinnerTableView.reloadData()
        case .snack:
            snackMeals = meals
            snackTableView.reloadData()
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
