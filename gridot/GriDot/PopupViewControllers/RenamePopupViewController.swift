//
//  RenamePopupViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/26.
//

import UIKit

func initRenamePopupCV(presentTarget: UIViewController, currentText: String?, callback: @escaping (_ text: String)->()) -> RenamePopupViewController? {
    guard let renamePopupVC = UIStoryboard(name: "RenamePopup", bundle: nil).instantiateViewController(identifier: "RenamePopupViewController") as? RenamePopupViewController else { return nil }

    renamePopupVC.modalPresentationStyle = .pageSheet
    renamePopupVC.currentText = currentText
    renamePopupVC.renameCallback = callback
    presentTarget.present(renamePopupVC, animated: true)
    return renamePopupVC
}

class RenamePopupViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var closeButton: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var errorLabel: UILabel!
    
    var currentText: String!
    var renameCallback: ((_ text: String)->())!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        superView.layer.cornerRadius = superView.bounds.width / 25
        superView.layer.masksToBounds = true
        closeButton.layer.borderWidth = 1
        closeButton.layer.borderColor = UIColor.init(named: "Icon")!.cgColor
        textField.text = currentText
        textField.becomeFirstResponder()
    }
    
    @IBAction func tappedRenameButton(_ sender: Any) {
        if (rename()) {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func tappedCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (rename()) {
            dismiss(animated: true, completion: nil)
        }
        return true
    }
    
    func rename() -> Bool {
        guard let callback = renameCallback else { return false }
        guard let text = textField.text else { return false }
        
        do {
            let confirmedText = try validateTextField(type: .name).isValided(text)
            callback(confirmedText)
            return true
        } catch (let error) {
            changeErrorLabelText((error as! ValidationError).msg, true)
            return false
        }
    }
    
    func changeErrorLabelText(_ text: String, _ isError: Bool) {
        errorLabel.text = text
        errorLabel.textColor = .red
    }
    
    func addSubviewToContentView(_ view: UIView) {
        if let heightConstraint = contentViewHeightConstraint,
           let widthConstraint = contentViewWidthConstraint
        {
            heightConstraint.constant = view.frame.height + 10
            widthConstraint.constant = view.frame.width
            contentView.addSubview(view)
        }
    }
}
