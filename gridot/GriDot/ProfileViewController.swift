//
//  ProfileViewController.swift
//  GriDot
//
//  Created by 박찬울 on 2022/02/24.
//

import Foundation
import UIKit

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

class UserInfo {
    static let shared: UserInfo = UserInfo()
    let disposeBag = DisposeBag()
    var uid: String?
    var name: String?
    var email: String?
    var photoUrl: URL?
    var photo: UIImage?
    var isSignin: Bool {
        return (Auth.auth().currentUser != nil)
    }
    
    init() {
        initUserInfo()
    }
    
    func initUserInfo() {
        if let user = Auth.auth().currentUser {
            uid = user.uid
            name = user.displayName
            email = user.email
            photoUrl = user.photoURL
            FireStorage.shared.downloadImage(user.uid)
                .asObservable()
                .subscribe { image in
                    self.photo = image
                } onError: { error in
                    print(error)
                }.disposed(by: disposeBag)
        }
    }
}

class ProfileViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userIdLabel: UILabel!
    
    var kasKey: KasKey?
    var data: Data?
    var fireStorage: FireStorage?
    

    override func awakeFromNib() {
        fireStorage = FireStorage.shared
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupProfileView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupProfileView()
    }
    
    func setupProfileView() {
        let userInfo = UserInfo.shared
        userInfo.initUserInfo()
        
        if (userInfo.isSignin == false) { return }
        if let name = userInfo.name {
            self.userIdLabel.text = name
        } else {
            self.userIdLabel.text = "프로필을 수정하여 아이디를 입력해주세요"
        }
        if let image = userInfo.photo {
            self.profileImageView.image = image
        }
    }
    
    func presentSigninVC(){
        let signinVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.navigationController?.pushViewController(signinVC, animated: true)
    }
    
    @IBAction func tappedLogout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
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
