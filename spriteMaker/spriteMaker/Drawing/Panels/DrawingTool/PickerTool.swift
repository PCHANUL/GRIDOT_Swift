//
//  PickerTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/28.
//

import UIKit

class ColorPicker: UIView {
    var canvasRect: CGRect
    var grid: [String:[Int:[Int]]] = [:]
    var touchPos: CGPoint = CGPoint(x: 0, y: 0)
    var curColor: UIColor = .white
    var updateCurColor: (_ color: UIColor)->Void
    
    init(_ frame: CGRect, _ canvasFrame: CGRect, _ updateColor: @escaping (_:UIColor)->Void) {
        self.canvasRect = canvasFrame
        self.updateCurColor = updateColor
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        drawPicker(context)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        
        touchPos = point
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        var touchX = self.frame.minX + point.x - touchPos.x
        var touchY = self.frame.minY + point.y - touchPos.y
        let halfOfWidth = self.frame.width / 2
        let topSafeInset = (self.window?.safeAreaInsets.top)!

        if (touchX + halfOfWidth < canvasRect.minX) { touchX = canvasRect.minX - halfOfWidth }
        if (touchX + halfOfWidth > canvasRect.maxX) { touchX = canvasRect.maxX - halfOfWidth }
        if (touchY + halfOfWidth - topSafeInset < canvasRect.minY) { touchY = canvasRect.minY - halfOfWidth + topSafeInset}
        if (touchY + halfOfWidth - topSafeInset > canvasRect.maxY) { touchY = canvasRect.maxY - halfOfWidth + topSafeInset}

        self.frame = CGRect(x: touchX, y: touchY, width: self.frame.width, height: self.frame.height)
        updateCurColor(curColor)
        self.setNeedsDisplay()
    }
    
    func drawPicker(_ context: CGContext) {
        let halfOfWidth = self.frame.width / 2
        let curColorWidth: CGFloat = 10
        let lineWidth: CGFloat = 3
        let topSafeInset = (self.window?.safeAreaInsets.top)!
        
        let position = transPosition(CGPoint(
            x: self.frame.minX - canvasRect.minX,
            y: self.frame.minY - canvasRect.minY - topSafeInset
        ))
        
        let pixelSize = 24
        var rectPosX = 15
        var rectPosY = 15
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
        
        func isInnerPos(_ pos: CGPoint) -> Bool {
            if (pos.x < 0 || pos.x > 15) { return false }
            if (pos.y < 0 || pos.y > 15) { return false }
            return true
        }

        context.setStrokeColor(UIColor.init(named: "Color_gridLine")!.cgColor)
        while countY < 5 {
            while countX < 5 {
                let x = position["x"]! + countX + 1
                let y = position["y"]! + countY + 1
                if (isCorner() == false) {

                    // get color
                    var fillColor = findColorSelected(gridData: grid, x: x, y: y)
                    fillColor = fillColor == "none" ? UIColor.init(named: "Color1")!.hexa! : fillColor
                    context.setFillColor(fillColor.uicolor!.cgColor)

                    // draw rectangle
                    let rectangle = CGRect(x: rectPosX, y: rectPosY, width: pixelSize, height: pixelSize)
                    context.addRect(rectangle)
                    context.drawPath(using: .fillStroke)

                }
                rectPosX += pixelSize
                countX += 1
            }
            countY += 1
            rectPosY += pixelSize

            // init
            countX = 0
            rectPosX = 15
        }
        
        // draw colored outline
        let fillColor = findColorSelected(
            gridData: grid,
            x: position["x"]! + 3,
            y: position["y"]! + 3
        )
        curColor = fillColor == "none" ? UIColor.init(named: "Color1")! : fillColor.uicolor!
        context.setStrokeColor(curColor.cgColor)
        context.setLineWidth(curColorWidth)
        context.addArc(
            center: CGPoint(x: halfOfWidth, y: halfOfWidth),
            radius: halfOfWidth - curColorWidth,
            startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true
        )
        context.strokePath()

        // draw outline
        context.setStrokeColor(UIColor.init(named: "Color_gridLine")!.cgColor)
        context.setLineWidth(lineWidth)
        context.addArc(
            center: CGPoint(x: halfOfWidth, y: halfOfWidth),
            radius: halfOfWidth - curColorWidth - lineWidth - 1,
            startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true
        )
        context.strokePath()
    }
    
    func findColorSelected(gridData: [String:[Int:[Int]]], x: Int, y: Int) -> String {
        for (hex, locations) in gridData {
            guard let location = locations[x] else { continue }
            if (location.firstIndex(of: y) != nil) { return hex }
        }
        return "none"
    }
    
    func transPosition(_ point: CGPoint) -> [String: Int] {
        let x = Int(point.x / (canvasRect.width / 16))
        let y = Int(point.y / (canvasRect.width / 16))

        return ["x": x == 16 ? 15 : x, "y": y == 16 ? 15 : y]
    }
}

class PickerTool {
    var canvas: Canvas
    var grid: Grid
    var pickerView: ColorPicker!
    let pickerSize = CGSize(width: 150, height: 150)
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.grid = canvas.grid
    }
    
    func initPickerView() {
        if (pickerView != nil) { return }
        let canvasFrame = canvas.drawingVC.canvasView.frame
        let pickerFrame = CGRect(
            x: canvasFrame.midX - pickerSize.width / 2,
            y: canvasFrame.midY + (canvas.window?.safeAreaInsets.top)! - pickerSize.width / 2,
            width: pickerSize.width, height: pickerSize.height
        )
        
        pickerView = ColorPicker(pickerFrame, canvasFrame, updateCurColor)
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
            y: pos.y - pickerWidth / 2,
            width: 150, height: 150
        )
    }
    
    func removePickerView() {
        pickerView.removeFromSuperview()
    }
    
    func getFrameImage() {
        guard let layerVM = canvas.drawingVC.previewImageToolBar.layerVM else { return }
        guard let image = layerVM.selectedFrame?.renderedImage else { return }
        let width = Int(image.cgImage!.width) / 16
        let gridData = transImageToGrid(image: image, start: CGPoint(x: 0, y: 0), width)
        
        pickerView.grid = gridData
    }
    
    func updateCurColor(color: UIColor) {
        canvas.selectedColor = color
        canvas.drawingVC.colorPaletteVM.selectedColorIndex = -1
        canvas.drawingVC.colorPickerToolBar.selectedColor = color
        canvas.drawingVC.colorPickerToolBar.updateColorBasedCanvasForThreeSection(true)
    }
}

extension PickerTool {
    func noneTouches(_ context: CGContext) {
        print("began")
        initPickerView()
        getFrameImage()
        pickerView.isHidden = false
    }
    
    func touchesBegan(_ pixelPosition: [String: Int]) {
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
        print("began")
        getFrameImage()
        pickerView.isHidden = false
    }
    
    func touchesMoved(_ context: CGContext) {
    }
    
    func touchesEnded(_ context: CGContext) {
    }
    
    func setUnused() {
        if (pickerView != nil) {
            let canvasFrame = canvas.drawingVC.canvasView.frame
            setPickerPosition(pos: CGPoint(
                x: canvasFrame.midX,
                y: canvasFrame.midY + (canvas.window?.safeAreaInsets.top)!
            ))
            pickerView.isHidden = true
        }
    }
}



