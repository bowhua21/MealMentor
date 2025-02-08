import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, UserAccountInterface {

    var accounts: [String : String] = [:]
    
    @IBOutlet weak var userIDField: UITextField!
 
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var statusLabelField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        userIDField.delegate = self
        passwordField.delegate = self
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        let userName = userIDField.text!
        let password = passwordField.text!
        if userName.isEmpty || password.isEmpty {
            statusLabelField.text = "Please fill in all fields"
        } else if !validLogin(username: userName, password: password){
            statusLabelField.text = "Invalid login"
        } else {
            statusLabelField.text = userName + "successfully logged in"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RegisterSegue", let registerVC = segue.destination as? RegisterViewController {
            
            registerVC.delegate = self
        }
    }
    
    func addNewAccount(username: String, password: String) {
        accounts[username] = password
    }
    
    func validLogin(username: String, password: String) -> Bool {
        if !usernameExists(username: username) {
            return false
        }
        if accounts[username] != password {
            return false
        }
        return true
    }
    
    func usernameExists(username: String) -> Bool {
        return accounts.contains { $0.key == username}
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

