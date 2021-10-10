//
//  Screen.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/09/24.
//

import UIKit

class ScreenView: UIView {
    var posX: CGFloat
    var posY: CGFloat
    
    var selectedStick: Int
    var selectedButton: Int
    
    var counters: [String: Int]
    var countersMax: [String: Int]
    
    var characterVM: CharacterViewModel!
    
    init(_ sideLen: CGFloat, _ data: Time) {
        posX = 0
        posY = sideLen - 100
        counters = [:]
        countersMax = [:]
        
        selectedStick = -1
        selectedButton = -1
        
        super.init(frame: CGRect(x: 0, y: 0, width: sideLen, height: sideLen))
        
        characterVM = CharacterViewModel(self, sideLen, data)
        characterVM.setActionObject()
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
        
        drawCharacter(context)
        
    }
    
    func drawCharacter(_ context: CGContext) {
        guard let curActionImages = characterVM.actionDic[characterVM.workingAction] else { return }
        let flipedImage =
            characterVM.isRight
            ? flipImageVertically(originalImage: curActionImages[counters["character"]!])
            : flipImageHorizontal(originalImage: curActionImages[counters["character"]!])
        
        context.draw(
            flipedImage.cgImage!,
            in: CGRect(x: characterVM.posX, y: characterVM.posY, width: 100, height: 100)
        )
    }
}

// image index counter
extension ScreenView {
    
    func initCounter() {
        guard let curActionImages = characterVM.actionDic[characterVM.workingAction] else { return }
        
        counters["character"] = 0
        countersMax["character"] = curActionImages.count - 1
    }
    
    func counterFunc() {
        for key in counters.keys {
            if (counters[key] == countersMax[key]) {
                counters[key] = 0
            } else {
                counters[key]! += 1
            }
        }
    }
}
