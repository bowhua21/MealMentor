//
//  UserAccountDatabase.swift
//  HuangBowen-HW2
//
//  Created by Bowen Huang on 2/7/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import UIKit


let db = Firestore.firestore()

internal func isValidEmail(_ email: String) -> Bool {
    let emailRegEx =
    "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPred = NSPredicate(format:"SELF MATCHES %@",
                                emailRegEx)
    return emailPred.evaluate(with: email)
}

internal func isValidPassword(_ password: String) -> Bool {
    let minPasswordLength = 6
    return password.count >= minPasswordLength
}

internal func isUserLoggedIn() -> Bool {
    return Auth.auth().currentUser != nil
}


internal func updateDocument(doc: DocumentReference, category: String, value: Any) {
    doc.updateData([category: value]) { error in
        if let error = error {
            print("Error: \(error)")
        }
    }
}



internal func getDocumentData(from docRef: DocumentReference, category: String, completion: @escaping (Any?, Error?) -> Void) {
    
    docRef.getDocument { document, error in
        if let error = error {
            completion(nil, error)
            return
        }
        
        if let document = document, document.exists {
            let value = document.data()?[category]
            completion(value, nil)
        } else {
            completion(nil, NSError(domain: "Firestore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"]))
        }
    }
}


//copied from https://stackoverflow.com/questions/24263007/how-to-use-hex-color-values
//function to transform a color hex string to a UIColor in swift
internal func hexStringToUIColor (hex:String, alphaVal:Double) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(alphaVal)
    )
}


internal func createUserDefaultData(password: String) {
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
        "gender": "none",
        "goals": "",
        "height": 0,
        "lastName": "",
        "nutritionfocuses": "",
        "password": password,
        "verboseResponsePreference": false,
        "weight": 0,
        "darkMode": false
    ] as [String : Any]
    
    db.collection("users").document(currentUser!.uid).setData(newUserData) { error in
        if let error = error {
            print("Error: \(error)")
            return
        }
    }
}

internal func errorAlertController(title: String, message: String) -> UIAlertController {
    let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
    controller.addAction(UIAlertAction(title: "OK", style: .default))
    return controller
}
