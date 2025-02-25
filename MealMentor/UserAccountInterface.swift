//
//  UserAccountDatabase.swift
//  HuangBowen-HW2
//
//  Created by Bowen Huang on 2/7/25.
//

import Foundation

//protocol UserAccountInterface {
//    var accounts:[String: String] {get set}
    
//    func addNewAccount (username: String, password: String)
    
//    func validLogin (username: String, password: String) -> Bool
    
//    func usernameExists(username: String) -> Bool
    
//}

public var accounts: [String : String] = [:]

public func addNewAccount(username: String, password: String) {
    accounts[username] = password
}

public func validLogin(username: String, password: String) -> Bool {
    if !usernameExists(username: username) {
        return false
    }
    if accounts[username] != password {
        return false
    }
    return true
}

public func usernameExists(username: String) -> Bool {
    return accounts.contains { $0.key == username}
}
