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
    var galleryVC: GalleryViewController!
    
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
        cell.infoMenuVC = self
        cell.galleryVC = galleryVC
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
    var infoMenuVC: InfoMenuViewController!
    var galleryVC: GalleryViewController!

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
            let editProfileVC = galleryVC.storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
            infoMenuVC.dismiss(animated: true)
            galleryVC.navigationController?.pushViewController(editProfileVC, animated: true)
        } else {
            guard let signInVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SignInViewController") as? SignInViewController else { return }
            infoMenuVC.present(signInVC, animated: true, completion: nil)
        }
    }
}
