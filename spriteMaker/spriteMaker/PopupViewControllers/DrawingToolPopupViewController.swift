//
//  DrawingToolPopupViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/24.
//

import UIKit

class DrawingToolPopupViewController: UIViewController {
    @IBOutlet weak var drawingToolList: UIView!
    @IBOutlet weak var popupView: UIView!
    
    var popupPositionY: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawingToolList.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 0).isActive = true
        
    }
    
    @IBAction func tappedBG(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    

   

}
