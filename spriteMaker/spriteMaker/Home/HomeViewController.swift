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
    @IBOutlet weak var button: UIButton!
    var homeMenuPanelViewController: HomeMenuPanelViewController!
    var constraint: NSLayoutConstraint!
    var selectedMenuIndex: Int!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        homeMenuPanelViewController = segue.destination as? HomeMenuPanelViewController
        homeMenuPanelViewController?.superViewController = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setOneSideCorner(target: backgroundView, side: "all", radius: backgroundView.bounds.width / 20)
        setOneSideCorner(target: mainView, side: "all", radius: mainView.bounds.width / 20)
        setOneSideCorner(target: selectedMenubar, side: "all", radius: selectedMenubar.bounds.width / 8)
        selectedMenuIndex = 0
    }
    
    @IBAction func tappedCloseBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchMenuButton(_ sender: UIButton) {
        let menuPanelWidth = self.homeMenuPanelViewController.homeMenuPanelCV.bounds.width
        self.selectedMenuIndex = self.menubarStackView.subviews.firstIndex(of: sender)
        self.homeMenuPanelViewController.homeMenuPanelCV.setContentOffset(
            CGPoint(x: menuPanelWidth * CGFloat(self.selectedMenuIndex), y: 0), animated: true
        )
        moveMenuToggle()
    }
    
    func moveMenuToggle() {
        self.menubarConstraint.constant = self.menubarStackView.subviews[self.selectedMenuIndex].frame.minX
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}



