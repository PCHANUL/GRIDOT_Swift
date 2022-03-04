//
//  EditProfileViewController.swift
//  GriDot
//
//  Created by 박찬울 on 2022/03/03.
//

import UIKit
import RxSwift

class EditProfileViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        nameTextField.becomeFirstResponder()
        initTextField()
    }
    
    func initTextField() {
        self.nameTextField.rx.controlEvent([.editingDidEnd, .editingDidEndOnExit])
            .asObservable()
            .subscribe ({ [self] newValue in
                if (nameTextField.text != "") {
                    if (validateTextField(nameTextField.text, type: .name) != 0) {
                        nameTextField.layer.borderColor = UIColor.red.cgColor
                        nameTextField.layer.borderWidth = 1
                        nameErrorLabel.isHidden = false
                    } else {
                        nameTextField.layer.borderWidth = 0
                        nameErrorLabel.isHidden = true
                    }
                }
            }).disposed(by: disposeBag)
        
        self.emailTextField.rx.controlEvent([.editingDidEnd, .editingDidEndOnExit])
            .asObservable()
            .subscribe ({ [self] newValue in
                if (emailTextField.text != "") {
                    if (validateTextField(emailTextField.text, type: .email) != 0) {
                        emailTextField.layer.borderColor = UIColor.red.cgColor
                        emailTextField.layer.borderWidth = 1
                        emailErrorLabel.isHidden = false
                    } else {
                        emailTextField.layer.borderWidth = 0
                        emailErrorLabel.isHidden = true
                    }
                }
            }).disposed(by: disposeBag)

    }
    
    
    @IBAction func tappedApply(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
        }
        dismiss(animated: true, completion: nil)
    }
}

enum ValidatorType {
    case name
    case email
}

func validateTextField(_ value: String?, type: ValidatorType) -> Int {
    switch type {
    case .name:
        return isNameValid(value)
    case .email:
        return isEmailValid(value)
    }
}

func isNameValid(_ value: String?) -> Int {
    if let text = value {
        do {
            if try NSRegularExpression(
                pattern: "[A-Z0-9a-z]",
                options: .caseInsensitive
            ).firstMatch(
                in: text,
                options: [],
                range: NSRange(location: 0, length: text.count)
            ) == nil {
                return 1
            }
        } catch {
            return 2
        }
    }
    return 0
}

func isEmailValid(_ value: String?) -> Int {
    if let text = value {
        do {
            if try NSRegularExpression(
                pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$",
                options: .caseInsensitive
            ).firstMatch(
                in: text,
                options: [],
                range: NSRange(location: 0, length: text.count)
            ) == nil {
                return 1
            }
        } catch {
            return 2
        }
    }
    return 0
}

