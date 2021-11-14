//
//  CharacterViewModel.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/10/10.
//

import UIKit

class CharacterViewModel {
    var screenView: ScreenView
    var posX: CGFloat
    var posY: CGFloat
    var gameData: Time
    var actionDic: [String: [UIImage]]
    
    var inputAction: String
    var workingAction: String
    
    var walkInterval: Timer!
    var jumpInterval: Timer!
    var attackInterval: Timer!
    var frameInterval: Timer!
    
    var jumpAcc: CGFloat
    var jumpIsFalling: Bool
    var jumpBasePos: CGFloat
    
    var isRight: Bool
    var isJumping: Bool
    var isAttacking: Bool
    var isWalking: Bool
    
    var counters: [String: Int]
    var countersMax: [String: Int]
    
    init(_ screen: ScreenView, _ sideLen: CGFloat, _ data: Time) {
        screenView = screen
        posX = 0
        posY = sideLen - 100
        gameData = data
        actionDic = [:]
        counters = [:]
        countersMax = [:]
        
        jumpAcc = 40
        jumpIsFalling = false
        jumpBasePos = 0
        
        isRight = true
        isJumping = false
        isAttacking = false
        isWalking = false
        
        walkInterval = Timer()
        jumpInterval = Timer()
        attackInterval = Timer()
        frameInterval = Timer()
        
        inputAction = "Default"
        workingAction = "Default"
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
        guard let curActionImages = actionDic[workingAction] else { return }
        let image = flipImageVertically(originalImage: curActionImages[counters["character"]!])
        let flipedImage = isRight ? image : flipImageHorizontal(originalImage: image)
        
        context.draw(flipedImage.cgImage!,
            in: CGRect(x: posX, y: posY, width: 16 * 4, height: 16 * 4)
        )
    }
}
 
// action
extension CharacterViewModel {
    func activateCharacter() {
        if ((isJumping || isWalking || isAttacking) == false) {
            workingAction = inputAction
            initCounter()
        }
        
        switch screenView.selectedButton {
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
                screenView.setNeedsDisplay()
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
                screenView.setNeedsDisplay()
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
                screenView.setNeedsDisplay()
            }
        }
    }
}

// move
extension CharacterViewModel {
    func moveCharacter() {
        let stickNum = screenView.selectedStick
        if ((isJumping || isWalking) == false) {
            workingAction = inputAction
            initCounter()
        }
        
        switch stickNum {
        case 0:
            activateJump()
        case 1:
            activateWalk("y", 0, stickNum)
        case 2:
            activateWalk("x", -20, stickNum)
            isRight = false
        case 3:
            activateWalk("x", 20, stickNum)
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
                if (screenView.selectedStick == curStick) {
                    if (dir == "x") { posX += val }
                    if (dir == "y") { posY += val }
                    screenView.setNeedsDisplay()
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
            if (screenView.selectedButton != 0 && isWalking) {
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
                    screenView.setNeedsDisplay()
                }
                
                if (jumpIsFalling && posY == jumpBasePos) {
                    inactivateFrameInterval()
                    isJumping = false
                    jumpAcc = 40
                    jumpIsFalling = false
                    jumpBasePos = 0
                    if (screenView.selectedStick == 0) {
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
}


// frame
extension CharacterViewModel {
    func activateFrameInterval(_ time: TimeInterval) {
        if (!(frameInterval?.isValid ?? false)) {
            frameInterval = Timer.scheduledTimer(withTimeInterval: time, repeats: true)
            {[self] Timer in
                counterFunc()
                screenView.setNeedsDisplay()
            }
        }
    }
    
    func inactivateFrameInterval() {
        frameInterval.invalidate()
    }
    
    func activateFrameIntervalInputAction() {
        workingAction = screenView.selectedStick == -1 ? "Default" : inputAction
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
