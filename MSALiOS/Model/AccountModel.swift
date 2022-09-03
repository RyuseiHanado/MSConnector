//
//  PostData.swift
//  MARVEL-Pictorial-Book
//
//  Created by 花堂　瑠聖 on 2022/08/04.
//

import Foundation
import SwiftyJSON

struct Account {
    
//    static var currentAccount: MSALAccount? = nil
    
    static var accountData: JSON = []
    static var accountImage: Data? = nil
    
    static var displayName: String {
        accountData["displayName"].stringValue
    }
    static var officeLocation: String {
        accountData["officeLocation"].stringValue
    }
    static var jobTitle: String {
        accountData["jobTitle"].stringValue
    }
    static var mail: String {
        accountData["mail"].stringValue
    }
    static var id: String {
        accountData["id"].stringValue
    }
    
//    static var businessPhones: [String] {
//        accountData["businessPhones"].array!
//    }
}
