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
        breakfastTableView.delegate = self
        breakfastTableView.dataSource = self
        breakfastTableView.register(UITableViewCell.self, forCellReuseIdentifier: "mealCell")
        breakfastTableView.rowHeight = 65
        breakfastTableView.layer.cornerRadius = 12
        
        lunchTableView.delegate = self
        lunchTableView.dataSource = self
        lunchTableView.register(UITableViewCell.self, forCellReuseIdentifier: "mealCell")
        lunchTableView.rowHeight = 65
        lunchTableView.layer.cornerRadius = 12
        
        dinnerTableView.delegate = self
        dinnerTableView.dataSource = self
        dinnerTableView.register(UITableViewCell.self, forCellReuseIdentifier: "mealCell")
        dinnerTableView.rowHeight = 65
        dinnerTableView.layer.cornerRadius = 12
        
        snackTableView.delegate = self
        snackTableView.dataSource = self
        snackTableView.register(UITableViewCell.self, forCellReuseIdentifier: "mealCell")
        snackTableView.rowHeight = 65
        snackTableView.layer.cornerRadius = 12
    }
    
    private func setupTableViewConstraints() {
            breakfastTableView.translatesAutoresizingMaskIntoConstraints = false
            lunchTableView.translatesAutoresizingMaskIntoConstraints = false
            dinnerTableView.translatesAutoresizingMaskIntoConstraints = false
            snackTableView.translatesAutoresizingMaskIntoConstraints = false
        
            let tablesStackView = UIStackView(arrangedSubviews: [
                breakfastTableView,
                lunchTableView,
                dinnerTableView,
                snackTableView
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
            [breakfastTableView, lunchTableView, dinnerTableView, snackTableView].forEach { tableView in
                tableView.layer.cornerRadius = 12
                tableView.rowHeight = 65
                tableView.backgroundColor = UIColor(hex: "BADAAF")
            }
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
        switch selectedNutritionType {
        case .calories:
            content.secondaryText = "Calories: \(food.calories)"
        case .fat:
            content.secondaryText = "Fat: \(food.fat)g"
        case .protein:
            content.secondaryText = "Protein: \(food.protein)g"
        }
        
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

