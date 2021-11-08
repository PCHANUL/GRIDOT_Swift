//
//  GameButtonView.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/09/12.
//

import UIKit

class GameButtonView: UIView {
    weak var testViewController: TestingViewController!
    var screen: ScreenView!
    
    var selectedIndex: Int = 0
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (testViewController.gameCommands == nil) {
            testViewController.initGameCommandsArr()
        }
        
        guard let pos = touches.first?.location(in: self) else { return }
        guard let key = getTouchedIndex(pos) else { return }
        guard let view = testViewController.gameButtonView.subviews[key] as? UIImageView else { return }
        guard let actionName = view.subviews.first as? UILabel else { return }
        
        selectedIndex = key
        screen.selectedButton = key
        screen.characterVM.inputAction = actionName.text! == "" ? "Default" : actionName.text!
        screen.characterVM.activateCharacter()
        
        view.image = UIImage(systemName: "circle.fill")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let view = testViewController.gameButtonView.subviews[selectedIndex] as? UIImageView else { return }
        screen.selectedButton = -1
        view.image = UIImage(systemName: "circle")
    }
    
    // y위치에 따라서 index를 설정 후, index에 따라서 x위치를 확인
    func getTouchedIndex(_ pos: CGPoint) -> Int? {
        var touchedIndex: Int = 0
        
        let viewFrame = testViewController.gameButtonView.frame
        let viewWidth = viewFrame.width / 3
        let viewHeight = viewFrame.height
        
        if (viewWidth * 2 < pos.x) { touchedIndex = 2 }
        else if (viewWidth < pos.x) { touchedIndex = 1 }
        else { touchedIndex = 0 }
        
        if (touchedIndex == 0 && pos.y < viewHeight / 2) { return nil }
        if (touchedIndex == 1 && (pos.y < viewHeight / 4 || pos.y > (viewHeight * 3) / 4)) { return nil }
        if (touchedIndex == 2 && pos.y > viewHeight / 2) { return nil }
        
        return touchedIndex
    }
}
