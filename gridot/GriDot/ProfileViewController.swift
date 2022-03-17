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

class ProfileViewController: UIViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var thumbnailView: UIView!
    
    var kasKey: KasKey?
    var data: Data?
    var fireStorage: FireStorage?
    let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        fireStorage = FireStorage.shared
        if (UserInfo.shared.isSignin == false) {
            presentSigninVC()
        } else if (UserInfo.shared.name == nil) {
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
        UserInfo.shared.setUserInfo()
        
        guard let kasKey = Bundle.main.kasApiKey else { return }
        let header = RequestHeaders(Content_Type: "application/json", x_chain_id: "8721", Authorization: kasKey.authorization)
        try? request("https://wallet-api.klaytnapi.com/v2/account", .Get, header) { (isDone, data) -> Void in
            print(isDone, data)
        }
    }
    
    override func viewDidLoad() {
        setSideCorner(target: thumbnailView, side: "all", radius: thumbnailView.frame.width / 2)
        
        
        FirebaseRequest.shared.onCall(.addMessage, { result, error in
            if (error != nil) {
                print(error)
            } else {
                print(result)
            }
        })
        
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
            UserInfo.shared.initUserInfo()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

class ProfileMenuViewController: UIViewController {



}

extension ProfileMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "ProfileMenuOptionTableViewCell") else { return UITableViewCell() }
        
        return cell
    }
    
    
}

class ProfileMenuOptionTableViewCell: UITableViewCell {
    
}
