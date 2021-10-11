//
//  Screen.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/09/24.
//

import UIKit

class ScreenView: UIView {
    var selectedStick: Int
    var selectedButton: Int
    
    var characterVM: CharacterViewModel!
    var backgroundVM: BackgroundViewModel!
    
    init(_ sideLen: CGFloat, _ data: Time) {
        selectedStick = -1
        selectedButton = -1
        super.init(frame: CGRect(x: 0, y: 0, width: sideLen, height: sideLen))
        
        characterVM = CharacterViewModel(self, sideLen, data)
        characterVM.setActionObject()
        
        backgroundVM = BackgroundViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// draw
extension ScreenView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        backgroundVM.drawBackground(context)
        characterVM.drawCharacter(context)
        
    }
}

