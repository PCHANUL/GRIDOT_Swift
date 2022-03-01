//
//  ProfileViewController.swift
//  GriDot
//
//  Created by 박찬울 on 2022/02/24.
//

import Foundation
import UIKit
import AuthenticationServices
import RxSwift
import RxCocoa
import Firebase


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

class ProfileViewController: UIViewController {
    @IBOutlet weak var loginView: UIView!
    var kasKey: KasKey?
    var data: Data?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        if let userId = UserDefaults.standard.value(forKey: "userId") as? String {
            appleIDProvider.getCredentialState(forUserID: userId) { (credentialState, error) in
                switch credentialState {
                case .authorized:
                    DispatchQueue.main.async {
                        self.setupProfileView()
                    }
                case .revoked, .notFound, .transferred:
                    DispatchQueue.main.async {
                        self.setupProviderLoginView()
                    }
                @unknown default:
                    fatalError()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        if (data != nil) {
//            let json = try! JSONDecoder().decode(AccountList.self, from: self.data!)
//            print(json)
//        }
    }
    
    func setupProfileView() {
        
    }
    
    func setupProviderLoginView() {
        let appleButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
        appleButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        loginView.addSubview(appleButton)
        
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
        guard let kasKey = Bundle.main.kasApiKey else { return }
        let headers = [
            "Content-Type": "application/json",
            "x-chain-id": "8721",
            "Authorization": kasKey.authorization
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
            print(response as Any)
            if (error != nil) {
                print(error as Any)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse as Any)
            }
        })
        dataTask.resume()
    }
}

extension ProfileViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        addNewUser(authorization: authorization)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error)
    }
    
    func addNewUser(authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let collection = Firestore.firestore().collection("users")
            let user = setUser(appleIDCredential)
            collection.addDocument(data: user.dictionary)
            UserDefaults.standard.setValue(user.userId, forKey: "userId")
        case let passwordCredential as ASPasswordCredential:
            let username = passwordCredential.user
            let password = passwordCredential.password
            print(username, password)
        default:
            break
        }
    }
    
    func setUser(_ appleIDCredential: ASAuthorizationAppleIDCredential) -> User {
        var user = User(userId: appleIDCredential.user)
        if let email = appleIDCredential.email {
            user.email = email
        }
        if let fullName = appleIDCredential.fullName,
           let givenName = fullName.givenName,
           let familyName = fullName.familyName
        {
            user.fullName = "\(givenName) \(familyName)"
        }
        return user
    }
}

struct User {
    var userId: String = "none"
    var email: String = "none"
    var fullName: String = "unnamed"
    
    var dictionary: [String: Any] {
      return [
        "userId": userId,
        "email": email,
        "fullName": fullName
      ]
    }
}
