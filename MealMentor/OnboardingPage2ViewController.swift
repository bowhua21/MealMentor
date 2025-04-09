//
//  OnboardingPage2ViewController.swift
//  MealMentor
//
//  Created by Bowen Huang on 2/24/25.
//

import UIKit
import FirebaseAuth

class OnboardingPage2ViewController: UIViewController, UITextFieldDelegate {

    let userDoc = db.collection("users").document(Auth.auth().currentUser!.uid)
    
    var nutritionList : Set = Set<String>()
    
    @IBOutlet weak var goalsField: UITextField!
    
    @IBOutlet weak var allergiesField: UITextField!
    
    @IBOutlet weak var dietRestrictionsField: UITextField!
        
    @IBOutlet weak var firstNameField: UITextField!
    
    @IBOutlet weak var lastNameField: UITextField!
        
    @IBOutlet weak var vitaminClabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    
    @IBOutlet weak var fatLabel: UILabel!
    
    @IBOutlet weak var proteinLabel: UILabel!
    
    @IBOutlet weak var fiberLabel: UILabel!
    @IBOutlet weak var vitaminALabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    
    
    @IBOutlet weak var caloriesSwitch: UISwitch!
    
    @IBOutlet weak var proteinSwitch: UISwitch!
    @IBOutlet weak var vitaminCSwitch: UISwitch!
    
    @IBOutlet weak var vitaminASwitch: UISwitch!
    @IBOutlet weak var fatSwitch: UISwitch!
    
    @IBOutlet weak var fiberSwitch: UISwitch!
    @IBOutlet weak var carbsSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goalsField.delegate = self
        allergiesField.delegate = self
        dietRestrictionsField.delegate = self
        firstNameField.delegate = self
        lastNameField.delegate = self

        // Do any additional setup after loading the view.
    }
    // Called when 'return' key pressed
    
    
    @IBAction func firstNameType(_ sender: Any) {
        updateDocument(doc: userDoc, category: "firstName", value: firstNameField.text!)
    }
    
    @IBAction func lastNameType(_ sender: Any) {
        updateDocument(doc: userDoc, category: "lastName", value: lastNameField.text!)
    }
    
    @IBAction func goalsType(_ sender: Any) {
        updateDocument(doc: userDoc, category: "goals", value: goalsField.text!)
    }
    
    @IBAction func allergiesType(_ sender: Any) {
        updateDocument(doc: userDoc, category: "allergies", value: allergiesField.text!)
    }
    
    @IBAction func dietaryRestrictionsType(_ sender: Any) {
        updateDocument(doc: userDoc, category: "dietaryRestrictions", value: dietRestrictionsField.text!)
    }
    
    
    
    @IBAction func toHomePage(_ sender: Any) {
        let firstName = firstNameField.text!
        let lastName = lastNameField.text!
        if firstName.isEmpty || lastName.isEmpty {
            present(errorAlertController(title: "Error", message: "Please fill in both first and last name"), animated: true)
        } else {
                self.performSegue(withIdentifier: "OnboardingToHomePageIdentifier", sender: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func fiberAction(_ sender: Any) {
        updateNutrition(conditionSwitch: fiberSwitch, nutrition: "fiber", conditionLabel: fiberLabel)
    }
    
    @IBAction func caloriesAction(_ sender: Any) {
        updateNutrition(conditionSwitch: caloriesSwitch, nutrition: "calories", conditionLabel: caloriesLabel)
    }
    @IBAction func vitaminAAction(_ sender: Any) {
        updateNutrition(conditionSwitch: vitaminASwitch, nutrition: "vitamin A", conditionLabel: vitaminALabel)
    }
    @IBAction func carbsAction(_ sender: Any) {
        updateNutrition(conditionSwitch: carbsSwitch, nutrition: "carbohydrates", conditionLabel: carbsLabel)
    }
    
    @IBAction func vitaminCAction(_ sender: Any) {
        updateNutrition(conditionSwitch: vitaminCSwitch, nutrition: "vitamin C", conditionLabel: vitaminClabel)
    }
    
    @IBAction func proteinAction(_ sender: Any) {
        updateNutrition(conditionSwitch: proteinSwitch, nutrition: "protein", conditionLabel: proteinLabel)
    }
    
    @IBAction func fatAction(_ sender: Any) {
        updateNutrition(conditionSwitch: fatSwitch, nutrition: "fat", conditionLabel: fatLabel)
    }
    
    
    private func updateNutrition(conditionSwitch : UISwitch, nutrition : String, conditionLabel : UILabel) {
        if conditionSwitch.isOn {
            conditionLabel.textColor = UIColor.black
            nutritionList.insert(nutrition)
        } else {
            conditionLabel.textColor = UIColor.lightGray
            nutritionList.remove(nutrition)
        }
        updateDocument(doc: userDoc, category: "nutritionfocuses", value: nutritionList.description)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OnboardingToHomePageIdentifier" {
            if let tabBarController = segue.destination as? UITabBarController {
                tabBarController.loadViewIfNeeded()
                tabBarController.selectedIndex = 2
                if let homeVC = tabBarController.viewControllers?[2] as? HomePageViewController {
                }
            }
        }
    }


}
