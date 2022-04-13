//
//  PickerTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/28.
//

import UIKit

class ColorPicker: UIView {
    var canvasRect: CGRect
    var grid: [Int] = generateInitGrid()
    var touchPos: CGPoint = CGPoint(x: 0, y: 0)
    var curColor: UIColor = .white
    var updateCurColor: (_ color: UIColor)->Void
    let pixelSize = 25
    let curColorWidth: CGFloat = 10
    let lineWidth: CGFloat = 7
    let naviHeight: CGFloat
    
    init(_ frame: CGRect, _ canvasFrame: CGRect, _ updateColor: @escaping (_:UIColor)->Void, _ naviHeight: CGFloat) {
        self.canvasRect = canvasFrame
        self.updateCurColor = updateColor
        self.naviHeight = naviHeight
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
        if (touchY + halfOfWidth - topSafeInset - naviHeight < canvasRect.minY) { touchY = canvasRect.minY - halfOfWidth + topSafeInset + naviHeight }
        if (touchY + halfOfWidth - topSafeInset - naviHeight > canvasRect.maxY) { touchY = canvasRect.maxY - halfOfWidth + topSafeInset + naviHeight }

        self.frame = CGRect(x: touchX, y: touchY, width: self.frame.width, height: self.frame.height)
        updateCurColor(curColor)
        self.setNeedsDisplay()
    }
    
    func drawPicker(_ context: CGContext) {
        let halfOfWidth = self.frame.width / 2
        let topSafeInset = (self.window?.safeAreaInsets.top)!
        let onePixelLength = canvasRect.width / 16
        let position = CGPoint(
            x: Int((self.frame.minX - canvasRect.minX) / onePixelLength),
            y: Int((self.frame.minY - canvasRect.minY - topSafeInset - naviHeight) / onePixelLength)
        )
        drawPixelRect(context, position)
        drawCenterPixelRect(context, position)
        // inner line
        context.setLineWidth(lineWidth)
        drawOutline(context, CGPoint(x: halfOfWidth, y: halfOfWidth),
                    radius: halfOfWidth - curColorWidth - lineWidth)
        // outer line
        context.setLineWidth(lineWidth * 2)
        context.setStrokeColor(curColor.cgColor)
        drawOutline(context, CGPoint(x: halfOfWidth, y: halfOfWidth),
                    radius: halfOfWidth - lineWidth)
    }
    
    private func drawOutline(_ context: CGContext, _ center: CGPoint, radius: CGFloat) {
        context.addArc(center: center, radius: radius,
                       startAngle: 0, endAngle: CGFloat(Double.pi * 2),
                       clockwise: true)
        context.strokePath()
    }
    
    private func drawCenterPixelRect(_ context: CGContext, _ pos: CGPoint) {
        guard let gridIdx = getGridIndex(CGPoint(x: pos.x + 3, y: pos.y + 3)) else { return }
        guard let fillColor = transIntToHex(grid[gridIdx]) else { return }
        let rectX = 12.5 + Double(2 * pixelSize)
        let rectY = 12.5 + Double(2 * pixelSize)
        let rectangle = CGRect(x: rectX, y: rectY, width: Double(pixelSize), height: Double(pixelSize))
        
        curColor = fillColor == "none" ? UIColor.init(named: "Color2")! : fillColor.uicolor!
        context.setStrokeColor(getColorBasedOnColorBrightness(curColor).cgColor)
        context.addRect(rectangle)
        context.setLineWidth(3)
        context.strokePath()
    }
    
    private func drawPixelRect(_ context: CGContext, _ pos: CGPoint) {
        context.setStrokeColor(UIColor.init(named: "Color_gridLine")!.cgColor)
        for countY in 0...4 {
            for countX in 0...4 {
                let x = Int(pos.x) + countX + 1
                let y = Int(pos.y) + countY + 1
                if (isInnerPos(x, y) == false) { continue }
                if (isCorner(countX, countY) == true) { continue }
                
                let rectX = 12.5 + Double(countX * pixelSize)
                let rectY = 12.5 + Double(countY * pixelSize)
                let rectangle = CGRect(x: rectX, y: rectY, width: Double(pixelSize), height: Double(pixelSize))
                guard let gridIdx = getGridIndex(CGPoint(x: x, y: y)) else { continue }
                if (grid[gridIdx] == -1) {
                    context.setFillColor(UIColor.init(named: "Color2")!.cgColor)
                } else {
                    guard let hex = transIntToHex(grid[gridIdx]) else { continue }
                    context.setFillColor(hex.uicolor!.cgColor)
                }
                context.addRect(rectangle)
                context.drawPath(using: .fillStroke)
            }
        }
    }
    
