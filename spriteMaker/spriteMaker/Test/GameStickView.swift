//
//  GameStickView.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/09/12.
//

import UIKit

class GameStickView: UIView {
    weak var testViewController: TestingCollectionViewCell!
    var screen: Screen!
    
}

// touch methods
extension GameStickView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (testViewController.gameCommands == nil) {
            testViewController.initGameCommandsArr()
        }
        changeGameStick(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        changeGameStick(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        initGameStickViewImage()
        screen.selectedStick = -1
    }
    
    func changeGameStick(_ touches: Set<UITouch>) {
        guard let pos = touches.first?.location(in: self) else { return }
        guard let key = calcTouchPosition(pos) else { return }
        guard let view = testViewController.gameStickView.subviews[key] as? UIImageView else { return }
        guard let label = view.subviews.first as? UILabel else { return }
        guard let actionName = label.text else { return }
        
        if (isTouchedCenterOfGameStick(key, pos)) {
            initGameStickViewImage()
        } else {
            changeGameStickViewImage(key)
            screen.inputAction = actionName == "" ? "Default" : actionName
            screen.moveCharacter()
        }
    }
    
    func isTouchedCenterOfGameStick(_ key: Int, _ pos: CGPoint) -> Bool {
        let center = self.frame.width / 7
        
        switch key {
        case 0, 1:
            if (pos.y > (self.frame.width / 2) - center && pos.y < (self.frame.width / 2) + center)
            { return true }
        default:
            if (pos.x > (self.frame.width / 2) - center && pos.x < (self.frame.width / 2) + center)
            { return true }
        }
        return false
    }
    
    func initGameStickViewImage() {
        if (screen.selectedStick == -1) { return }
        guard let view = testViewController.gameStickView.subviews[screen.selectedStick] as? UIImageView else { return }
        view.image = UIImage(systemName: "circle")
    }
    
    func changeGameStickViewImage(_ keyIndex: Int) {
        if (screen.selectedStick == keyIndex) { return }
        initGameStickViewImage()
        screen.selectedStick = keyIndex
        guard let view = testViewController.gameStickView.subviews[screen.selectedStick] as? UIImageView else { return }
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
