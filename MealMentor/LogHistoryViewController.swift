import UIKit
import FirebaseFirestore
import FirebaseAuth

class LogHistoryViewController: DarkModeViewController {
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fillEqually
        return stack
    }()
    private var mealTables: [MealCategory: UITableView] = [:]
    private var mealData: [MealCategory: [Meal]] = [:]
    
    var selectedDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTables()
        displayDate()
        fetchMealsForSelectedDate()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dateLabel)
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupTables() {
        MealCategory.allCases.forEach { category in
            let tableView = UITableView()
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "mealCell")
            tableView.rowHeight = 65
            tableView.layer.cornerRadius = 12
            tableView.backgroundColor = UIColor(hex: "BADAAF")
            
            let headerView = UIView()
            headerView.backgroundColor = UIColor(hex: "BADAAF")
            headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40)
            
            // add label
            let headerLabel = UILabel()
            headerLabel.text = category.rawValue.replacingOccurrences(of: "Add ", with: "")
            headerLabel.font = UIFont.boldSystemFont(ofSize: 18)
            headerLabel.textAlignment = .left
            headerLabel.translatesAutoresizingMaskIntoConstraints = false
            
            // add button
            let galleryButton = UIButton(type: .system)
            galleryButton.setImage(UIImage(systemName: "photo.on.rectangle"), for: .normal)
            galleryButton.tintColor = .black
            galleryButton.translatesAutoresizingMaskIntoConstraints = false
            galleryButton.tag = MealCategory.allCases.firstIndex(of: category) ?? 0
            galleryButton.addTarget(self, action: #selector(galleryButtonTapped(_:)), for: .touchUpInside)

            headerView.addSubview(headerLabel)
            headerView.addSubview(galleryButton)
            
            NSLayoutConstraint.activate([
                headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

                galleryButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                galleryButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
            ])
            
            tableView.tableHeaderView = headerView
            mealTables[category] = tableView
            mealData[category] = []
            stackView.addArrangedSubview(tableView)
        }
    }
    
    @objc private func galleryButtonTapped(_ sender: UIButton) {
        let category = MealCategory.allCases[sender.tag]

        let storyboard = UIStoryboard(name: "CalendarPage", bundle: nil)
        if let galleryVC = storyboard.instantiateViewController(withIdentifier: "logHistoryFoodGalleryViewController") as? LogHistoryFoodGalleryViewController {
            galleryVC.selectedCategory = category
            galleryVC.selectedDate = self.selectedDate
            galleryVC.modalPresentationStyle = .formSheet
            present(galleryVC, animated: true)
        } else {
            print("Could not instantiate logHistoryFoodGalleryViewController")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToLogHistoryFoodGallery",
           let destinationVC = segue.destination as? LogHistoryFoodGalleryViewController,
           let category = sender as? MealCategory {
            destinationVC.selectedCategory = category
            destinationVC.selectedDate = self.selectedDate
        }
    }
    
    private func displayDate() {
        guard let date = selectedDate else {
            dateLabel.text = "No date selected"
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        dateLabel.text = formatter.string(from: date)
    }
    
    private func fetchMealsForSelectedDate() {
        guard let userID = Auth.auth().currentUser?.uid,
              let selectedDate = selectedDate else {
            showError(message: "User not authenticated or no date selected")
            return
        }
        
        let db = Firestore.firestore()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        MealCategory.allCases.forEach { category in
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
                    
                    let meals = snapshot?.documents.compactMap { document in
                        try? self.parseMeal(document: document)
                    } ?? []
                    
                    DispatchQueue.main.async {
                        self.mealData[category] = meals
                        self.mealTables[category]?.reloadData()
                    }
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
        return Meal(date: date.dateValue(), userID: userID, category: category, foodList: foodList)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension LogHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        for (category, table) in mealTables where table == tableView {
            return mealData[category]?.flatMap { $0.foodList }.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mealCell", for: indexPath)
        cell.backgroundColor = UIColor(hex: "BADAAF")
        
        for (category, table) in mealTables where table == tableView {
            if let foods = mealData[category]?.flatMap({ $0.foodList }), foods.indices.contains(indexPath.row) {
                let food = foods[indexPath.row]
                var content = cell.defaultContentConfiguration()
                content.text = "\(food.name) (\(food.quantity)g)"
                content.secondaryText = "Calories: \(food.calories)"
                cell.contentConfiguration = content
            }
        }
        
        return cell
    }
}