    private func isCorner(_ x: Int, _ y: Int) -> Bool {
        if (x != 0 && x != 4) { return false }
        if (y != 0 && y != 4) { return false }
        return true
    }
    
    private func isInnerPos(_ x: Int, _ y: Int) -> Bool {
        if (x < 0 || x > 15) { return false }
        if (y < 0 || y > 15) { return false }
        return true
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
        var naviHeight: CGFloat = 0
        if let navi = canvas.drawingVC.navigationController {
            naviHeight = navi.navigationBar.frame.height
        }
        let canvasFrame = canvas.drawingVC.canvasView.frame
        
        let pickerFrame = CGRect(
            x: canvasFrame.midX - pickerSize.width / 2,
            y: canvasFrame.midY - (pickerSize.width / 2) + naviHeight + (canvas.window?.safeAreaInsets.top)!,
            width: pickerSize.width, height: pickerSize.height
        )
        
        pickerView = ColorPicker(pickerFrame, canvasFrame, updateCurColor, naviHeight)
        pickerView.backgroundColor = .clear
        canvas.drawingVC.view.addSubview(pickerView)
        canvas.drawingVC.colorPickerToolBar.sliderView.slider.value = 0
    }
    
    func setPickerPosition(pos: CGPoint) {
        let pickerWidth = pickerView.frame.width
        
        pickerView.frame = CGRect(
            x: pos.x - pickerWidth / 2,
            y: pos.y - pickerWidth / 2,
            width: 150, height: 150
        )
    }
    
    func setPickerPositionCenter() {
        let canvasFrame = canvas.drawingVC.canvasView.frame
        setPickerPosition(pos: CGPoint(
            x: canvasFrame.midX,
            y: canvasFrame.midY + (canvas.window?.safeAreaInsets.top)!
        ))
    }
    
    func removePickerView() {
        pickerView.removeFromSuperview()
    }
    
    func getFrameImage() {
        guard let layerVM = canvas.drawingVC.previewImageToolBar.layerVM else { return }
        guard let frame = layerVM.selectedFrame else { return }
        let gridData: [Int]
        
        if (layerVM.checkFrameIsEmpty(index: layerVM.selectedFrameIndex)) {
            gridData = generateInitGrid()
        } else {
            let image = frame.renderedImage
            let pixelWidth = (image.cgImage!.width) / 16
            gridData = transImageToGrid(image: image, start: CGPoint(x: 0, y: 0), pixelWidth)
        }
        pickerView.grid = gridData
    }
    
    func updateCurColor(color: UIColor) {
        guard let hex = color.hexa else { return }
        let colorIndex = CoreData.shared.getColorIndex(hex)
        
        CoreData.shared.selectedColorIndex = colorIndex
        canvas.selectedColor = color
        canvas.drawingVC.colorPaletteVM.selectedColorIndex = colorIndex
        canvas.drawingVC.colorPickerToolBar.selectedColor = color
        canvas.drawingVC.colorPickerToolBar.initSliderColor()
        canvas.drawingVC.colorPickerToolBar.colorCollectionList.scrollToItem(
            at: IndexPath(row: colorIndex, section: 0), at: .left, animated: true
        )
    }
}

extension PickerTool {
    func initPickerTool() {
        initPickerView()
        getFrameImage()
        pickerView.isHidden = false
        pickerView.setNeedsDisplay()
    }
    
    func noneTouches(_ context: CGContext) {
        initPickerTool()
    }
    
    func touchesBegan(_ pixelPos: CGPoint) {
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
        initPickerTool()
    }
    
    func touchesMoved(_ context: CGContext) {
    }
    
    func touchesEnded(_ context: CGContext) {
    }
    
    func setUnused() {
        if (pickerView != nil) {
            setPickerPositionCenter()
            pickerView.isHidden = true
        }
    }
    
    func initToolSetting() {
        if (pickerView != nil) {
            setPickerPositionCenter()
            pickerView.isHidden = true
        }
    }
}



