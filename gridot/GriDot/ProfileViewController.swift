//
//  ProfileViewController.swift
//  GriDot
//
//  Created by 박찬울 on 2022/02/24.
//

import UIKit
import RxSwift
import RxCocoa

class ProfileViewController: UIViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var thumbnailView: UIView!

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
    
    override func viewDidLoad() {
        setSideCorner(target: thumbnailView, side: "all", radius: thumbnailView.frame.width / 2)
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        if (UserInfo.shared.isSignin == false) {
            presentSigninVC()
        }
        UserInfo.shared.setUserInfo()
    }
    
    func presentEditVC(){
        let signinVC = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        self.navigationController?.pushViewController(signinVC, animated: true)
    }
    
    func presentSigninVC(){
        let signinVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.navigationController?.pushViewController(signinVC, animated: true)
    }
}
