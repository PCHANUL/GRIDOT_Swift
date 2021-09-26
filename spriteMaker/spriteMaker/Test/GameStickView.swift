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
    var selectedIndex: Int = -1
    
    var moveInterval: Timer?
    
    func startMoveInterval() {
        if (!(moveInterval?.isValid ?? false)) {
            moveInterval = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true)
            { (Timer) in
                if (self.selectedIndex != -1) {
                    print("move", self.selectedIndex)
                    self.moveCharacter()
                }
            }
        }
    }
    
    func moveCharacter() {
        switch selectedIndex {
        case 0:
            screen.jumpAction()
//        case 1:
//            screen.posY += 20
        case 2:
            screen.posX -= 20
        case 3:
            screen.posX += 20
        default:
            return
        }
        screen.setNeedsDisplay()
    }
}

// touch methods
extension GameStickView {
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
            let view = testViewController.gameStickView.subviews[selectedIndex] as! UIImageView
            print((view.subviews.first as! UILabel).text)
            guard var actionName = (view.subviews.first as! UILabel).text else { return }
            if (actionName == "") { actionName = "Default" }
            screen.inputAction = actionName
            moveCharacter()
            startMoveInterval()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let pos = touches.first?.location(in: self) else { return }
        guard let key = calcTouchPosition(pos) else { return }
        
        if (isTouchedCenterOfGameStick(key, pos)) {
            initGameStickViewImage()
        } else {
            changeGameStickViewImage(key)
            
            let view = testViewController.gameStickView.subviews[selectedIndex] as! UIImageView
            guard var actionName = (view.subviews.first as! UILabel).text else { return }
            if (actionName == "") { actionName = "Default" }
            screen.inputAction = actionName
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        initGameStickViewImage()
        moveInterval?.invalidate()
        selectedIndex = -1
        screen.inputAction = "Default"
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
