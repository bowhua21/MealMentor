import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userIDField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    @IBOutlet weak var statusLabelField: UILabel!
    var delegate: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userIDField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func createAccountPressed(_ sender: Any) {
        let loginVC = delegate as! UserAccountInterface
        let userName = userIDField.text!
        let password = passwordField.text!
        let confirmPass = confirmPasswordField.text!
        if userName.isEmpty || password.isEmpty || confirmPass.isEmpty {
            statusLabelField.text = "Please fill in all fields"
        } else if password != confirmPass {
            statusLabelField.text = "The passwords do not match"
        } else if loginVC.usernameExists(username: userName) {
            statusLabelField.text = "Username already exists"
        } else {
            loginVC.addNewAccount(username: userName, password: password)
            statusLabelField.text = "Successfully created new account"
            self.dismiss(animated: true)
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
