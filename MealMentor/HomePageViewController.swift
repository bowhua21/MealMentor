//
//  HomePageViewController.swift
//  MealMentor
//
//  Created by Gina Jeon on 2/23/25.
//

import UIKit

// TODO delete later
let dummyMeals = ["Oatmeal with berries", "fake meal 1", "fake meal 2", "fake meal 3", "fake meal 4"]
let dummyNutrition = ["350 kcal, 10g Protein, 60g Carbs, 5g Fat", "fake nutrition 1", "fake nutrition 2", "fake nutrition 3", "fake nutrition 4"]

class HomePageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    // home screen properties
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var numDaysLoggedThisMonth: UILabel!
    @IBOutlet weak var numDayStreak: UILabel!
    
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
    //    TODO tracked days
//    var trackedDays: [Date] = []
    var daysOfWeek: [Date] = []
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
        thisWeekCollectionView.layer.backgroundColor  = UIColor.clear.cgColor
        let today = Date()
        let startOfWeek = Calendar.current.startOfWeek(for: today)
        daysOfWeek = getDaysOfWeek(startOfWeek: startOfWeek)
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
        cell.configure(with: date, isTracked: false)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
