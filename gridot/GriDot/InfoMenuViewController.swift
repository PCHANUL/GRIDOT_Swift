//
//  InfoMenuViewController.swift
//  GriDot
//
//  Created by 박찬울 on 2022/04/04.
//

import UIKit
import RxSwift

class InfoMenuViewController: UIViewController {
    @IBOutlet weak var MenuTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

extension InfoMenuViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTabelViewCell", for: indexPath) as? ProfileTabelViewCell else { return UITableViewCell() }
        setSideCorner(target: cell, side: "all", radius: 10)
        cell.superViewController = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat
        
        height = 100
        return height
    }
}

class ProfileTabelViewCell: UITableViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    var isInited: Bool = false
    let disposeBag = DisposeBag()
    var userInfo: UserInfo = UserInfo.shared
    var superViewController: UIViewController!

    override func layoutSubviews() {
        if (isInited == false) {
            if (userInfo.isSignin) {
                if let image = userInfo.curUserImage { thumbnail.image = image }
                nameLabel.text = userInfo.curUserName
            } else {
                nameLabel.text = "로그인을 해주세요"
            }
            isInited = true
        }
    }
    
    @IBAction func tappedButton(_ sender: Any) {
        if (userInfo.isSignin) {
            guard let editProfileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "EditProfileViewController") as? EditProfileViewController else { return }
            superViewController.present(editProfileVC, animated: true, completion: nil)
        } else {
            guard let signInVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SignInViewController") as? SignInViewController else { return }
            superViewController.present(signInVC, animated: true, completion: nil)
        }
    }
}
