//
//  HoldTool.swift
//  GriDot
//
//  Created by 박찬울 on 2022/01/11.
//

import UIKit

class HoldTool: NSObject {
    var pixels: [String: [Int: [Int]]] = [:]
    var canvas: Canvas!
    var pixelLen: CGFloat!
    
    var accX: CGFloat = 0
    var accY: CGFloat = 0
    var startX: CGFloat = 0
    var startY: CGFloat = 0
    var endX: CGFloat = 0
    var endY: CGFloat = 0
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.pixelLen = canvas.onePixelLength
    }
    
    // canvas에서 움직일 픽셀을 모두 가져온다.
    // grid에서 모든 픽셀을 지우고, 픽셀을 대신 그려준다.
    // 변경된 커서 위치 값을 가져와서 픽셀의 위치를 정한다.
    // touchesEnded되거나 buttonUp되면 움직인 모든 픽셀을 grid에 더한다.
    
    func setStartPosition(_ touchPosition: [String: Int]) {
        startX = (pixelLen * CGFloat(touchPosition["x"]!))
        startY = (pixelLen * CGFloat(touchPosition["y"]!))
        print(startX, startY)
    }
    
    func setMovePosition(_ touchPosition: [String: Int]) {
        endX = pixelLen * CGFloat(touchPosition["x"]!)
        endY = pixelLen * CGFloat(touchPosition["y"]!)
        accX = endX - startX
        accY = endY - startY
    }
    
    func drawSelectedAreaPixels(_ context: CGContext) {
        context.setStrokeColor(UIColor.init(named: "Color_gridLine")!.cgColor)
        context.setLineWidth(0.5)
        let widthOfPixel = Double(pixelLen)
        for hex in pixels {
            for x in hex.value {
                for y in x.value {
                    guard let uiColor = hex.key.uicolor else { return }
                    
                    context.setFillColor(uiColor.cgColor)
                    let xlocation = (Double(x.key) * widthOfPixel) + Double(accX)
                    let ylocation = (Double(y) * widthOfPixel)  + Double(accY)
                    let rectangle = CGRect(x: xlocation, y: ylocation,
                                           width: widthOfPixel, height: widthOfPixel)
                    context.addRect(rectangle)
                    context.drawPath(using: .fillStroke)
                }
            }
        }
        context.strokePath()
    }
}

extension HoldTool {
    func touchesBegan(_ pixelPosition: [String: Int]) {
        switch canvas.selectedDrawingMode {
        case "pen":
            setStartPosition(canvas.transPosition(canvas.initTouchPosition))
            if (canvas.selectedPixels.count == 0) {
                // 모든 픽셀을 가져온다.
                pixels = canvas.grid.gridLocations
                canvas.grid.initGrid()
                print(pixels)
            } else {
                // 선택된 픽셀을 가져온다.
            }
                
        case "touch":
            return
        default:
            return
        }
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
        drawSelectedAreaPixels(context)
    }
    
    func touchesMoved(_ context: CGContext) {
        switch canvas.selectedDrawingMode {
        case "pen":
            setMovePosition(canvas.transPosition(canvas.moveTouchPosition))
            drawSelectedAreaPixels(context)
        case "touch":
            return
        default:
            return
        }
    }
    
    func touchesEnded(_ context: CGContext) {
        let widthOfPixel = Double(pixelLen)
        
        switch canvas.selectedDrawingMode {
        case "pen":
            for hex in pixels {
                for x in hex.value {
                    for y in x.value {
                        let xPos = Double(x.key) + (Double(accX) / widthOfPixel)
                        let yPos = Double(y) + (Double(accY) / widthOfPixel)
                        canvas.grid.addLocation(hex: hex.key, x: Int(xPos), y: Int(yPos))
                    }
                }
            }
        default:
            return
        }
    }
    
    func buttonDown() {
       
    }
    
    func buttonUp() {
       
    }
}
