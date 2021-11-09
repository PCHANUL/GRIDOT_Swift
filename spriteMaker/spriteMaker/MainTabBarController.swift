//
//  MainTabBarController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/11/05.
//

import UIKit

class MainTabBarController: UITabBarController {
    var coreData = CoreData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        switch viewController.title {
//        case "gallery":
//            return
//        case "drawing":
//            print("tabbar drawing")
//        case "testing":
//            print("tabbar testing")
//        default:
//            return
//        }
    }
}
