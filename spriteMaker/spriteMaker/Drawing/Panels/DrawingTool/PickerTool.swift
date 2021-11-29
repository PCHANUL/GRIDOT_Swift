//
//  PickerTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/28.
//

import UIKit

class ColorPicker: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        drawPicker(context)
    }
    
    func drawPicker(_ context: CGContext) {
        let halfOfWidth = self.frame.width / 2
        let curColor = "#555555"
        let curColorWidth: CGFloat = 10
        let lineWidth: CGFloat = 3
        
        // draw colored outline
        context.setStrokeColor(curColor.uicolor!.cgColor)
        context.setLineWidth(curColorWidth)
        context.addArc(
            center: CGPoint(x: halfOfWidth, y: halfOfWidth),
            radius: halfOfWidth - curColorWidth,
            startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true
        )
        context.strokePath()
        
        // draw outline
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(lineWidth)
        context.addArc(
            center: CGPoint(x: halfOfWidth, y: halfOfWidth),
            radius: halfOfWidth - curColorWidth - lineWidth - 1,
            startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true
        )
        context.strokePath()
    }
}

class PickerTool {
    var canvas: Canvas
    var grid: Grid
    var pickerView: ColorPicker!
    
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.grid = canvas.grid
    }
    
    func drawPicker(_ context: CGContext) {
        let pixelSize = canvas.onePixelLength! * 1.5
        let posX = canvas.moveTouchPosition.x
        let posY = canvas.moveTouchPosition.y
        let posGrid = canvas.transPosition(canvas.moveTouchPosition)
        var curColor = canvas.grid.findColorSelected(x: posGrid["x"]!, y: posGrid["y"]!)
        curColor = curColor == "none" ? "#555555" : curColor
        
        var rectangle: CGRect!
        let centerX: CGFloat = posX - (20 + pixelSize / 2)
        let centerY: CGFloat = posY - (20 + pixelSize / 2)
        var rectPosX: CGFloat = centerX - (pixelSize * 2)
        var rectPosY: CGFloat = centerY - (pixelSize * 2)
        var posGridX = posGrid["x"]! - 2
        var posGridY = posGrid["y"]! - 2
        var countX = 0
        var countY = 0
        
        let corner: [String: [Int]] = [
            "0": [0, 4],
            "4": [0, 4]
        ]
        
        func isCorner() -> Bool {
            guard let cornerX = corner[String(countX)] else { return false }
            return cornerX.firstIndex(of: countY) != nil
        }
        
        while countY < 5 {
            while countX < 5 {
                if isCorner() == false {
                    var fillColor = canvas.grid.findColorSelected(x: posGridX, y: posGridY)
                    fillColor = fillColor == "none" ? "#555555" : fillColor
                    context.setFillColor(fillColor.uicolor!.cgColor)
                    rectangle = CGRect(x: rectPosX, y: rectPosY, width: pixelSize, height: pixelSize)
                    context.addRect(rectangle)
                    context.drawPath(using: .fillStroke)
                }
                rectPosX += pixelSize
                countX += 1
                posGridX += 1
            }
            countY += 1
            posGridY += 1
            rectPosY += pixelSize
            // init
            countX = 0
            posGridX = posGrid["x"]! - 2
            rectPosX = centerX - (pixelSize * 2)
        }
        
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(canvas.onePixelLength / 5)
        context.setFillColor(curColor.uicolor!.cgColor)
        rectangle = CGRect(x: centerX, y: centerY, width: pixelSize, height: pixelSize)
        context.addRect(rectangle)
        context.drawPath(using: .fillStroke)

        // draw colored outline
        context.setStrokeColor(curColor.uicolor!.cgColor)
        context.setLineWidth(canvas.onePixelLength / 1)
        context.addArc(
            center: CGPoint(x: posX - 20, y: posY - 20),
            radius: pixelSize * 2.6,
            startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true
        )
        context.strokePath()
        
        // draw outline
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(canvas.onePixelLength / 3)
        context.addArc(
            center: CGPoint(x: posX - 20, y: posY - 20),
            radius: pixelSize * 2.3,
            startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true
        )
        context.strokePath()
    }
    
    func initPickerView() {
        let canvasFrame = canvas.drawingVC.canvasView.frame
        
        pickerView = ColorPicker(frame: CGRect(x: canvasFrame.midX, y: canvasFrame.midY, width: 150, height: 150))
        pickerView.backgroundColor = .clear
        canvas.drawingVC.view.addSubview(pickerView)
    }
    
    func movePickerPosition() {
        let canvasFrame = canvas.drawingVC.canvasView.frame
        var touchX = canvas.moveTouchPosition.x
        var touchY = canvas.moveTouchPosition.y
        
        if (touchX < 0 ) { touchX = 0 }
        if (touchY < 0) { touchY = 0 }
        if (touchX > canvasFrame.width) { touchX = canvasFrame.width }
        if (touchY > canvasFrame.height) { touchY = canvasFrame.height }
        
        setPickerPosition(pos: CGPoint(x: touchX + canvasFrame.minX, y: touchY + canvasFrame.minY))
    }
    
    func setPickerPosition(pos: CGPoint) {
        let pickerWidth = pickerView.frame.width
        
        pickerView.frame = CGRect(
            x: pos.x - pickerWidth / 2,
            y: pos.y,
            width: 150, height: 150
        )
    }
    
    func removePickerView() {
        pickerView.removeFromSuperview()
    }
}

extension PickerTool {
    func noneTouches(_ context: CGContext) {
        initPickerView()
        pickerView.isHidden = false
    }
    
    func touchesBegan(_ pixelPosition: [String: Int]) {
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
        pickerView.isHidden = false
    }
    
    func touchesMoved(_ context: CGContext) {
        movePickerPosition()
    }
    
    func touchesEnded(_ context: CGContext) {
        let endPosition = canvas.transPosition(canvas.moveTouchPosition)
        let removedColor = grid.findColorSelected(x: endPosition["x"]!, y: endPosition["y"]!)
        if (removedColor != "none") {
            canvas.selectedColor = removedColor.uicolor
            canvas.drawingVC.colorPaletteVM.selectedColorIndex = -1
            canvas.drawingVC.colorPickerToolBar.selectedColor = removedColor.uicolor
            canvas.drawingVC.colorPickerToolBar.updateColorBasedCanvasForThreeSection(true)
        }
    }
    
    func setUnused() {
        if (pickerView != nil) {
            let canvasFrame = canvas.drawingVC.canvasView.frame
            setPickerPosition(pos: CGPoint(x: canvasFrame.midX, y: canvasFrame.midY))
            pickerView.isHidden = true
        }
    }
}



