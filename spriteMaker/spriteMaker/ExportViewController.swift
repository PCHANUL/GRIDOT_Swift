//
//  ExportViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/07.
//

import UIKit

class ExportViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setOneSideCorner(target: backgroundView, side: "all", radius: backgroundView.bounds.width / 25)
    }
    
    @IBAction func tappedCloseBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedBackground(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
