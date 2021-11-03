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
    @IBOutlet weak var toggleStackView: UIStackView!
    
    var mainViewController: MainViewController!
    var timeMachineVM: TimeMachineViewModel!
    var coreData: CoreData!
    var canvas: Canvas!
    
    var toggleArr: [String] = ["home", "draw", "test"]
    var selectedToggle: Int = 0
    var selectedToggleStr: String {
        return toggleArr[selectedToggle]
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        coreData = CoreData()
    }
    
    override func viewDidLoad() {
        setSideCorner(target: toggleBG, side: "all", radius: toggleBG.bounds.height / 4)
        setSideCorner(target: toggleBtnView, side: "all", radius: toggleBtnView.bounds.height / 4)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        mainViewController = segue.destination as? MainViewController
        mainViewController.superViewController = self
    }
    
    @IBAction func tappedToggleButton(_ sender: UIButton) {
        selectedToggle = sender.tag
        setTogglePosition()
    }
    
    func changeToggle(toggleName: String) {
        guard let num = toggleArr.firstIndex(of: toggleName) else { return }
        selectedToggle = num
        setTogglePosition()
    }
    
    func setTogglePosition() {
        let toggleWidth = toggleStackView.subviews[0].frame.width + toggleStackView.spacing
        toggleCenterConstraint.constant = toggleWidth * CGFloat(selectedToggle)
        var pos = CGPoint(x: 0, y: 0)
        pos.x = mainContainerView.frame.width * CGFloat(selectedToggle)
        
        self.mainViewController.mainCollectionView.setContentOffset(pos, animated: true)
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}
