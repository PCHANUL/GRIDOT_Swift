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
    
    var jumpAcc: CGFloat
    var jumpIsFalling: Bool
    var jumpBasePos: CGFloat
    
    var isJumping: Bool
    var isAttacking: Bool
    var isWalking: Bool
    
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
        
        jumpAcc = 40
        jumpIsFalling = false
        jumpBasePos = 0
        
        isJumping = false
        isAttacking = false
        isWalking = false
        
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
        if ((isJumping || isWalking || isAttacking) == false) {
            workingAction = inputAction
            initCounter()
        }
        
        switch selectedButton {
        case 0:
            activateDash()
        case 1:
            activateAttack()
        case 2:
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
        let preAction: String
        let preActionCount: Int
        var acc: Int
        
        var wasJumping: Bool = false
        
        if (isAttacking == false) {
            isAttacking = true
            
            if (isWalking) {
                walkInterval?.invalidate()
                isWalking = false
            }
            if (isJumping) {
                jumpInterval?.invalidate()
                wasJumping = true
            }
            
            preAction = workingAction
            preActionCount = counters["character"] ?? 0
            acc = 50
            
            workingAction = inputAction
            activateFrameIntervalDividedTime(time: 0.3)
            
            attackInterval = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true)
            {[self] (Timer) in
                acc -= 8
                if (acc < 10) {
                    if (wasJumping == true) {
                        workingAction = preAction
                        isJumping = false
                        activateJump()
                        counters["character"] = preActionCount
                    } else {
                        inputAction = "Default"
                        activateFrameIntervalInputAction()
                        isAttacking = false
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
        
        if (isWalking) { walkInterval?.invalidate() }
        
        preAction = workingAction
        preActionCount = counters["character"] ?? 0
        acc = 50
        
        workingAction = inputAction
        activateFrameIntervalDividedTime(time: 0.6)
        
        if (isAttacking == false) {
            isAttacking = true
            
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
                    isAttacking = false
                }
                setNeedsDisplay()
            }
        }
    }
}

// move interval
extension Screen {
    
    func moveCharacter() {
        if ((isJumping || isWalking) == false) {
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
        if (isWalking == false) {
            isWalking = true
            walkInterval = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true)
            {[self] (Timer) in
                if (selectedStick == curStick) {
                    if (dir == "x") { posX += val }
                    if (dir == "y") { posY += val }
                    setNeedsDisplay()
                } else {
                    activateFrameIntervalInputAction()
                    isWalking = false
                    Timer.invalidate()
                }
            }
        }
    }
    
    func activateJump() {
        
        if (jumpBasePos == 0) {
            jumpBasePos = posY
        }
        
        if (isJumping == false) {
            isJumping = true
            
            if (selectedButton != 0 && isWalking) {
                activateFrameIntervalInputAction()
                walkInterval?.invalidate()
                isWalking = false
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
                        isJumping = false
                        activateJump()
                    } else {
                        Timer.invalidate()
                        isJumping = false
                        activateFrameIntervalInputAction()
                    }
                }
                if (isAttacking) {
                    isAttacking = false
                }
            }
        }
    }
    
    func jumpFunction() {
        
    }
}

// frame interval
extension Screen {
    
    func activateFrameInterval(_ time: TimeInterval) {
        if (!(frameInterval?.isValid ?? false)) {
            frameInterval = Timer.scheduledTimer(withTimeInterval: time, repeats: true)
            {[self] Timer in
                counterFunc()
                setNeedsDisplay()
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
        for key in counters.keys {
            if (counters[key] == countersMax[key]) {
                counters[key] = 0
            } else {
                counters[key]! += 1
            }
        }
    }
}
