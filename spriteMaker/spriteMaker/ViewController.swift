//
//  ViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/02/19.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var viewController: UIView!
    @IBOutlet weak var mainContainerView: UIView!
    
    @IBOutlet weak var bottomNav: UIView!
    @IBOutlet weak var toggleBG: UIView!
    @IBOutlet weak var toggleBtnView: UIView!
    @IBOutlet weak var toggleCenterConstraint: NSLayoutConstraint!
    
    var mainViewController: MainViewController!
    var timeMachineVM: TimeMachineViewModel!
    var coreData: CoreData!
    var canvas: Canvas!
    
    var selectedToggle: Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        coreData = CoreData()
    }
    
    override func viewDidLoad() {
        setSideCorner(target: bottomNav, side: "top", radius: bottomNav.bounds.width / 25)
        setSideCorner(target: toggleBG, side: "all", radius: toggleBG.bounds.height / 4)
        setSideCorner(target: toggleBtnView, side: "all", radius: toggleBtnView.bounds.height / 4)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "main":
            print("main")
            mainViewController = segue.destination as? MainViewController
            mainViewController.superViewController = self
        case "home":
            print("home")
            let destinationVC = segue.destination as? HomeViewController
            destinationVC?.superViewController = self
        default:
            return
        }
    }
    
    @IBAction func tappedToggleButton(_ sender: UIButton) {
        selectedToggle = sender.tag
        setTogglePosition()
    }
    
    @IBAction func toggleValueChanged(_ sender: UIButton) {
        let pos: CGPoint
        
        if (selectedToggle == 0) {
            pos = CGPoint(x: 0, y: 0)
        } else {
            pos = CGPoint(x: mainContainerView.frame.width, y: 0)
            self.mainViewController.setLabelView(self)
        }
        self.mainViewController.mainCollectionView.setContentOffset(pos, animated: true)
    }
    
    func setTogglePosition() {
        toggleCenterConstraint.constant = (toggleBtnView.frame.width + 5) * CGFloat(selectedToggle)
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}
