import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userIDField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var confirmPasswordField: UITextField!
        
    var delegate: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userIDField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
        passwordField.isSecureTextEntry = true
        confirmPasswordField.isSecureTextEntry = true
        
        Auth.auth().addStateDidChangeListener() {
            (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: "OnboardSegueID", sender: nil)
                self.userIDField.text = nil
                self.passwordField.text = nil
                self.confirmPasswordField.text = nil
            }
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func createAccountPressed(_ sender: Any) {
        let userName = userIDField.text!
        let password = passwordField.text!
        let confirmPass = confirmPasswordField.text!
        if userName.isEmpty || password.isEmpty || confirmPass.isEmpty {
            present(errorAlertController(title: "Error", message: "Please fill in all fields"), animated: true)
        } else if !isValidEmail(userName) {
            present(errorAlertController(title: "Error", message: "Invalid email format"), animated: true)
        } else if !isValidPassword(password) {
            present(errorAlertController(title: "Error", message: "The password is too short"), animated: true)
        } else if password != confirmPass {
            present(errorAlertController(title: "Error", message: "The passwords do not match"), animated: true)
        } else {
            Auth.auth().createUser(withEmail: userName, password: password) {
                (authResult, error) in
                if let error = error as NSError? {
                    self.present(errorAlertController(title: "Error", message: "Database error - \(error.localizedDescription)"), animated: true)
                } else {
                    createUserDefaultData(password: password)
                }
            }
            
            //self.dismiss(animated: true)
        }
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
}
