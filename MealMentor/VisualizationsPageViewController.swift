//
//  VisualizationsPageViewController.swift
//  MealMentor
//
//  Created by Gina Jeon on 3/2/25.
//

import UIKit
import DGCharts

class VisualizationsPageViewController: DarkModeViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var weeklyNutritionLabel: UILabel!
    @IBOutlet weak var monthlyNutritionLabel: UILabel!
    var selectedSegmentIndex = 0
    var delegate: UIViewController!
    // weekly bar chart
    lazy var barChartView: BarChartView = {
        makeBaseBarChartView()
    }()
    var proteinBarChartData: [BarChartDataEntry] = []
    var caloriesBarChartData: [BarChartDataEntry] = []
    var carbsBarChartData: [BarChartDataEntry] = []
    var fatBarChartData: [BarChartDataEntry] = []
    var fiberBarChartData: [BarChartDataEntry] = []
    var vitABarChartData: [BarChartDataEntry] = []
    var vitCBarChartData: [BarChartDataEntry] = []
    // monthly line chart
    lazy var lineChartView: LineChartView = {
        makeBaseLineChartView()
    }()
    
    
    // each floating cell
    @IBOutlet weak var dataTodayView: UIView!
    @IBOutlet weak var weeklyDataView: UIView!
    @IBOutlet weak var monthlyDataView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // setup weekly bar chart
        weeklyDataView.addSubview(barChartView)
        barChartView.center(in: weeklyDataView, offset: CGPoint(x: 0, y: 10))
        barChartView.width(360)
        barChartView.height(130)
        // setup monthly line chart
        monthlyDataView.addSubview(lineChartView)
        lineChartView.center(in: monthlyDataView, offset: CGPoint(x: 0, y: 10))
        lineChartView.width(360)
        lineChartView.height(145)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // set selected segment
        segmentedControl.selectedSegmentIndex = selectedSegmentIndex
        segmentedControl.sendActions(for: UIControl.Event.valueChanged)
    }
    
    override func viewDidLayoutSubviews() {
        dataTodayView.layer.cornerRadius = 20
        weeklyDataView.layer.cornerRadius = 20
        monthlyDataView.layer.cornerRadius = 20
    }
    
    
    @IBAction func onSegmentedChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            weeklyNutritionLabel.text = "Protein"
            monthlyNutritionLabel.text = "Protein"
            setBarChartData(nutritionData: self.proteinBarChartData, label: "Protein", unit: "g", barChartView: self.barChartView)
            setLineChartData(nutritionData: dummyMonthlyProteinDataPts, label: "Protein", unit: "g", lineChartView: self.lineChartView)
        case 1:
            weeklyNutritionLabel.text = "Calories"
            monthlyNutritionLabel.text = "Calories"
            setBarChartData(nutritionData: self.caloriesBarChartData, label: "Calories", unit: "kcal", barChartView: self.barChartView)
            setLineChartData(nutritionData: dummyMonthlyCaloriesDataPts, label: "Calories", unit: "kcal", lineChartView: self.lineChartView)
        case 2:
            weeklyNutritionLabel.text = "Carbohydrates"
            monthlyNutritionLabel.text = "Carbohydrates"
            setBarChartData(nutritionData: self.carbsBarChartData, label: "Carbohydrates", unit: "g", barChartView: self.barChartView)
            setLineChartData(nutritionData: dummyMonthlyCarbsDataPts, label: "Carbohydrates", unit: "g", lineChartView: self.lineChartView)
        case 3:
            weeklyNutritionLabel.text = "Fat"
            monthlyNutritionLabel.text = "Fat"
            setBarChartData(nutritionData: self.fatBarChartData, label: "Fat", unit: "g", barChartView: self.barChartView)
            setLineChartData(nutritionData: dummyMonthlyFatDataPts, label: "Fat", unit: "g", lineChartView: self.lineChartView)
        case 4:
            weeklyNutritionLabel.text = "Fiber"
            monthlyNutritionLabel.text = "Fiber"
            setBarChartData(nutritionData: self.fiberBarChartData, label: "Fiber", unit: "g", barChartView: self.barChartView)
            setLineChartData(nutritionData: dummyMonthlyFiberDataPts, label: "Fiber", unit: "g", lineChartView: self.lineChartView)
        case 5:
            weeklyNutritionLabel.text = "Vitamin A"
            monthlyNutritionLabel.text = "Vitamin A"
            setBarChartData(nutritionData: self.vitABarChartData, label: "Vitamin A", unit: "%", barChartView: self.barChartView)
            setLineChartData(nutritionData: dummyMonthlyVitADataPts, label: "Vitamin A", unit: "%", lineChartView: self.lineChartView)
        case 6:
            weeklyNutritionLabel.text = "Vitamin C"
            monthlyNutritionLabel.text = "Vitamin C"
            setBarChartData(nutritionData: self.vitCBarChartData, label: "Vitamin C", unit: "%", barChartView: self.barChartView)
            setLineChartData(nutritionData: dummyMonthlyVitCDataPts, label: "Vitamin C", unit: "%", lineChartView: self.lineChartView)
        default:
            print("default")
        }
    }
}
