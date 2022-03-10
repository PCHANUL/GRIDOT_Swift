//
//  ColorPaletteRenamePopupViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/26.
//

import UIKit

class RenamePopupViewController: UIViewController {
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var closeButton: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    
    weak var preView: ColorPaletteCell!
    var currentPalette: Palette!
    var currentText: String!
    
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
        preView.renamePalette(text: textField.text!)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension RenamePopupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        preView.renamePalette(text: textField.text!)
        dismiss(animated: true, completion: nil)
        return true
    }
}
