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
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var gameStickView: GameStickView!
    @IBOutlet weak var gameStickImageView: UIImageView!
    @IBOutlet weak var gameButtonView: GameButtonView!
    @IBOutlet weak var gameButton_A: UIImageView!
    @IBOutlet weak var gameButton_B: UIImageView!
    @IBOutlet weak var gameButton_C: UIImageView!
    
    var items = ["Game", "Message", "AppleWatch"]
    let gameCommands = ["up", "down", "left", "right"]
    
    override func viewDidLoad() {
        segmentedControl.selectedSegmentIndex = 0
        setSideCorner(target: tabBarView, side: "top", radius: tabBarView.bounds.width / 25)
        
        gameStickView.testViewController = self
        gameButtonView.testViewController = self
    }
    
    @IBAction func tappedButton(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}
