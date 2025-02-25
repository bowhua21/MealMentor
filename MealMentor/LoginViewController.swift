import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
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
            statusLabelField.text = userName + " successfully logged in"
            self.performSegue(withIdentifier: "LoginToHomePageIdentifier", sender: nil)
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

