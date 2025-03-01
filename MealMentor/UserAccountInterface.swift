//
//  UserAccountDatabase.swift
//  HuangBowen-HW2
//
//  Created by Bowen Huang on 2/7/25.
//

import Foundation
import FirebaseAuth

//protocol UserAccountInterface {
//    var accounts:[String: String] {get set}
    
//    func addNewAccount (username: String, password: String)
    
//    func validLogin (username: String, password: String) -> Bool
    
//    func usernameExists(username: String) -> Bool
    
//}

public var accounts: [String : String] = [:]

public func addNewAccount(username: String, password: String) {
    //create new user account here
    accounts[username] = password
    
//    Auth.auth().createUser(withEmail: username, password: password) {
//        (authResult, error) in
//        if let error = error as NSError? {
//            
//        }
//    }
}

public func validLogin(username: String, password: String) -> Bool {
    if !usernameExists(username: username) {
        return false
    }
    if !isValidPassword(password) || accounts[username] != password {
        return false
    }
    return true
}

public func usernameExists(username: String) -> Bool {
    return isValidEmail(username) && accounts.contains { $0.key == username}
}

public func isValidEmail(_ email: String) -> Bool {
    let emailRegEx =
    "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPred = NSPredicate(format:"SELF MATCHES %@",
                                emailRegEx)
    return emailPred.evaluate(with: email)
}

public func isValidPassword(_ password: String) -> Bool {
    let minPasswordLength = 6
    return password.count >= minPasswordLength
}

public func isUserLoggedIn() -> Bool {
    return Auth.auth().currentUser != nil
}
