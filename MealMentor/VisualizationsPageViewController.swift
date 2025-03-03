//
//  VisualizationsPageViewController.swift
//  MealMentor
//
//  Created by Gina Jeon on 3/2/25.
//

import UIKit

class VisualizationsPageViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var selectedSegmentIndex = 0
    var delegate: UIViewController!
    // each floating cell
    
    @IBOutlet weak var dataTodayView: UIView!
    @IBOutlet weak var weeklyDataView: UIView!
    @IBOutlet weak var monthlyDataView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onSegmentedChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            print("0")
        case 1:
            print("1")
        default:
            print("default")
        }
    }
    
}
