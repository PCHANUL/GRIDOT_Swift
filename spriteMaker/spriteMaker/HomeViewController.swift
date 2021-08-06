//
//  HomeViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/05.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setOneSideCorner(target: backgroundView, side: "all", radius: backgroundView.bounds.width / 25)
    }
}
