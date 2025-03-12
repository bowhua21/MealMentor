//
//  ChangePasswordViewController.swift
//  MealMentor
//
//  Created by Bowen Huang on 3/11/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var statusFieldLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newPasswordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        newPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let newPass = newPasswordTextField.text!
        let confirmPass = confirmPasswordTextField.text!
        if newPass.isEmpty || confirmPass.isEmpty {
            statusFieldLabel.text = "Please fill in all fields"
        } else if !isValidPassword(newPass) {
            statusFieldLabel.text = "The password is too short"
        } else if newPass != confirmPass {
            statusFieldLabel.text = "The passwords do not match"
        } else {
            let userDoc = db.collection("users").document(Auth.auth().currentUser!.uid)
            updateDocument(doc: userDoc, category: "password", value: newPass)
            statusFieldLabel.text = "Successfully changed password"
            self.dismiss(animated: true)
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
}
