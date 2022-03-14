//
//  Request.swift
//  GriDot
//
//  Created by 박찬울 on 2022/03/14.
//

import UIKit

enum RequestMethod: String {
    case Get = "GET"
    case Post = "POST"
}

struct RequestHeaders {
    var Content_Type: String
    var x_chain_id: String
    var Authorization: String
}

struct AccountList: Codable {
    let cursor: String
    let items: [Acount]
}

struct Acount: Codable {
    let address: String
    let chainId: Int
    let createdAt: Int
    let keyId: String
    let krn: String
    let publicKey: String
    let updatedAt: Int
}

func request(_ url: String, _ method: RequestMethod, _ headers: RequestHeaders? = nil, _ params: [String: Any]? = nil, compleiton: @escaping (Bool, Any)->Void) throws {
    let req = NSMutableURLRequest(
        url: NSURL(string: url)! as URL,
        cachePolicy: .useProtocolCachePolicy,
        timeoutInterval: 10.0
    )
    
    req.httpMethod = method.rawValue
    if let headers = headers {
        req.allHTTPHeaderFields = [
            "Content-Type": headers.Content_Type,
            "x-chain-id": headers.x_chain_id,
            "Authorization": headers.Authorization
        ]
    }
    
    switch method {
    case .Get:
        URLSession.shared.dataTask(with: req as URLRequest) {
            (data, res, error) -> Void in
            if (error != nil) {
                print(error! as Any)
            } else {
                let httpResponse = res as? HTTPURLResponse
                print(httpResponse as Any)
            }
            guard let data = data else {
                print("Did not receive data")
                return
            }
            guard let output = try? JSONDecoder().decode(AccountList.self, from: data) else {
                print("JSON data parsing failed")
                return
            }
            compleiton(true, output)
        }.resume()
    case .Post:
        print("post")
    }
}
