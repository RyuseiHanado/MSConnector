//
//  MSGraphManager.swift
//  MSALiOS
//
//  Created by 花堂　瑠聖 on 2022/09/04.
//  Copyright © 2022 Microsoft. All rights reserved.
//

import Foundation
import MSAL
import SwiftyJSON

class MSGraphManager: ObservableObject {
    
    func getMailListEndpoint() -> String {
        return K.kMailListEndpoint.hasSuffix("/") ? (K.kMailListEndpoint) : (K.kMailListEndpoint);
    }
    
    func postMailEndpoint() -> String {
        return K.kSendMailEndpoint.hasSuffix("/") ? (K.kSendMailEndpoint) : (K.kSendMailEndpoint);
    }
    
    // 引数でクロージャを受け取る
    func getMailList(operation:@escaping()->Void) {
        
        print("getMailList")
        
        // Specify the Graph API endpoint
        let graphURI = getMailListEndpoint()
        let url = URL(string: graphURI)
        var request = URLRequest(url: url!)
        
        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        request.setValue("Bearer \(K.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                self.updateLogging(text: "Couldn't get graph result: \(error)")
                return
            }
            
            let decoder = JSONDecoder()
            if let safeData = data {
                do {
                    let result = try decoder.decode(Results.self, from: safeData)
                    DispatchQueue.main.sync {
                        Account.mailList = result.value
                        print("firstMail: \(Account.mailList[0].subject)")
                        print(Account.mailList.count)
                        // 引数で受け取ったクロージャを実行
                        operation()
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    func postMail() {
        print("post mail!!")
        
        
    }
    
    func updateLogging(text : String) {
        print("updateLogging")
        print(text)
    }
}
