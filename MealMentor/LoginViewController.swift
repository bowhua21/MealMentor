import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userIDField: UITextField!
 
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var statusLabelField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        userIDField.delegate = self
        passwordField.delegate = self
        passwordField.isSecureTextEntry = true
        
        Auth.auth().addStateDidChangeListener() {
            (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: "LoginToHomePageIdentifier", sender: nil)
                self.userIDField.text = nil
                self.passwordField.text = nil
            }
        }
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        let userName = userIDField.text!
        let password = passwordField.text!
        if userName.isEmpty || password.isEmpty {
            statusLabelField.text = "Please fill in all fields"
        } else if !isValidEmail(userName) {
            statusLabelField.text = "Invalid email format"
        } else if !isValidPassword(password) {
            statusLabelField.text = "The password is too short"
        } else {
            Auth.auth().signIn(withEmail: userName, password: password) {
                (authResult, error) in
                if let error = error as NSError? {
                    self.statusLabelField.text = "Database error - \(error.localizedDescription)"
                } else {
                    self.statusLabelField.text = userName + " successfully logged in"
                }
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginToHomePageIdentifier", let tabBarController = segue.destination as? UITabBarController {
            tabBarController.selectedIndex = 0
            if let homePageNav = tabBarController.viewControllers?[0] as? UINavigationController,
               let homePageVC = homePageNav.topViewController as? HomePageViewController {
                homePageVC.userName = userIDField.text!
            }
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

