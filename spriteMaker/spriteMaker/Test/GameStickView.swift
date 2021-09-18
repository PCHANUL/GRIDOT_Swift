//
//  GameStickView.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/09/12.
//

import UIKit

class GameStickView: UIView {
    weak var testViewController: GameBoyPanelCollectionViewCell!
    var selectedIndex: Int = -1
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let pos = touches.first?.location(in: self) else { return }
        guard let key = calcTouchPosition(pos) else { return }
        
        if (testViewController.gameCommands == nil) {
            testViewController.initGameCommandsArr()
        }
        
        if (isTouchedCenterOfGameStick(key, pos)) {
            initGameStickViewImage()
        } else {
            changeGameStickViewImage(key)
        }
        
        let view = testViewController.gameStickView.subviews[selectedIndex] as! UIImageView
        print((view.subviews.first as! UILabel).text)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let pos = touches.first?.location(in: self) else { return }
        guard let key = calcTouchPosition(pos) else { return }
        
        if (isTouchedCenterOfGameStick(key, pos)) {
            initGameStickViewImage()
        } else {
            changeGameStickViewImage(key)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        initGameStickViewImage()
        selectedIndex = -1
    }
    
    func isTouchedCenterOfGameStick(_ key: Int, _ pos: CGPoint) -> Bool {
        let center = self.frame.width / 7
        
        switch key {
        case 0, 1:
            if (pos.y > (self.frame.width / 2) - center && pos.y < (self.frame.width / 2) + center) {
                return true
            }
        default:
            if (pos.x > (self.frame.width / 2) - center && pos.x < (self.frame.width / 2) + center) {
                return true
            }
        }
        return false
    }
    
    func initGameStickViewImage() {
        if (selectedIndex == -1) { return }
        let view = testViewController.gameStickView.subviews[selectedIndex] as! UIImageView
        view.image = UIImage(systemName: "circle")
    }
    
    func changeGameStickViewImage(_ keyIndex: Int) {
        if (selectedIndex == keyIndex) { return }
        initGameStickViewImage()
        selectedIndex = keyIndex
        let view = testViewController.gameStickView.subviews[selectedIndex] as! UIImageView
        view.image = UIImage(systemName: "circle.fill")
    }
    
    func calcTouchPosition(_ location: CGPoint) -> Int? {
        let calc_a = location.x > location.y
        let calc_b = self.frame.width - location.x > location.y

        if (calc_a && calc_b) { return 0 }
        else if (!calc_a && !calc_b) { return 1 }
        else if (!calc_a && calc_b) { return 2 }
        else if (calc_a && !calc_b) { return 3 }
        return nil
    }
}
