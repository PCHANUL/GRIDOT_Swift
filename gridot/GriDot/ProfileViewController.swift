//
//  ProfileViewController.swift
//  GriDot
//
//  Created by 박찬울 on 2022/02/24.
//

import Foundation
import UIKit
import AuthenticationServices

struct KasKey: Codable {
    let accessKeyId: String
    let secretAccessKey: String
    let authorization: String
}

struct AccountList: Codable {
    let cursor: String
    let items: [Item]
}

struct Item: Codable {
    let address: String
    let chainId: Int
    let createdAt: Int
    let keyId: String
    let krn: String
    let publicKey: String
    let updatedAt: Int
}

struct User {
    let userId: String
    let fullName: PersonNameComponents?
    let email: String?
    let authCode: Data?
    let idToken: Data?
}

class ProfileViewController: UIViewController {
    @IBOutlet weak var loginView: UIView!
    var kasKey: KasKey?
    var data: Data?

    override func viewDidLoad() {
        super.viewDidLoad()
        kasKey = getKasKey()
//        getKeyList()
        setupProviderLoginView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        if (data != nil) {
//            let json = try! JSONDecoder().decode(AccountList.self, from: self.data!)
//            print(json)
//        }
    }
    
    func setupProviderLoginView() {
        let appleButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
        appleButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.loginView.addSubview(appleButton)
        
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        appleButton.leadingAnchor.constraint(equalTo: loginView.leadingAnchor).isActive = true
        appleButton.trailingAnchor.constraint(equalTo: loginView.trailingAnchor).isActive = true
        appleButton.topAnchor.constraint(equalTo: loginView.topAnchor).isActive = true
        appleButton.bottomAnchor.constraint(equalTo: loginView.bottomAnchor).isActive = true
    }
    
    @objc func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    func getKeyList() {
        if (kasKey == nil) { return }
        let headers = [
            "Content-Type": "application/json",
            "x-chain-id": "8721",
            "Authorization": kasKey!.authorization
        ]

        let request = NSMutableURLRequest(
            url: NSURL(string: "https://wallet-api.klaytnapi.com/v2/account")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0
        )
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            self.data = data
            print(response)
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
            }
        })
        dataTask.resume()
    }
    
    func getKasKey() -> KasKey? {
        if let path = Bundle.main.url(forResource: "kas-credential", withExtension: "json") {
            do {
                let data = try Data(contentsOf: path)
                print(data)
                let json = try JSONDecoder().decode(KasKey.self, from: data)
                return json
            } catch {
                print("error")
            }
        }
        return nil
    }
}

extension ProfileViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let user = User(
                userId: appleIDCredential.user,
                fullName: appleIDCredential.fullName,
                email: appleIDCredential.email,
                authCode: appleIDCredential.authorizationCode,
                idToken: appleIDCredential.identityToken
            )
            print(user)
        case let passwordCredential as ASPasswordCredential:
            print("aspassword", passwordCredential)
            let username = passwordCredential.user
            let password = passwordCredential.password
            print(username, password)
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error)
    }
}
