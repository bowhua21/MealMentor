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
    
    // each floating cell
    @IBOutlet weak var dataTodayView: UIView!
    @IBOutlet weak var weeklyDataView: UIView!
    @IBOutlet weak var monthlyDataView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // setup calories bar chart
        weeklyDataView.addSubview(barChartView)
        barChartView.center(in: weeklyDataView, offset: CGPoint(x: 0, y: 10))
        barChartView.width(360)
        barChartView.height(130)
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
            print("0")
            weeklyNutritionLabel.text = "Protein"
            setBarChartData(nutritionData: self.proteinBarChartData, label: "Protein", unit: "g", barChartView: self.barChartView)
        case 1:
            print("1")
            weeklyNutritionLabel.text = "Calories"
            setBarChartData(nutritionData: self.caloriesBarChartData, label: "Calories", unit: "kcal", barChartView: self.barChartView)
        case 2:
            print("2")
            weeklyNutritionLabel.text = "Carbohydrates"
            setBarChartData(nutritionData: self.carbsBarChartData, label: "Carbohydrates", unit: "g", barChartView: self.barChartView)
        case 3:
            print("3")
            weeklyNutritionLabel.text = "Fat"
            setBarChartData(nutritionData: self.fatBarChartData, label: "Fat", unit: "g", barChartView: self.barChartView)
        case 4:
            print("4")
            weeklyNutritionLabel.text = "Fiber"
            setBarChartData(nutritionData: self.fiberBarChartData, label: "Fiber", unit: "g", barChartView: self.barChartView)
        case 5:
            print("5")
            weeklyNutritionLabel.text = "Vitamin A"
            setBarChartData(nutritionData: self.vitABarChartData, label: "Vitamin A", unit: "%", barChartView: self.barChartView)
        case 6:
            print("6")
            weeklyNutritionLabel.text = "Vitamin C"
            setBarChartData(nutritionData: self.vitCBarChartData, label: "Vitamin C", unit: "%", barChartView: self.barChartView)
        default:
            print("default")
        }
    }
}
