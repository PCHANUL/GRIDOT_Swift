//
//  UserInfo.swift
//  GriDot
//
//  Created by 박찬울 on 2022/03/08.
//

import RxSwift
import RxCocoa
import Firebase

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
        setUserInfo()
    }
    
    func initUserInfo() {
        uid = nil
        name = nil
        email = nil
        photoUrl = nil
        photo = nil
        userName.accept(nil)
        userImage.accept(nil)
    }
    
    var curUserName: String? {
        return userName.value
    }
    
    var curUserImage: UIImage? {
        return userImage.value
    }
    
    func changeUserName(_ name: String?) {
        guard let user = Auth.auth().currentUser else { return }
        let changeReq = user.createProfileChangeRequest()
        
        changeReq.displayName = name
        changeReq.commitChanges(completion: nil)
        userName.accept(name)
    }
    
    func changeUserImage(_ image: UIImage, _ completion: @escaping ()->()) {
        guard let user = Auth.auth().currentUser else { return }
        let changeReq = user.createProfileChangeRequest()
        
        FireStorage.shared
            .uploadNewImage(image, user.uid)
            .subscribe { url in
                changeReq.photoURL = url
            } onCompleted: {
                changeReq.commitChanges {_ in
                    self.userImage.accept(image)
                    completion()
                }
            }.disposed(by: disposeBag)
    }
    
    func setUserInfo() {
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
