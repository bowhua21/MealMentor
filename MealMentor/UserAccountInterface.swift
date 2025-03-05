//
//  UserAccountDatabase.swift
//  HuangBowen-HW2
//
//  Created by Bowen Huang on 2/7/25.
//

import Foundation
import FirebaseAuth


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
