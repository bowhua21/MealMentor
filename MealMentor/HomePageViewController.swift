//
//  HomePageViewController.swift
//  MealMentor
//
//  Created by Gina Jeon on 2/23/25.
//

import UIKit
import DGCharts
import TinyConstraints
import FirebaseAuth
import FirebaseFirestore

// TODO delete later
let dummyDataPts: [BarChartDataEntry] = [
    BarChartDataEntry(x: 1.0, y: 50.0),
    BarChartDataEntry(x: 2.0, y: 25.0),
    BarChartDataEntry(x: 3.0, y: 30.0),
    BarChartDataEntry(x: 4.0, y: 0.0),
    BarChartDataEntry(x: 5.0, y: 10.0),
    BarChartDataEntry(x: 6.0, y: 0.0),
    BarChartDataEntry(x: 7.0, y: 40.0)
]

let dummyDataPts2: [BarChartDataEntry] = [
    BarChartDataEntry(x: 1.0, y: 1500.0),
    BarChartDataEntry(x: 2.0, y: 2000.0),
    BarChartDataEntry(x: 3.0, y: 1700.0),
    BarChartDataEntry(x: 4.0, y: 0.0),
    BarChartDataEntry(x: 5.0, y: 1975.0),
    BarChartDataEntry(x: 6.0, y: 0.0),
    BarChartDataEntry(x: 7.0, y: 1530.0)
]

