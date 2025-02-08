//
//  UserAccountDatabase.swift
//  HuangBowen-HW2
//
//  Created by Bowen Huang on 2/7/25.
//

import Foundation

protocol UserAccountInterface {
    var accounts:[String: String] {get set}
    
    func addNewAccount (username: String, password: String)
    
    func validLogin (username: String, password: String) -> Bool
    
    func usernameExists(username: String) -> Bool
    
}
