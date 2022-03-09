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
    @IBOutlet weak var confirmBtnConstraint: NSLayoutConstraint!
    @IBOutlet weak var naviItem: UINavigationItem!
    
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
        nameTextField.becomeFirstResponder()
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
    
    @IBAction func tappedApply(_ sender: UIButton) {
        if (checkNameTextFieldValidation() == false) { return }

        sender.isEnabled = false
        UserInfo.shared.changeUserName(self.nameTextField.text)
        if let image = imageView.image {
            UserInfo.shared.changeUserImage(image)
        }
        sender.isEnabled = true
        self.navigationController?.popViewController(animated: true)
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

enum ValidatorType {
    case name
    case email
}

func validateTextField(type: ValidatorType) -> Validator {
    switch type {
    case .name:
        return NameValidator()
    case .email:
        return EmailValidator()
    }
}

protocol Validator {
    func isValided(_ value: String) throws -> String
}

class ValidationError: Error {
    var msg: String
    
    init(_ msg: String) {
        self.msg = msg
    }
}

class NameValidator: Validator {
    func isValided(_ value: String) throws -> String {
        let pattern = "^[a-zA-Z0-9]*$"
        let range = NSRange(location: 0, length: value.count)
        
        do {
            let expression = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            if (expression.firstMatch(in: value, options: [], range: range) == nil) {
                throw ValidationError("영문자와 숫자만 입력해주세요")
            }
        } catch {
            throw ValidationError("영문자와 숫자만 입력해주세요")
        }
        if (value.count < 5 || value.count > 30) {
            throw ValidationError("5자리 이상, 30자리 이하로 입력해주세요")
        }
        return value
    }
}

class EmailValidator: Validator {
    func isValided(_ value: String) throws -> String {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$"
        let range = NSRange(location: 0, length: value.count)
        
        do {
            let expression = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            if (expression.firstMatch(in: value, options: [], range: range) == nil) {
                throw ValidationError("이메일 형식으로 입력해주세요")
            }
        } catch {
            throw ValidationError("이메일 형식으로 입력해주세요")
        }
        return value
    }
}
