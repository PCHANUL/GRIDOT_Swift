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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = userInfo.curUserImage { imageView.image = image }
        nameTextField.text = userInfo.curUserName
        
        initTextFieldListener()
        nameTextField.becomeFirstResponder()
        setSideCorner(target: nameTextField, side: "all", radius: 3)
        setSideCorner(target: imageView, side: "all", radius: imageView.frame.width / 2)
        setButtonLoadingState(isLoading: false)
        
        NotificationCenter.default
            .rx.notification(UIResponder.keyboardDidShowNotification)
            .subscribe(onNext: showKeyboardTextView)
            .disposed(by: disposeBag)

        NotificationCenter.default
            .rx.notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: hideKeyboardTextView)
            .disposed(by: disposeBag)
    }
    
    private func showKeyboardTextView(noti: Notification) {
        guard let userInfo = noti.userInfo else { return }
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let heightConstant = keyboardFrame.height
        applyBottomAnchorConstraint.constant = heightConstant
        applyButtonFixed.isHidden = true
    }
    
    private func hideKeyboardTextView(noti: Notification) {
        applyBottomAnchorConstraint.constant = -60
        applyButtonFixed.isHidden = false
    }
    
    func initTextFieldListener() {
        self.nameTextField
            .rx.controlEvent([.editingDidEnd, .editingDidEndOnExit])
            .asObservable()
            .subscribe ({ _ in
                let _ = self.checkNameTextFieldValidation()
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
            applyButtonFixed.isEnabled = false
            applyButton.setTitle("", for: .normal)
            applyButtonFixed.setTitle("", for: .normal)
        } else {
            loadingIndicator.stopAnimating()
            loadingIndicatorFixed.stopAnimating()
            applyButton.isEnabled = true
            applyButtonFixed.isEnabled = true
            applyButton.setTitle("확인", for: .normal)
            applyButtonFixed.setTitle("확인", for: .normal)
        }
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.imageView.image = editedImage
        }
        dismiss(animated: true, completion: nil)
    }
}
