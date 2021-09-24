//
//  Screen.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/09/24.
//

import UIKit

class Screen: UIView {
    var posX: CGFloat
    var posY: CGFloat
    var gameData: Time
    var actionDic: [String: [UIImage]]
    var curAction: String
    
    var jumpInterval: Timer!
    var animationInterval: Timer!
    
    init(_ sideLen: CGFloat, _ data: Time) {
        posX = 0
        posY = sideLen - 100
        gameData = data
        actionDic = [:]
        curAction = "Default"
        
        super.init(frame: CGRect(x: 0, y: 0, width: sideLen, height: sideLen))
        
        setActionObject()
        jumpInterval = Timer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        drawCharacter(context)
        
    }
    
    func setActionObject() {
        for frame in gameData.frames {
            if (actionDic[frame.category] == nil) {
                actionDic[frame.category] = [frame.renderedImage]
            } else {
                actionDic[frame.category]?.append(frame.renderedImage)
            }
        }
    }
    
    func drawCharacter(_ context: CGContext) {
        // 현재 action을 참조하여 화면에 그릴 이미지를 actionDic에서 찾아 그린다.
        guard let curActionImages = actionDic[curAction] else { return }
        let index = 0
        let flipedImage = flipImageVertically(originalImage: curActionImages[index])
        context.draw(flipedImage.cgImage!, in: CGRect(x: self.posX, y: self.posY, width: 100, height: 100))
    }
    
    func activeAnimation() {
        
    }
    
    func jumpAction() {
        var acc: CGFloat
        var isFalling: Bool
        
        acc = 0
        isFalling = false
        if (!(jumpInterval?.isValid ?? false)) {
            jumpInterval = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { Timer in
                acc = isFalling ? acc - 10 : acc + 10
                
                if (acc > 40) {
                    isFalling = true
                } else {
                    self.posY = isFalling ? self.posY + acc : self.posY - acc
                    self.setNeedsDisplay()
                }
                if (isFalling && acc < 10) {
                    Timer.invalidate()
                }
            }
        }
    }

}
