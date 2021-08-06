//
//  TestViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/06.
//

import UIKit

class TestViewController: UIViewController {
    var segmentedControl: UISegmentedControl!
    @IBOutlet weak var toggle: UISegmentedControl!
    @IBOutlet weak var tabBarView: UIView!
    
    override func viewDidLoad() {
        segmentedControl.selectedSegmentIndex = 0
        setOneSideCorner(target: tabBarView, side: "top", radius: tabBarView.bounds.width / 25)
    }
    
    @IBAction func tappedButton(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}
