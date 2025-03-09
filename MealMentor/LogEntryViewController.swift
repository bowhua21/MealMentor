//
//  LogEntryViewController.swift
//  MealMentor
//
//  Created by Gina Jeon on 3/6/25.
//

import UIKit




class LogEntryViewController: UIViewController {
    var userInput: String?
    
    @IBOutlet weak var logTextField: UITextField!
    
    @IBOutlet weak var mealLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func finishClicked(_ sender: Any) {
        userInput = logTextField.text
        print("hi")
    }
    
}
