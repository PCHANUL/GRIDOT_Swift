//
//  EditProfileViewController.swift
//  GriDot
//
//  Created by 박찬울 on 2022/03/03.
//

import UIKit
import RxSwift
import FirebaseAuth

class EditProfileViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingIndicatorFixed: UIActivityIndicatorView!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var applyButtonFixed: UIButton!
    @IBOutlet weak var applyBottomAnchorConstraint: NSLayoutConstraint!
    
    
    let disposeBag = DisposeBag()
    var userInfo: UserInfo = UserInfo.shared
    var isImageChanged: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (UserInfo.shared.hasUserInfo == false) {
            naviItem.setLeftBarButton(
                UIBarButtonItem.init(title: nil, image: nil, primaryAction: nil, menu: nil),
                animated: true)
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
        
        initTextFieldListener()
        if let image = userInfo.photo { imageView.image = image }
        nameTextField.text = userInfo.name
        setSideCorner(target: nameTextField, side: "all", radius: 3)
        setSideCorner(target: imageView, side: "all", radius: imageView.frame.width / 2)
        nameTextField.becomeFirstResponder()
        setButtonLoadingState(isLoading: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboardTextView), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboardTextView), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func showKeyboardTextView(noti: Notification) {
        guard let userInfo = noti.userInfo else { return }
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        if (noti.name == UIResponder.keyboardDidShowNotification) {
            let heightConstant = keyboardFrame.height
            applyBottomAnchorConstraint.constant = heightConstant
            applyButtonFixed.isHidden = true
        } else {
            applyBottomAnchorConstraint.constant = -60
            applyButtonFixed.isHidden = false
        }
    }
    
    func initTextFieldListener() {
        self.nameTextField.rx.controlEvent([.editingDidEnd, .editingDidEndOnExit])
            .asObservable()
            .subscribe ({ [self] newValue in
                let _ = checkNameTextFieldValidation()
            }).disposed(by: disposeBag)
    }
    
    func checkNameTextFieldValidation() -> Bool {
        do {
            guard let text = nameTextField.text else { return false }
            let _ = try validateTextField(type: .name).isValided(text)
            nameTextField.layer.borderWidth = 0
            nameErrorLabel.textColor = .darkGray
            nameErrorLabel.text = "영문과 숫자로 아이디를 입력해주세요"
        } catch (let error) {
            nameErrorLabel.text = (error as! ValidationError).msg
            nameTextField.layer.borderColor = UIColor.red.cgColor
            nameTextField.layer.borderWidth = 1
            nameErrorLabel.textColor = .red
            return false
        }
        return true
    }
    
    func checkImageViewValidation() -> Bool {
        if (imageView.image != nil) { return true }
        
        let alert = UIAlertController(
            title: "Your Title",
            message: "Your Message",
            preferredStyle: UIAlertController.Style.alert
        )
        present(alert, animated: true, completion: nil)
        return false
    }
    
    @IBAction func tappedChangeProfileImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        if UIDevice.current.userInterfaceIdiom == .pad {
            imagePicker.allowsEditing = true
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            imagePicker.allowsEditing = true
        }
        present(imagePicker, animated: true)
    }
    
    @IBAction func tappedApply(_ sender: UIButton) {
        if (checkNameTextFieldValidation() == false) { return }
        if (checkImageViewValidation() == false) { return }
        
        setButtonLoadingState(isLoading: true)
        UserInfo.shared.changeUserName(nameTextField.text)
        UserInfo.shared.changeUserImage(imageView.image!) {
            self.dismiss(animated: true)
            self.setButtonLoadingState(isLoading: false)
        }
    }
    
    func setButtonLoadingState(isLoading: Bool) {
        if (isLoading) {
            loadingIndicator.startAnimating()
            loadingIndicatorFixed.startAnimating()
            applyButton.isEnabled = false
            applyButton.tintColor = .lightGray
            applyButton.setTitle("", for: .normal)
            applyButtonFixed.isEnabled = false
            applyButtonFixed.tintColor = .lightGray
            applyButtonFixed.setTitle("", for: .normal)
        } else {
            loadingIndicator.stopAnimating()
            loadingIndicatorFixed.stopAnimating()
            applyButton.isEnabled = true
            applyButton.tintColor = .systemBlue
            applyButton.setTitle("확인", for: .normal)
            applyButtonFixed.isEnabled = true
            applyButtonFixed.tintColor = .systemBlue
            applyButtonFixed.setTitle("확인", for: .normal)
        }
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.imageView.image = editedImage
            self.isImageChanged = true
        }
        dismiss(animated: true, completion: nil)
    }
}
