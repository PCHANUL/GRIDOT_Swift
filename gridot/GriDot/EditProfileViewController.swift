//
//  EditProfileViewController.swift
//  GriDot
//
//  Created by 박찬울 on 2022/03/03.
//

import UIKit

class EditProfileViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
    }
    
    
    @IBAction func tappedApply(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}
