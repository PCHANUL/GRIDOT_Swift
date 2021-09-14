//
//  TestViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/06.
//

import UIKit

class TestViewController: UIViewController {
    @IBOutlet weak var toggle: UISegmentedControl!
    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var panelView: UIView!
    @IBOutlet weak var selectedAnchorLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var gameBoyBtn: UIButton!
    var prevSelectedBtn: UIButton!
    var segmentedControl: UISegmentedControl!
    var testPanelViewController: TestPanelViewController!
    
    var items = ["Game", "Message", "AppleWatch"]
    
    override func viewDidLoad() {
        prevSelectedBtn = gameBoyBtn
        segmentedControl.selectedSegmentIndex = 0
        setSideCorner(target: tabBarView, side: "top", radius: tabBarView.bounds.width / 25)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "panel") {
            testPanelViewController = segue.destination as? TestPanelViewController
            testPanelViewController.superView = self
        }
    }
    
    @IBAction func tappedButton(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func tappedSelectPanel(_ sender: UIButton) {
        prevSelectedBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        prevSelectedBtn = sender
        
        selectedAnchorLeadingConstraint.constant = sender.frame.minX
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        
        let pos = CGPoint(x: 0, y: Int(panelView.frame.height) * (sender.tag - 1))
        testPanelViewController.collectionView.setContentOffset(pos, animated: true)
    }
    
    
}

class TestPanelViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var superView: TestViewController!
    
}

extension TestPanelViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameBoyPanelCollectionViewCell", for: indexPath)
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameBoyPanelCollectionViewCell", for: indexPath)
            return cell
        }
    }
}

extension TestPanelViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewFrame = superView.panelView.frame
        return CGSize(width: viewFrame.width, height: viewFrame.height)
    }
}

class GameBoyPanelCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var gameStickView: GameStickView!
    @IBOutlet weak var gameStickImageView: UIImageView!
    @IBOutlet weak var gameButtonView: GameButtonView!
    @IBOutlet weak var gameButton_A: UIImageView!
    @IBOutlet weak var gameButton_B: UIImageView!
    @IBOutlet weak var gameButton_C: UIImageView!
    
    let gameCommands = ["up", "down", "left", "right"]
    
    override func layoutSubviews() {
        gameStickView.testViewController = self
        gameButtonView.testViewController = self
    }
    
}


