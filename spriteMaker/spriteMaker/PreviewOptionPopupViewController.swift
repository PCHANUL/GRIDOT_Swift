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
        let leadingAnchor = popupArrorX! - popupArror.frame.width / 2
        
        popupOption.topAnchor.constraint(equalTo: popupSuperView.topAnchor, constant: topAnchor).isActive = true
        popupArror.leadingAnchor.constraint(equalTo: popupOption.leadingAnchor, constant: leadingAnchor).isActive = true
    }
    
    @IBAction func handlePan(_ gesture: UIPanGestureRecognizer) {
        let center = popupSuperView.frame.height / 2
        
        switch gesture.state {
        case .changed:
            let movement = popupSuperView.center.y + gesture.translation(in: popupOption).y
            if movement > center {
                popupSuperView.center.y = popupSuperView.center.y + gesture.translation(in: popupOption).y
                gesture.setTranslation(CGPoint.zero, in: popupSuperView)
            }
        case .ended:
            if popupSuperView.frame.minY > popupSuperView.frame.height / 10 {
                dismiss(animated: true, completion: nil)
            } else {
                popupSuperView.center.y = center
            }
        default: break
        }
    }
}



// [] 팝업창에 들어가는 옵션들
// - [] 셀 제거
// - [] 셀 배경변경
// - [] 셀 정보

// 만약에 셀 분류가 되면 animatedPreview를 클릭하여 특정 분류만 볼 수 있어야 한다.
// [] 특정 분류만 보기
// [] 일시정지
//


