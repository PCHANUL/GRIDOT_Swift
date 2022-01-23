//
//  MainTabBarController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/11/05.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let drawingVC = tabBarController.viewControllers?[1] else { return false }
        return (viewController != drawingVC || CoreData.shared.numsOfAsset != 0)
    }
}
