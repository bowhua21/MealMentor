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
    
    
    @IBOutlet weak var goalsField: UITextField!
    
    @IBOutlet weak var allergiesField: UITextField!
    
    @IBOutlet weak var dietRestrictionsField: UITextField!
    
    @IBOutlet weak var nutritionFocusField: UITextField!
    
    @IBOutlet weak var firstNameField: UITextField!
    
    @IBOutlet weak var lastNameField: UITextField!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        goalsField.delegate = self
        allergiesField.delegate = self
        dietRestrictionsField.delegate = self
        nutritionFocusField.delegate = self
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
    
    @IBAction func nutritionFocusType(_ sender: Any) {
        updateDocument(doc: userDoc, category: "nutritionfocuses", value: nutritionFocusField.text!)
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


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OnboardingToHomePageIdentifier" {
            if let tabBarController = segue.destination as? UITabBarController {
                tabBarController.loadViewIfNeeded()
                tabBarController.selectedIndex = 2
                if let homeVC = tabBarController.viewControllers?[2] as? HomePageViewController {
                    homeVC.userName = firstNameField.text!
                }
            }
        }
    }


}
