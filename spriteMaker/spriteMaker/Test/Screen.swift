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
    
    var isRight: Bool
    var selectedStick: Int
    var selectedButton: Int
    var inputAction: String
    var workingAction: String
    
    var walkInterval: Timer!
    var jumpInterval: Timer!
    var attackInterval: Timer!
    var frameInterval: Timer!
    
    var counters: [String: Int]
    var countersMax: [String: Int]
    
    var isJumping: Bool
    var jumpAcc: CGFloat
    var jumpIsFalling: Bool
    var jumpBasePos: CGFloat
    
    init(_ sideLen: CGFloat, _ data: Time) {
        posX = 0
        posY = sideLen - 100
        gameData = data
        counters = [:]
        countersMax = [:]
        actionDic = [:]
        
        isRight = true
        selectedStick = -1
        selectedButton = -1
        inputAction = "Default"
        workingAction = "Default"
        
        isJumping = false
        jumpAcc = 40
        jumpIsFalling = false
        jumpBasePos = 0
        
        super.init(frame: CGRect(x: 0, y: 0, width: sideLen, height: sideLen))
        
        setActionObject()
        walkInterval = Timer()
        jumpInterval = Timer()
        attackInterval = Timer()
        frameInterval = Timer()
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
}

// draw
extension Screen {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        drawCharacter(context)
        
    }
    
    func drawCharacter(_ context: CGContext) {
        guard let curActionImages = actionDic[workingAction] else { return }
        let flipedImage =
            isRight
            ? flipImageVertically(originalImage: curActionImages[counters["character"]!])
            : flipImageHorizontal(originalImage: curActionImages[counters["character"]!])
        
        context.draw(
            flipedImage.cgImage!,
            in: CGRect(x: self.posX, y: self.posY, width: 100, height: 100)
        )
    }
}

extension Screen {
    
    func activateCharacter() {
        if (!(jumpInterval?.isValid ?? false)
            && !(walkInterval?.isValid ?? false)
            && !(attackInterval?.isValid ?? false)
        ) {
            workingAction = inputAction
            initCounter()
        }
        
        switch selectedButton {
        case 0:
            print("dash")
            activateDash()
        case 1:
//            print("attack")
            activateAttack()
        case 2:
            print("skill")
            activateSkill()
        default:
            return
        }
    }
    
    func activateDash() {
        let preAction: String
        let preActionCount: Int
        var acc: CGFloat
        
        if (!(walkInterval?.isValid ?? false)) {
            preAction = workingAction
            preActionCount = counters["character"] ?? 0
            acc = 50
            
            workingAction = inputAction
            activateFrameIntervalDividedTime(time: 0.3)
            walkInterval = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true)
            {[self] (Timer) in
                acc -= 8
                if (acc < 10) {
                    if (jumpInterval?.isValid == true) {
                        workingAction = preAction
                        activateFrameIntervalDividedTime(time: 0.6)
                        counters["character"] = preActionCount
                    } else {
                        inputAction = "Default"
                        activateFrameIntervalInputAction()
                    }
                    Timer.invalidate()
                } else {
                    posX += isRight ? acc : -acc
                }
                setNeedsDisplay()
            }
        }
    }
    
    func activateAttack() {
        if (walkInterval?.isValid == true) {
            walkInterval?.invalidate()
        }
        if (isJumping == true) {
            jumpInterval?.invalidate()
        }
        
        if (!(attackInterval?.isValid ?? false)) {
            let preAction: String
            let preActionCount: Int
            var acc: Int
            
            preAction = workingAction
            preActionCount = counters["character"] ?? 0
            acc = 50
            
            workingAction = inputAction
            activateFrameIntervalDividedTime(time: 0.3)
            attackInterval = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true)
            {[self] (Timer) in
                acc -= 8
                if (acc < 10) {
                    if (isJumping == true) {
                        workingAction = preAction
                        activateJump()
                        counters["character"] = preActionCount
                    } else {
                        inputAction = "Default"
                        activateFrameIntervalInputAction()
                    }
                    Timer.invalidate()
                }
                setNeedsDisplay()
            }
        }
    }
    
    func activateSkill() {
        let preAction: String
        let preActionCount: Int
        var acc: Int
        
        if (walkInterval?.isValid == true) {
            walkInterval?.invalidate()
        }
        preAction = workingAction
        preActionCount = counters["character"] ?? 0
        acc = 50
        
        workingAction = inputAction
        activateFrameIntervalDividedTime(time: 0.6)
        
        if (!(attackInterval?.isValid ?? false)) {
            attackInterval = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true)
            {[self] (Timer) in
                acc -= 8
                if (acc < 10) {
                    if (jumpInterval?.isValid == true) {
                        workingAction = preAction
                        activateFrameIntervalDividedTime(time: 0.6)
                        counters["character"] = preActionCount
                    } else {
                        inputAction = "Default"
                        activateFrameIntervalInputAction()
                    }
                    Timer.invalidate()
                }
                setNeedsDisplay()
            }
        }
    }
}

