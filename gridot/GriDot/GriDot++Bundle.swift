//
//  GriDot++Bundle.swift
//  GriDot
//
//  Created by 박찬울 on 2022/02/26.
//

import Foundation

struct KasKey {
    let accessKeyId: String
    let secretAccessKey: String
    let authorization: String
}

extension Bundle {
    var kasApiKey: KasKey? {
        guard let file = self.path(forResource: "kas-credential", ofType: "plist") else { return nil }
        guard let src = NSDictionary(contentsOfFile: file) else { return nil }
        
        if let keyId = src["accessKeyId"] as? String,
           let accessKey = src["secretAccessKey"] as? String,
           let auth = src["authorization"] as? String
        {
            return KasKey(accessKeyId: keyId, secretAccessKey: accessKey, authorization: auth)
        } else {
            fatalError("kas-credential.plist에 설정을 해주세요")
        }
    }
}
