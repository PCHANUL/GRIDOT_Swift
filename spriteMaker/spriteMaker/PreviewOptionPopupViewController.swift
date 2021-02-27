//
//  PreviewOptionPopupViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/02/26.
//

import UIKit

class PreviewOptionPopupViewController: UIViewController {
    var popupRectY: CGFloat!
    var popupArrorX: CGFloat!
    
    @IBOutlet var popupSuperView: UIView!
    @IBOutlet weak var popupOption: UIView!
    @IBOutlet weak var popupArror: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bottomSafeArea = UIApplication.shared.windows[0].safeAreaInsets.top
        let topAnchor = popupRectY! - bottomSafeArea
        print(topAnchor)
        
        let leadingAnchor = popupArrorX! - popupArror.frame.width / 2
        
        popupOption.topAnchor.constraint(equalTo: popupSuperView.topAnchor, constant: topAnchor).isActive = true
        popupArror.leadingAnchor.constraint(equalTo: popupOption.leadingAnchor, constant: leadingAnchor).isActive = true
    }
    
    @IBAction func handlePan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
//        case .began:
//        case .changed:
        case .ended:
            dismiss(animated: true, completion: nil)
        default: break
        }
        
    }
    
}


