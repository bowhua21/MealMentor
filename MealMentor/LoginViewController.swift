import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userIDField: UITextField!
 
    @IBOutlet weak var passwordField: UITextField!
        
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
            present(errorAlertController(title: "Error", message: "Please fill in all fields"), animated: true)
        } else if !isValidEmail(userName) {
            present(errorAlertController(title: "Error", message: "Invalid email format"), animated: true)
        } else if !isValidPassword(password) {
            present(errorAlertController(title: "Error", message: "The password is too short"), animated: true)
        } else {
            Auth.auth().signIn(withEmail: userName, password: password) {
                (authResult, error) in
                if let error = error as NSError? {
                    self.present(errorAlertController(title: "Error", message: "Database error - \(error.localizedDescription)"), animated: true)
                }
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginToHomePageIdentifier", let tabBarController = segue.destination as? UITabBarController {
            tabBarController.selectedIndex = 2
            if let homePageNav = tabBarController.viewControllers?[2] as? UINavigationController,
               let homePageVC = homePageNav.topViewController as? HomePageViewController {
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

