//
//  MainTabBarController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/11/05.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    @IBOutlet weak var tabbar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        let _ = UserInfo.shared
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let drawingVC = tabBarController.viewControllers?[1] else { return false }
        return (viewController != drawingVC || CoreData.shared.numsOfAsset != 0)
    }
    
    @objc func detectOrientation() {
        if (UIDevice.current.orientation == .landscapeLeft) {
            let subviews = tabbar.subviews
            let idx = subviews.count == 2 ? 0 : 1
            subviews[idx].subviews[0].transform = CGAffineTransform(rotationAngle: .pi / 2)
            subviews[idx + 1].subviews[0].transform = CGAffineTransform(rotationAngle: .pi / 2)
        }
        
        if (UIDevice.current.orientation == .landscapeRight) {
            let subviews = tabbar.subviews
            let idx = subviews.count == 2 ? 0 : 1
            subviews[idx].subviews[0].transform = CGAffineTransform(rotationAngle: -(.pi / 2))
            subviews[idx + 1].subviews[0].transform = CGAffineTransform(rotationAngle: -(.pi / 2))
        }
        
        if (UIDevice.current.orientation == .portrait) || (UIDevice.current.orientation == .portraitUpsideDown){
            let subviews = tabbar.subviews
            let idx = subviews.count == 2 ? 0 : 1
            subviews[idx].subviews[0].transform = CGAffineTransform(rotationAngle: 0)
            subviews[idx + 1].subviews[0].transform = CGAffineTransform(rotationAngle: 0)
        }
    }
}
