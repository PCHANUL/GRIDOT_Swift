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
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameErrorLabel: UILabel!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        nameTextField.becomeFirstResponder()
        initTextField()
        setSideCorner(target: nameTextField, side: "all", radius: 3)
        setSideCorner(target: emailTextField, side: "all", radius: 3)
        nameTextField.layer.borderColor = UIColor.red.cgColor
        emailTextField.layer.borderColor = UIColor.red.cgColor
        
        
        guard let user = Auth.auth().currentUser else { return }
        FireStorage.shared.downloadImage("\(user.uid)")
            .subscribe({ image in
                self.imageView.image = image.element
            }).disposed(by: disposeBag)
    }
    
    func initTextField() {
        self.nameTextField.rx.controlEvent([.editingDidEnd, .editingDidEndOnExit])
            .asObservable()
            .subscribe({ [self] newValue in
                    do {
                        let _ = try validateTextField(type: .name).isValided(nameTextField.text!)
                    } catch (let error) {
                        nameErrorLabel.text = (error as! ValidationError).msg
                        nameTextField.layer.borderWidth = 1
                        nameViewHeightConstraint.constant = 55
                        nameErrorLabel.isHidden = false
                    }
            }).disposed(by: disposeBag)
        
        self.nameTextField.rx.controlEvent(.editingChanged)
            .asObservable()
            .subscribe ({ [self] newValue in
                if (nameTextField.layer.borderWidth == 1) {
                    nameTextField.layer.borderWidth = 0
                    nameViewHeightConstraint.constant = 40
                    nameErrorLabel.isHidden = true
                }
            }).disposed(by: disposeBag)
        
        self.emailTextField.rx.controlEvent([.editingDidEnd, .editingDidEndOnExit])
            .asObservable()
            .subscribe ({ [self] newValue in
                if (emailTextField.text != "") {
                    do {
                        let _ = try validateTextField(type: .email).isValided(emailTextField.text!)
                    } catch (let error) {
                        emailErrorLabel.text = (error as! ValidationError).msg
                        emailTextField.layer.borderWidth = 1
                        emailErrorLabel.isHidden = false
                    }
                }
            }).disposed(by: disposeBag)
        
        self.emailTextField.rx.controlEvent(.editingChanged)
            .asObservable()
            .subscribe({ [self] value in
                if (emailTextField.layer.borderWidth == 1) {
                    emailTextField.layer.borderWidth = 0
                    emailErrorLabel.isHidden = true
                }
            }).disposed(by: disposeBag)
    }
    
    
    @IBAction func tappedApply(_ sender: Any) {
        guard let user = Auth.auth().currentUser else { return }
        let userId = user.uid
        let changeReq = user.createProfileChangeRequest()
        
        FireStorage.shared.uploadNewImage(imageView.image!, userId)
            .subscribe { url in
                print(url)
                changeReq.photoURL = url.element }
            .disposed(by: disposeBag)

        
//        dismiss(animated: true, completion: nil)
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
        
        if (value.count < 5) { throw ValidationError("5자리 이상으로 입력해주세요") }
        if (value.count > 30) { throw ValidationError("30자리 이하로 입력해주세요") }
        
        do {
            let expression = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            if (expression.firstMatch(in: value, options: [], range: range) == nil) {
                throw ValidationError("영문자와 숫자만 입력해주세요")
            }
        } catch {
            throw ValidationError("영문자와 숫자만 입력해주세요")
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
