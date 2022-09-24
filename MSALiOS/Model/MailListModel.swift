import Foundation

// APIから取得するデータ構造に基づいて構成
struct Results: Decodable {
    let value: [MailData]
}

struct MailData: Decodable {
    let body: Body
    let from: From
    let subject: String
}

struct Body: Decodable {
    let content: String
}
struct From: Decodable {
    let emailAddress: EmailAddress
}
struct EmailAddress: Decodable {
    let name: String
    let address: String
}
