//
//  OnboardingPage2ViewController.swift
//  MealMentor
//
//  Created by Bowen Huang on 2/24/25.
//

import UIKit

class OnboardingPage2ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var goalsField: UITextField!
    
    @IBOutlet weak var allergiesField: UITextField!
    
    @IBOutlet weak var dietRestrictionsField: UITextField!
    
    @IBOutlet weak var nutritionFocusField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goalsField.delegate = self
        allergiesField.delegate = self
        dietRestrictionsField.delegate = self
        nutritionFocusField.delegate = self

        // Do any additional setup after loading the view.
    }
    // Called when 'return' key pressed
    
    
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
