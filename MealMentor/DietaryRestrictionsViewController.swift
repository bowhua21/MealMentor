//
//  DietaryRestrictionsViewController.swift
//  MealMentor
//
//  Created by Bowen Huang on 3/11/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class DietaryRestrictionsViewController: UIViewController, UITextViewDelegate {
    let userDoc = db.collection("users").document(Auth.auth().currentUser!.uid)
    
    @IBOutlet weak var goalsTextField: UITextView!
    
    @IBOutlet weak var dietRestrictionsTextField: UITextView!
    
    
    @IBOutlet weak var allergiesTextField: UITextView!
    
    @IBOutlet weak var nutritionFocusTextField: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goalsTextField.delegate = self
        dietRestrictionsTextField.delegate = self
        allergiesTextField.delegate = self
        nutritionFocusTextField.delegate = self
        
        getDocumentData(from: userDoc, category: "goals") { value, error in
            if let error = error {
                print("Error fetching field: \(error.localizedDescription)")
            } else if let value = value {
                print("Fetched field value: \(value)")
                self.goalsTextField.text = value as? String
            } else {
                print("Field does not exist")
            }
        }
        getDocumentData(from: userDoc, category: "dietaryRestrictions") { value, error in
            if let error = error {
                print("Error fetching field: \(error.localizedDescription)")
            } else if let value = value {
                print("Fetched field value: \(value)")
                self.dietRestrictionsTextField.text = value as? String
            } else {
                print("Field does not exist")
            }
        }
        getDocumentData(from: userDoc, category: "allergies") { value, error in
            if let error = error {
                print("Error fetching field: \(error.localizedDescription)")
            } else if let value = value {
                print("Fetched field value: \(value)")
                self.allergiesTextField.text = value as? String
            } else {
                print("Field does not exist")
            }
        }
        getDocumentData(from: userDoc, category: "nutritionfocuses") { value, error in
            if let error = error {
                print("Error fetching field: \(error.localizedDescription)")
            } else if let value = value {
                print("Fetched field value: \(value)")
                self.nutritionFocusTextField.text = value as? String
            } else {
                print("Field does not exist")
            }
        }
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        updateDocument(doc: userDoc, category: "goals", value: goalsTextField.text!)
        updateDocument(doc: userDoc, category: "dietaryRestrictions", value: dietRestrictionsTextField.text!)
        updateDocument(doc: userDoc, category: "allergies", value: allergiesTextField.text!)
        updateDocument(doc: userDoc, category: "nutritionfocuses", value: nutritionFocusTextField.text!)
    }
    
    // Called when 'return' key pressed

    func textFieldShouldReturn(_ textField:UITextView) -> Bool {
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
