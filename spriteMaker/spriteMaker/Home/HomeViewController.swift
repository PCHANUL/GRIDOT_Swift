//
//  HomeViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/05.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var menubarStackView: UIStackView!
    @IBOutlet weak var selectedMenubar: UIView!
    @IBOutlet weak var menubarConstraint: NSLayoutConstraint!
    var constraint: NSLayoutConstraint!
    
    @IBOutlet weak var button: UIButton!
    @IBAction func tappedCloseBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setOneSideCorner(target: backgroundView, side: "all", radius: backgroundView.bounds.width / 20)
        setOneSideCorner(target: mainView, side: "all", radius: mainView.bounds.width / 20)
        setOneSideCorner(target: selectedMenubar, side: "all", radius: selectedMenubar.bounds.width / 8)
    }
    
    @IBAction func switchMenuButton(_ sender: UIButton) {
        self.menubarConstraint.constant = sender.frame.minX
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
}