// move interval
extension Screen {
    
    func moveCharacter() {
        if (!(jumpInterval?.isValid ?? false) && !(walkInterval?.isValid ?? false)) {
            workingAction = inputAction
            initCounter()
        }
        
        switch selectedStick {
        case 0:
            activateJump()
        case 1:
            activateWalk("y", 0, selectedStick)
        case 2:
            activateWalk("x", -20, selectedStick)
            isRight = false
        case 3:
            activateWalk("x", 20, selectedStick)
            isRight = true
        default:
            return
        }
    }
    
    func activateWalk(_ dir: String, _ val: CGFloat, _ curStick: Int) {
        if (!(walkInterval?.isValid ?? false)) {
            walkInterval = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true)
            {[self] (Timer) in
                if (selectedStick == curStick) {
                    if (dir == "x") { posX += val }
                    if (dir == "y") { posY += val }
                    setNeedsDisplay()
                } else {
                    activateFrameIntervalInputAction()
                    Timer.invalidate()
                }
            }
        }
    }
    
    func activateJump() {
        
        if (jumpBasePos == 0) {
            jumpBasePos = posY
        }
        if (!(jumpInterval?.isValid ?? false)) {
            isJumping = true
            
            if (selectedButton != 0 && walkInterval?.isValid == true) {
                activateFrameIntervalInputAction()
                walkInterval?.invalidate()
            }
            activateFrameIntervalDividedTime(time: 0.6)
            
            jumpInterval = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true)
            {[self] Timer in
                jumpAcc += jumpIsFalling ? 8 : -8
                
                if (jumpAcc < 10) {
                    jumpIsFalling = true
                } else {
                    posY += jumpIsFalling ? jumpAcc : -jumpAcc
                    setNeedsDisplay()
                }
                
                if (jumpIsFalling && posY == jumpBasePos) {
                    inactivateFrameInterval()
                    isJumping = false
                    jumpAcc = 40
                    jumpIsFalling = false
                    jumpBasePos = 0
                    if (selectedStick == 0) {
                        Timer.invalidate()
                        activateJump()
                    } else {
                        Timer.invalidate()
                        activateFrameIntervalInputAction()
                    }
                }
            }
        }
    }
}

// frame interval
extension Screen {
    
    func activateFrameInterval(_ time: TimeInterval) {
        if (!(frameInterval?.isValid ?? false)) {
            frameInterval = Timer.scheduledTimer(withTimeInterval: time, repeats: true)
            { Timer in
                self.counterFunc()
                self.setNeedsDisplay()
            }
        }
    }
    
    func inactivateFrameInterval() {
        frameInterval.invalidate()
    }
    
    func activateFrameIntervalInputAction() {
        workingAction = selectedStick == -1 ? "Default" : inputAction
        initCounter()
        if (frameInterval?.isValid == true) {
            inactivateFrameInterval()
        }
        activateFrameInterval(0.2)
    }
    
    func activateFrameIntervalDividedTime(time: Double) {
        guard let curActionImages = actionDic[workingAction] else { return }
        let dividedTime: TimeInterval = time / Double(curActionImages.count)
        
        initCounter()
        inactivateFrameInterval()
        activateFrameInterval(dividedTime)
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
