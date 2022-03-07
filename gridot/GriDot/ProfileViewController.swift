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
    var hasUserInfo: Bool {
        if let user = Auth.auth().currentUser {
            return (user.displayName != nil)
        }
        return false
    }
    
    private let userName = BehaviorRelay<String?>(value: nil)
    private let userImage = BehaviorRelay<UIImage?>(value: nil)
    public var userNameObservable: Observable<String?>
    public var userImageObservable: Observable<UIImage?>
    
    init() {
        userNameObservable = userName.asObservable()
        userImageObservable = userImage.asObservable()
        initUserInfo()
    }
    
    func initUserInfo() {
        if let user = Auth.auth().currentUser {
            uid = user.uid
            email = user.email
            photoUrl = user.photoURL
            name = user.displayName
            userName.accept(user.displayName)
            FireStorage.shared.downloadImage(user.uid)
                .asObservable()
                .subscribe { image in
                    self.photo = image
                    self.userImage.accept(image)
                } onError: { error in
                    print(error)
                }.disposed(by: disposeBag)
        }
    }
}

class ProfileViewController: UIViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userIdLabel: UILabel!
    
    var kasKey: KasKey?
    var data: Data?
    var fireStorage: FireStorage?
    let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        fireStorage = FireStorage.shared
        if (UserInfo.shared.isSignin == false) {
            presentSigninVC()
        }
        if (UserInfo.shared.name == nil) {
            presentEditVC()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("apear")
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        if (UserInfo.shared.isSignin == false) {
            presentSigninVC()
        }
        if (UserInfo.shared.name == nil) {
            presentEditVC()
        }
    }
    
    override func viewDidLoad() {
        UserInfo.shared.userNameObservable
            .subscribe { value in
                if let value = value.element {
                    self.userIdLabel.text = value
                }
            }.disposed(by: disposeBag)
        
        UserInfo.shared.userImageObservable
            .subscribe { value in
                if let value = value.element {
                    self.profileImageView.image = value
                } else {
                    let defaultImage = UIImage(named: "person.fill")
                    self.profileImageView.image = defaultImage?.withTintColor(.darkGray)
                }
            }.disposed(by: disposeBag)
    }
    
    func presentSigninVC(){
        let signinVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.navigationController?.pushViewController(signinVC, animated: true)
    }
    
    func presentEditVC(){
        let signinVC = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
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
