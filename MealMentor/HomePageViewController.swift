//
//  HomePageViewController.swift
//  MealMentor
//
//  Created by Gina Jeon on 2/23/25.
//

import UIKit
import DGCharts
import TinyConstraints

// TODO delete later
let dummyMeals = ["Oatmeal with berries", "fake meal 1", "fake meal 2", "fake meal 3", "fake meal 4"]
let dummyNutrition = ["350 kcal, 10g Protein, 60g Carbs, 5g Fat", "fake nutrition 1", "fake nutrition 2", "fake nutrition 3", "fake nutrition 4"]
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

class HomePageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    // home screen properties
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var numDaysLoggedThisMonth: UILabel!
    @IBOutlet weak var numDayStreak: UILabel!
    @IBOutlet weak var proteinCellButton: UIButton!
    @IBOutlet weak var caloriesCellButton: UIButton!
    var userName:String = "Jane Doe"
    // each floating cell
    @IBOutlet weak var highlightsView: UIView!
    @IBOutlet weak var thisWeekView: UIView!
    @IBOutlet weak var todayMealsView: UIView!
    @IBOutlet weak var weeklyProteinView: UIView!
    @IBOutlet weak var weeklyCaloriesView: UIView!
    // today's meals table view within todayMealsView
    let tableViewCellIdentifier = "TableViewCellIdentifier"
    @IBOutlet weak var todayMealsTableView: UITableView!
    // calendar collection within thisWeekView
    @IBOutlet weak var thisWeekCollectionView: UICollectionView!
    // TODO tracked days
    // var trackedDays: [Date] = []
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
        chartView.legend.enabled = false
        
        return chartView
    }()
    // segue identifiers
    let segueToProteinVisualizationsIdentifier = "SegueToProteinVisualizationsIdentifier"
    let segueToCaloriesVisualizationsIdentifier = "SegueToCaloriesVisualizationsIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username.text = userName
        // Do any additional setup after loading the view.
        // TODO set username
        
        // setup today's meals
        todayMealsTableView.dataSource = self
        todayMealsTableView.delegate = self
        
        // setup this week calendar collection view
        thisWeekCollectionView.dataSource = self
        thisWeekCollectionView.delegate = self
        thisWeekCollectionView.layer.backgroundColor = UIColor.clear.cgColor
        let today = Date()
        let startOfWeek = Calendar.current.startOfWeek(for: today)
        daysOfWeek = getDaysOfWeek(startOfWeek: startOfWeek)
        
        // setup protein bar chart
        weeklyProteinView.addSubview(proteinBarChartView)
        proteinBarChartView.center(in: weeklyProteinView, offset: CGPoint(x: 0, y: 10))
        proteinBarChartView.width(360)
        proteinBarChartView.height(130)
        setProteinData()
        // make sure protein cell button is still clickable
        weeklyProteinView.bringSubviewToFront(proteinCellButton)
        
        // setup calories bar chart
        weeklyCaloriesView.addSubview(caloriesBarChartView)
        caloriesBarChartView.center(in: weeklyCaloriesView, offset: CGPoint(x: 0, y: 10))
        caloriesBarChartView.width(360)
        caloriesBarChartView.height(130)
        setCaloriesDate()
        // make sure calories cell button is still clickable
        weeklyCaloriesView.bringSubviewToFront(caloriesCellButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // put rounded corners for cells
        highlightsView.layer.cornerRadius = 20
        thisWeekView.layer.cornerRadius = 20
        todayMealsView.layer.cornerRadius = 20
        weeklyProteinView.layer.cornerRadius = 20
        weeklyCaloriesView.layer.cornerRadius = 20
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysOfWeek.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThisWeekDayCell.identifier, for: indexPath) as! ThisWeekDayCell
        let date = daysOfWeek[indexPath.row]
        // (dummy configuration) TODO change to tracked days
        if indexPath.row == 3 || indexPath.row == 5 {
            cell.configure(with: date, isTracked: false)
        }
        else {
            cell.configure(with: date, isTracked: true)
        }
        //TODO check if day is tracked
//        let isTracked = trackedDays.contains { Calendar.current.isDate($0, inSameDayAs: date) }
//        cell.configure(with: day, isTracked: true)
        return cell
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
        dummyMeals.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier, for: indexPath)
        cell.textLabel?.text = dummyMeals[indexPath.section]
        cell.detailTextLabel?.text = dummyNutrition[indexPath.section]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // set data for protein bar chart
    func setProteinData() {
        let set = BarChartDataSet(entries: dummyDataPts, label: "Protein")
        set.valueFormatter = BarChartYValueUnitValueFormatter(unit: "g")
        set.colors = [UIColor(red: 0.1019, green: 0.4823, blue: 0.8235, alpha: 1.0)]
        let data = BarChartData(dataSet: set)
        proteinBarChartView.data = data
    }
    
    // set data for calories bar chart
    func setCaloriesDate() {
        let set = BarChartDataSet(entries: dummyDataPts2, label: "Calories")
        set.valueFormatter = BarChartYValueUnitValueFormatter(unit: "cal")
        set.colors = [UIColor(red: 0.1019, green: 0.4823, blue: 0.8235, alpha: 1.0)]
        let data = BarChartData(dataSet: set)
        caloriesBarChartView.data = data
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
