//
//  GameButtonView.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/09/12.
//

import UIKit

class GameButtonView: UIView {
    weak var testViewController: GameBoyPanelCollectionViewCell!
    var prevTouchedIndex: Int = 0
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let pos = touches.first?.location(in: self) else { return }
        let viewFrame = testViewController.gameButtonView.frame
        
        if (testViewController.gameCommands == nil) {
            testViewController.initGameCommandsArr()
        }
        
        initPrevIndexButtonImage()
        prevTouchedIndex = getTouchedIndex(viewFrame, pos) ?? 0
        if (prevTouchedIndex == -1) { return }
        (testViewController.gameButtonView.subviews[prevTouchedIndex - 1] as! UIImageView).image = UIImage(systemName: "circle.fill")
        
        let view = testViewController.gameStickView.subviews[prevTouchedIndex] as! UIImageView
        print(view.subviews)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        initPrevIndexButtonImage()
    }
    
    func initPrevIndexButtonImage() {
        switch prevTouchedIndex {
        case 1:
            testViewController.gameButton_A.image = UIImage(systemName: "circle")
        case 2:
            testViewController.gameButton_B.image = UIImage(systemName: "circle")
        case 3:
            testViewController.gameButton_C.image = UIImage(systemName: "circle")
        default:
            return
        }
    }
    
    // y위치에 따라서 index를 설정 후, index에 따라서 x위치를 확인
    func getTouchedIndex(_ viewFrame: CGRect, _ pos: CGPoint) -> Int? {
        var touchedIndex: Int
        let viewWidth = viewFrame.width / 3
        
        if (viewWidth * 2 < pos.x) { touchedIndex = 3 }
        else if (viewWidth < pos.x) { touchedIndex = 2 }
        else { touchedIndex = 1 }
        
        if (touchedIndex == 1 && pos.y < viewFrame.height / 2) { return nil }
        if (touchedIndex == 2 && (pos.y < viewFrame.height / 4 || pos.y > (viewFrame.height * 3) / 4)) { return nil }
        if (touchedIndex == 3 && pos.y > viewFrame.height / 2) { return nil }
        
        return touchedIndex
    }
}