class HomePageViewController: DarkModeViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    //user firestore document
    let userDoc = db.collection("users").document(Auth.auth().currentUser!.uid)
    
    // home screen properties
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var numDaysLoggedThisMonth: UILabel!
    @IBOutlet weak var numDayStreak: UILabel!
    @IBOutlet weak var numDaysTrackedLabel: UILabel!
    @IBOutlet weak var proteinCellButton: UIButton!
    @IBOutlet weak var caloriesCellButton: UIButton!
    @IBOutlet weak var carbsCellButton: UIButton!
    @IBOutlet weak var fatCellButton: UIButton!
    @IBOutlet weak var fiberCellButton: UIButton!
    @IBOutlet weak var vitACellButton: UIButton!
    @IBOutlet weak var vitCCellButton: UIButton!
    // each floating cell
    @IBOutlet weak var highlightsView: UIView!
    @IBOutlet weak var thisWeekView: UIView!
    @IBOutlet weak var todayMealsView: UIView!
    @IBOutlet weak var weeklyProteinView: UIView!
    @IBOutlet weak var weeklyCaloriesView: UIView!
    @IBOutlet weak var weeklyCarbsView: UIView!
    @IBOutlet weak var weeklyFatView: UIView!
    @IBOutlet weak var weeklyFiberView: UIView!
    @IBOutlet weak var weeklyVitAView: UIView!
    @IBOutlet weak var weeklyVitCView: UIView!
    
    // today's meals table view within todayMealsView
    let tableViewCellIdentifier = "TableViewCellIdentifier"
    @IBOutlet weak var todayMealsTableView: UITableView!
    var todayFoods: [String] = []
    var todayNutritionDescription: [String] = []
    var todayNutrition: [String: Int] = [:]
    // calendar collection within thisWeekView
    @IBOutlet weak var thisWeekCollectionView: UICollectionView!
    // tracked days
    var trackedDays: [Date] = []
    var daysOfWeek: [Date] = []
    
    // graphs
    lazy var proteinBarChartView: BarChartView = {
        let chartView = BarChartView()
        chartView.backgroundColor = .clear
        chartView.rightAxis.enabled = false
        chartView.leftAxis.axisMinimum = 0
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.leftAxis.enabled = false
        chartView.xAxis.valueFormatter = BarChartXAxisWeekdayValueFormatter()
        chartView.xAxis.granularity = 1
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.axisMinimum = 0.5
        chartView.xAxis.axisMaximum = 7.5
        chartView.xAxis.labelCount = 7
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.labelTextColor = .black
        chartView.legend.enabled = false
        return chartView
    }()
    lazy var caloriesBarChartView: BarChartView = {
        let chartView = BarChartView()
        chartView.backgroundColor = .clear
        chartView.rightAxis.enabled = false
        chartView.leftAxis.axisMinimum = 0
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.leftAxis.enabled = false
        chartView.xAxis.valueFormatter = BarChartXAxisWeekdayValueFormatter()
        chartView.xAxis.granularity = 1
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.axisMinimum = 0.5
        chartView.xAxis.axisMaximum = 7.5
        chartView.xAxis.labelCount = 7
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.labelTextColor = .black
        chartView.legend.enabled = false
        return chartView
    }()
    lazy var carbsBarChartView: BarChartView = {
        let chartView = BarChartView()
        chartView.backgroundColor = .clear
        chartView.rightAxis.enabled = false
        chartView.leftAxis.axisMinimum = 0
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.leftAxis.enabled = false
        chartView.xAxis.valueFormatter = BarChartXAxisWeekdayValueFormatter()
        chartView.xAxis.granularity = 1
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.axisMinimum = 0.5
        chartView.xAxis.axisMaximum = 7.5
        chartView.xAxis.labelCount = 7
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.labelTextColor = .black
        chartView.legend.enabled = false
        return chartView
    }()
    lazy var fatBarChartView: BarChartView = {
        let chartView = BarChartView()
        chartView.backgroundColor = .clear
        chartView.rightAxis.enabled = false
        chartView.leftAxis.axisMinimum = 0
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.leftAxis.enabled = false
        chartView.xAxis.valueFormatter = BarChartXAxisWeekdayValueFormatter()
        chartView.xAxis.granularity = 1
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.axisMinimum = 0.5
        chartView.xAxis.axisMaximum = 7.5
        chartView.xAxis.labelCount = 7
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.labelTextColor = .black
        chartView.legend.enabled = false
        return chartView
    }()
    lazy var fiberBarChartView: BarChartView = {
        let chartView = BarChartView()
        chartView.backgroundColor = .clear
        chartView.rightAxis.enabled = false
        chartView.leftAxis.axisMinimum = 0
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.leftAxis.enabled = false
        chartView.xAxis.valueFormatter = BarChartXAxisWeekdayValueFormatter()
        chartView.xAxis.granularity = 1
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.axisMinimum = 0.5
        chartView.xAxis.axisMaximum = 7.5
        chartView.xAxis.labelCount = 7
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.labelTextColor = .black
        chartView.legend.enabled = false
        return chartView
    }()
    lazy var vitABarChartView: BarChartView = {
        let chartView = BarChartView()
        chartView.backgroundColor = .clear
        chartView.rightAxis.enabled = false
        chartView.leftAxis.axisMinimum = 0
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.leftAxis.enabled = false
        chartView.xAxis.valueFormatter = BarChartXAxisWeekdayValueFormatter()
        chartView.xAxis.granularity = 1
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.axisMinimum = 0.5
        chartView.xAxis.axisMaximum = 7.5
        chartView.xAxis.labelCount = 7
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.labelTextColor = .black
        chartView.legend.enabled = false
        return chartView
    }()
    lazy var vitCBarChartView: BarChartView = {
        let chartView = BarChartView()
        chartView.backgroundColor = .clear
        chartView.rightAxis.enabled = false
        chartView.leftAxis.axisMinimum = 0
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.leftAxis.enabled = false
        chartView.xAxis.valueFormatter = BarChartXAxisWeekdayValueFormatter()
        chartView.xAxis.granularity = 1
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.axisMinimum = 0.5
        chartView.xAxis.axisMaximum = 7.5
        chartView.xAxis.labelCount = 7
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.labelTextColor = .black
        chartView.legend.enabled = false
        return chartView
    }()
    // graph data TODO rest
    var proteinData: [BarChartDataEntry] = []
    var caloriesData: [BarChartDataEntry] = []
    var carbsData: [BarChartDataEntry] = []
    var fatData: [BarChartDataEntry] = []
    var fiberData: [BarChartDataEntry] = []
    var vitAData: [BarChartDataEntry] = []
    var vitCData: [BarChartDataEntry] = []
    // segue identifiers
    let segueToProteinVisualizationsIdentifier = "SegueToProteinVisualizationsIdentifier"
    let segueToCaloriesVisualizationsIdentifier = "SegueToCaloriesVisualizationsIdentifier"
    let segueTocarbsVisualizationsIdentifier = "SegueTocarbsVisualizationsIdentifier"
    let segueToFatVisualizationsIdentifier = "SegueToFatVisualizationsIdentifier"
    let segueToFiberVisualizationsIdentifier = "SegueToFiberVisualizationsIdentifier"
    let segueToVitAVisualizationsIdentifier = "SegueToVitAVisualizationsIdentifier"
    let segueToVitCVisualizationsIdentifier = "SegueToVitCVisualizationsIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // setup highlights
        NutritionStats.shared.getTrackedDaysOfMonth { daysTracked in
            self.numDaysLoggedThisMonth.text = String(daysTracked)
        }
        NutritionStats.shared.getTrackedDaysStreak { streak in
            self.numDayStreak.text = String(streak)
        }
        
        // setup today's meals
        todayMealsTableView.dataSource = self
        todayMealsTableView.delegate = self
        // fetch today's food data
        fetchTodayFoods()
                
        // setup this week calendar collection view
        thisWeekCollectionView.dataSource = self
        thisWeekCollectionView.delegate = self
        thisWeekCollectionView.layer.backgroundColor = UIColor.clear.cgColor
        let today = Date()
        let startOfWeek = Calendar.current.startOfWeek(for: today)
        daysOfWeek = getDaysOfWeek(startOfWeek: startOfWeek)
        NutritionStats.shared.getTrackedDaysOfWeek { [weak self] trackedDays in
            self?.trackedDays = trackedDays
            let numDaysTracked = (self?.trackedDays.count)!
            self?.numDaysTrackedLabel.text = "\(numDaysTracked)/7 days"
            DispatchQueue.main.async {
                self?.thisWeekCollectionView.reloadData()
            }
        }
    
        // setup protein bar chart
        weeklyProteinView.addSubview(proteinBarChartView)
        proteinBarChartView.center(in: weeklyProteinView, offset: CGPoint(x: 0, y: 10))
        proteinBarChartView.width(360)
        proteinBarChartView.height(130)
        // make sure protein cell button is still clickable
        weeklyProteinView.bringSubviewToFront(proteinCellButton)
        
        // setup calories bar chart
        weeklyCaloriesView.addSubview(caloriesBarChartView)
        caloriesBarChartView.center(in: weeklyCaloriesView, offset: CGPoint(x: 0, y: 10))
        caloriesBarChartView.width(360)
        caloriesBarChartView.height(130)
        // make sure calories cell button is still clickable
        weeklyCaloriesView.bringSubviewToFront(caloriesCellButton)
        
        // setup carbs bar chart
        weeklyCarbsView.addSubview(carbsBarChartView)
        carbsBarChartView.center(in: weeklyCarbsView, offset: CGPoint(x: 0, y: 10))
        carbsBarChartView.width(360)
        carbsBarChartView.height(130)
        // make sure carbs cell button is still clickable
        weeklyCarbsView.bringSubviewToFront(carbsCellButton)
        
        // setup fat bar chart
        weeklyFatView.addSubview(fatBarChartView)
        fatBarChartView.center(in: weeklyFatView, offset: CGPoint(x: 0, y: 10))
        fatBarChartView.width(360)
        fatBarChartView.height(130)
        // make sure fat cell button is still clickable
        weeklyFatView.bringSubviewToFront(fatCellButton)
        
        // setup fiber bar chart
        weeklyFiberView.addSubview(fiberBarChartView)
        fiberBarChartView.center(in: weeklyFiberView, offset: CGPoint(x: 0, y: 10))
        fiberBarChartView.width(360)
        fiberBarChartView.height(130)
        // make sure fiber cell button is still clickable
        weeklyFiberView.bringSubviewToFront(fiberCellButton)
        
        // setup vitamin A bar chart
        weeklyVitAView.addSubview(vitABarChartView)
        vitABarChartView.center(in: weeklyVitAView, offset: CGPoint(x: 0, y: 10))
        vitABarChartView.width(360)
        vitABarChartView.height(130)
        // make sure vitamin A cell button is still clickable
        weeklyVitAView.bringSubviewToFront(vitACellButton)
        
        // setup vitamin C bar chart
        weeklyVitCView.addSubview(vitCBarChartView)
        vitCBarChartView.center(in: weeklyVitCView, offset: CGPoint(x: 0, y: 10))
        vitCBarChartView.width(360)
        vitCBarChartView.height(130)
        // make sure vitamin A cell button is still clickable
        weeklyVitCView.bringSubviewToFront(vitCCellButton)
        
        // fetch weekly nutrition stats for bar charts
        // TODO do rest
        NutritionStats.shared.getWeeklyNutrition{ [weak self] weekStats in
            // reset data
            self?.proteinData = []
            self?.caloriesData = []
            self?.carbsData = []
            self?.fatData = []
            self?.fiberData = []
            self?.vitAData = []
            self?.vitCData = []
            for dayIdx in 0...(weekStats.count - 1) {
                // add protein data
                self?.proteinData.append(BarChartDataEntry(x: Double(dayIdx + 1), y: (Double(weekStats[dayIdx]["protein"] ?? 0))))
                // add calories data
                self?.caloriesData.append(BarChartDataEntry(x: Double(dayIdx + 1), y: (Double(weekStats[dayIdx]["calories"] ?? 0))))
                // add carbs data
                self?.carbsData.append(BarChartDataEntry(x: Double(dayIdx + 1), y: (Double(weekStats[dayIdx]["carbohydrates"] ?? 0))))
                // add fat data
                self?.fatData.append(BarChartDataEntry(x: Double(dayIdx + 1), y: (Double(weekStats[dayIdx]["fat"] ?? 0))))
                // add fiber data
                self?.fiberData.append(BarChartDataEntry(x: Double(dayIdx + 1), y: (Double(weekStats[dayIdx]["fiber"] ?? 0))))
                // add vitamin A data
                self?.vitAData.append(BarChartDataEntry(x: Double(dayIdx + 1), y: (Double(weekStats[dayIdx]["vitaminA"] ?? 0))))
                // add vitamin C data
                self?.vitCData.append(BarChartDataEntry(x: Double(dayIdx + 1), y: (Double(weekStats[dayIdx]["vitaminC"] ?? 0))))
            }
            self?.setProteinData()
            self?.setCaloriesData()
            self?.setCarbsData()
            self?.setFatData()
            self?.setFiberData()
            self?.setVitAData()
            self?.setVitCData()
        }
        
        //bowen edit 3/11 (input name)
        ProfileLoader().loadProfile { profile in
            self.username.text = profile.fullName
        }
        Notifications.shared.scheduleMealNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // put rounded corners for cells
        highlightsView.layer.cornerRadius = 20
        thisWeekView.layer.cornerRadius = 20
        todayMealsView.layer.cornerRadius = 20
        weeklyProteinView.layer.cornerRadius = 20
        weeklyCaloriesView.layer.cornerRadius = 20
        weeklyCarbsView.layer.cornerRadius = 20
        weeklyFatView.layer.cornerRadius = 20
        weeklyFiberView.layer.cornerRadius = 20
        weeklyVitAView.layer.cornerRadius = 20
        weeklyVitCView.layer.cornerRadius = 20
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // repeat a lot of the stuff in viewDidLoad as new logged meals updates this screen
        todayMealsTableView.dataSource = self
        todayMealsTableView.delegate = self
        fetchTodayFoods()
        // setup highlights
        NutritionStats.shared.getTrackedDaysOfMonth { daysTracked in
            self.numDaysLoggedThisMonth.text = String(daysTracked)
        }
        NutritionStats.shared.getTrackedDaysStreak { streak in
            self.numDayStreak.text = String(streak)
        }
        NutritionStats.shared.getTrackedDaysOfWeek { [weak self] trackedDays in
            self?.trackedDays = trackedDays
            let numDaysTracked = (self?.trackedDays.count)!
            self?.numDaysTrackedLabel.text = "\(numDaysTracked)/7 days"
            DispatchQueue.main.async {
                self?.thisWeekCollectionView.reloadData()
            }
        }
        
        // fetch weekly nutrition stats for bar charts
        NutritionStats.shared.getWeeklyNutrition{ [weak self] weekStats in
            // reset data
            self?.proteinData = []
            self?.caloriesData = []
            self?.carbsData = []
            self?.fatData = []
            self?.fiberData = []
            self?.vitAData = []
            self?.vitCData = []
            for dayIdx in 0...(weekStats.count - 1) {
                // add protein data
                self?.proteinData.append(BarChartDataEntry(x: Double(dayIdx + 1), y: (Double(weekStats[dayIdx]["protein"] ?? 0))))
                // add calories data
                self?.caloriesData.append(BarChartDataEntry(x: Double(dayIdx + 1), y: (Double(weekStats[dayIdx]["calories"] ?? 0))))
                // add carbs data
                self?.carbsData.append(BarChartDataEntry(x: Double(dayIdx + 1), y: (Double(weekStats[dayIdx]["carbohydrates"] ?? 0))))
                // add fat data
                self?.fatData.append(BarChartDataEntry(x: Double(dayIdx + 1), y: (Double(weekStats[dayIdx]["fat"] ?? 0))))
                // add fiber data
                self?.fiberData.append(BarChartDataEntry(x: Double(dayIdx + 1), y: (Double(weekStats[dayIdx]["fiber"] ?? 0))))
                // add vitamin A data
                self?.vitAData.append(BarChartDataEntry(x: Double(dayIdx + 1), y: (Double(weekStats[dayIdx]["vitaminA"] ?? 0))))
                // add vitamin C data
                self?.vitCData.append(BarChartDataEntry(x: Double(dayIdx + 1), y: (Double(weekStats[dayIdx]["vitaminC"] ?? 0))))
            }
            self?.setProteinData()
            self?.setCaloriesData()
            self?.setCarbsData()
            self?.setFatData()
            self?.setFiberData()
            self?.setVitAData()
            self?.setVitCData()
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysOfWeek.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThisWeekDayCell.identifier, for: indexPath) as! ThisWeekDayCell
        let date = daysOfWeek[indexPath.row]
        // Check if this date is in the trackedDays list
        let isTracked = trackedDays.contains { Calendar.current.isDate($0, inSameDayAs: date) }
        cell.configure(with: date, isTracked: isTracked)
        return cell
    }
    
    // fetch user's meals for today. populates food list and corresponding nutrition list
    private func fetchTodayFoods() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
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
                    return
                }
                let documents = snapshot.documents
                // get most updated food list and corresponding nutrition
                self.todayFoods = []
                self.todayNutritionDescription = []
                self.todayNutrition = [:]
                for doc in documents {
                    let data = doc.data()
                    guard let foodListData = data["foodList"] as? [[String: Any]] else {
                        print("error getting foodlist from meal document")
                        return
                    }
                    let foodList = foodListData.compactMap { Food.fromDictionary($0) }
                    for food in foodList {
                        self.todayFoods.append(food.name)
                        // TODO add other nutrition later
                        let nutritionDescription = "\(food.calories) kcal, \(food.protein)g protein, \(food.carbohydrates)g carbs, \(food.fat)g fat, \(food.fiber)g fiber"
                        self.todayNutritionDescription.append(nutritionDescription)
                        // update total nutrition
                        self.todayNutrition["calories", default: 0] += food.calories
                        self.todayNutrition["protein", default: 0] += food.protein
                        self.todayNutrition["carbohydrates", default: 0] += food.carbohydrates
                        self.todayNutrition["fat", default: 0] += food.fat
                        self.todayNutrition["fiber", default: 0] += food.fiber
                        self.todayNutrition["vitaminA", default: 0] += food.vitaminA
                        self.todayNutrition["vitaminC", default: 0] += food.vitaminC
                    }
                }
                DispatchQueue.main.async {
                    self.todayMealsTableView.reloadData()
                }
            }
    }
    
    // get the days of the current week using the start of the week date
    private func getDaysOfWeek(startOfWeek: Date) -> [Date] {
        var days: [Date] = []
        let calendar = Calendar.current
        
        // Generate the days of the week (Date objects for each day)
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                days.append(date)
            }
        }
        return days
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.todayFoods.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier, for: indexPath)
        cell.textLabel?.text = self.todayFoods[indexPath.section]
        cell.detailTextLabel?.text = self.todayNutritionDescription[indexPath.section]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // set data for protein bar chart
    func setProteinData() {
        //
        let set = BarChartDataSet(entries: self.proteinData, label: "Protein")
        set.valueFormatter = BarChartYValueUnitValueFormatter(unit: "g")
        set.colors = [UIColor(red: 0.1019, green: 0.4823, blue: 0.8235, alpha: 1.0)]
        set.valueTextColor = .black
        let data = BarChartData(dataSet: set)
        proteinBarChartView.data = data
    }
    
    // set data for calories bar chart
    func setCaloriesData() {
        let set = BarChartDataSet(entries: self.caloriesData, label: "Calories")
        set.valueFormatter = BarChartYValueUnitValueFormatter(unit: "cal")
        set.colors = [UIColor(red: 0.1019, green: 0.4823, blue: 0.8235, alpha: 1.0)]
        set.valueTextColor = .black
        let data = BarChartData(dataSet: set)
        caloriesBarChartView.data = data
    }
    
    // set data for carbs bar chart
    func setCarbsData() {
        let set = BarChartDataSet(entries: self.carbsData, label: "Carbohydrates")
        set.valueFormatter = BarChartYValueUnitValueFormatter(unit: "g")
        set.colors = [UIColor(red: 0.1019, green: 0.4823, blue: 0.8235, alpha: 1.0)]
        set.valueTextColor = .black
        let data = BarChartData(dataSet: set)
        carbsBarChartView.data = data
    }
    
    // set data for Fat bar chart
    func setFatData() {
        let set = BarChartDataSet(entries: self.fatData, label: "Fat")
        set.valueFormatter = BarChartYValueUnitValueFormatter(unit: "g")
        set.colors = [UIColor(red: 0.1019, green: 0.4823, blue: 0.8235, alpha: 1.0)]
        set.valueTextColor = .black
        let data = BarChartData(dataSet: set)
        fatBarChartView.data = data
    }
    
    // set data for Fiber bar chart
    func setFiberData() {
        let set = BarChartDataSet(entries: self.fiberData, label: "Fiber")
        set.valueFormatter = BarChartYValueUnitValueFormatter(unit: "g")
        set.colors = [UIColor(red: 0.1019, green: 0.4823, blue: 0.8235, alpha: 1.0)]
        set.valueTextColor = .black
        let data = BarChartData(dataSet: set)
        fiberBarChartView.data = data
    }
    
    // set data for vitamin A bar chart
    func setVitAData() {
        let set = BarChartDataSet(entries: self.vitAData, label: "Vitamin A")
        set.valueFormatter = BarChartYValueUnitValueFormatter(unit: "%")
        set.colors = [UIColor(red: 0.1019, green: 0.4823, blue: 0.8235, alpha: 1.0)]
        set.valueTextColor = .black
        let data = BarChartData(dataSet: set)
        vitABarChartView.data = data
    }
    
    // set data for vitamin C bar chart
    func setVitCData() {
        let set = BarChartDataSet(entries: self.vitCData, label: "Vitamin C")
        set.valueFormatter = BarChartYValueUnitValueFormatter(unit: "%")
        set.colors = [UIColor(red: 0.1019, green: 0.4823, blue: 0.8235, alpha: 1.0)]
        set.valueTextColor = .black
        let data = BarChartData(dataSet: set)
        vitCBarChartView.data = data
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // have a different segment selected depending on which segue was triggered
        if segue.identifier == segueToProteinVisualizationsIdentifier, let visualizationsVC = segue.destination as? VisualizationsPageViewController {
            // set segmented to be on protein
            visualizationsVC.selectedSegmentIndex = 0
            visualizationsVC.delegate = self
        }
        else if segue.identifier == segueToCaloriesVisualizationsIdentifier, let visualizationsVC = segue.destination as? VisualizationsPageViewController {
            // set segmented to be on calories
            visualizationsVC.selectedSegmentIndex = 1
            visualizationsVC.delegate = self
        }
    }
}

// extension function for Calendar class
extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components)!
    }
}
