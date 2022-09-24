//
//  SendMailModel.swift
//  MSALiOS
//
//  Created by 花堂　瑠聖 on 2022/09/05.
//  Copyright © 2022 Microsoft. All rights reserved.
//

import Foundation

//struct SendMailModel: Decodable {
//    let message: Message
//    let saveToSentItems: Bool
//}
//
//struct Message: Decodable {
//    let subject: String
//    let body: Body
//    let toRecipients: [EmailAddress]
//    let ccRecipients: [EmailAddress]
//}
//
//struct Body: Decodable {
//    let contentType:  String
//    let content:  String
//}
//
//struct EmailAddress: Decodable {
//    let address: String
//}

import Foundation
 
func test() {
    // hobbyひとつめのメンバを作成
    var hobby1 = Dictionary<String, Any>()
    hobby1["name"] = "sports"
    hobby1["startyear"] = 2000
     
    // hobbyふたつめのメンバを作成
    var hobby2 = Dictionary<String, Any>()
    hobby2["name"] = "movie"
    hobby2["startyear"] = 1992
     
    // hobbyふたつのメンバをArrayに追加
    var hobbyArray = Array<Dictionary<String, Any>>()
    hobbyArray.append(hobby1)
    hobbyArray.append(hobby2)
     
    var json = Dictionary<String, Any>()
    json["id"] = 1 // メンバid 値はInt
    json["name"] = "Suzuki" // メンバname 値はString
    json["hobby"] = hobbyArray // メンバhobby 値はArray
     
    do {
        // DictionaryをJSONデータに変換
        let jsonData = try JSONSerialization.data(withJSONObject: json)
        // JSONデータを文字列に変換
        let jsonStr = String(bytes: jsonData, encoding: .utf8)!
        print(jsonStr)
    } catch (let e) {
        print(e)
    }
}
