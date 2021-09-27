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
    var inputAction: String
    var workingAction: String
    
    var jumpInterval: Timer!
    var frameInterval: Timer!
    var counters: [String: Int]
    var countersMax: [String: Int]
    
    init(_ sideLen: CGFloat, _ data: Time) {
        posX = 0
        posY = sideLen - 100
        gameData = data
        counters = [:]
        countersMax = [:]
        actionDic = [:]
        inputAction = "Default"
        workingAction = "Default"
        
        super.init(frame: CGRect(x: 0, y: 0, width: sideLen, height: sideLen))
        
        setActionObject()
        jumpInterval = Timer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        drawCharacter(context)
    }
    
    func drawCharacter(_ context: CGContext) {
        guard let curActionImages = actionDic[workingAction] else { return }
        let flipedImage = flipImageVertically(originalImage: curActionImages[counters["character"]!])
        
        context.draw(
            flipedImage.cgImage!,
            in: CGRect(x: self.posX, y: self.posY, width: 100, height: 100)
        )
    }
    
    func jumpAction() {
        var acc: CGFloat
        var isFalling: Bool
        var basePos: CGFloat
        
        acc = 40
        basePos = posY
        isFalling = false
        
        if (!(jumpInterval?.isValid ?? false)) {
            if (inputAction != "Default") {
                inactivateInterval()
                activateJumpInterval()
            }
            jumpInterval = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true)
            {[self] Timer in
                acc = isFalling ? acc + 8 : acc - 8
                
                if (acc < 10) {
                    isFalling = true
                } else {
                    posY = isFalling ? posY + acc : posY - acc
                    setNeedsDisplay()
                }
                
                if (isFalling && posY == basePos) {
                    Timer.invalidate()
                    inactivateInterval()
                    activateFrameInterval()
                    
                }
            }
        }
    }

}

// image index counter
extension Screen {
    
    func initCounter() {
        guard let curActionImages = actionDic[workingAction] else { return }
        counters["character"] = 0
        countersMax["character"] = curActionImages.count - 1
    }
    
    func counterFunc() {
        for key in self.counters.keys {
            if (self.counters[key] == self.countersMax[key]) {
                self.counters[key] = 0
            } else {
                self.counters[key]! += 1
            }
        }
    }
}

// frame interval
extension Screen {
    
    func activateInterval(_ time: TimeInterval) {
        if (!(frameInterval?.isValid ?? false)) {
            frameInterval = Timer.scheduledTimer(withTimeInterval: time, repeats: true)
            { Timer in
                self.counterFunc()
                self.setNeedsDisplay()
            }
        }
    }
    
    func inactivateInterval() {
        frameInterval.invalidate()
    }
    
    func activateFrameInterval() {
        workingAction = "Default"
        initCounter()
        activateInterval(0.2)
    }
    
    func activateJumpInterval() {
        guard let curActionImages = actionDic[inputAction] else { return }
        let time: TimeInterval = 0.6 / Double(curActionImages.count)
        
        workingAction = inputAction
        initCounter()
        activateInterval(time)
    }
}
