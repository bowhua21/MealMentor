//
//  UserAccountDatabase.swift
//  HuangBowen-HW2
//
//  Created by Bowen Huang on 2/7/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore


let db = Firestore.firestore()

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

public func createUserDefaultData(password: String) {
    if !isUserLoggedIn() {
        return
    }
    
    let currentUser = Auth.auth().currentUser
    
    let newUserData = [
        "age": 0,
        "allergies": "",
        "dietaryRestrictions": "",
        "email": currentUser?.email,
        "firstName": "",
        "gender": "",
        "goals": "",
        "height": 0,
        "lastName": "",
        "nutritionfocuses": "",
        "password": password,
        "weight": 0
    ] as [String : Any]
    
    db.collection("users").document(currentUser!.uid).setData(newUserData) { error in
        if let error = error {
            print("Error: \(error)")
            return
        }
    }
    db.collection("users")
}
