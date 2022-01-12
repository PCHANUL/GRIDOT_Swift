//
//  Canvas.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/04.
//

import UIKit
import QuartzCore

class Canvas: UIView {
    var grid: Grid!
    var drawingVC: DrawingViewController!
 
    var numsOfPixels: Int!
    var lengthOfOneSide: CGFloat!
    var onePixelLength: CGFloat!
    
    var isTouchesBegan: Bool!
    var isTouchesMoved: Bool!
    var isTouchesEnded: Bool!
    var initTouchPosition: CGPoint!
    var moveTouchPosition: CGPoint!
    var targetLayerIndex: Int = 0
    var selectedColor: UIColor!
    var activatedDrawing: Bool!
    var selectedDrawingMode: String!
    var selectedDrawingTool: String!
    var isGridHidden: Bool = false
    
    // selectLine
    var selectedPixels: [Int: [Int]] = [:]
    var accX: CGFloat = 0
    var accY: CGFloat = 0
    var isDrawingSelectLine: Bool = false
    var outlineToggle: Bool = false
    var drawOutlineInterval: Timer?
 
    // tools
    var lineTool: LineTool!
    var squareTool: SquareTool!
    var eraserTool: EraserTool!
    var pencilTool: PencilTool!
    var pickerTool: PickerTool!
    var selectSquareTool: SelectSquareTool!
    var magicTool: MagicTool!
    var paintTool: PaintTool!
    var photoTool: PhotoTool!
    var undoTool: UndoTool!
    var handTool: HandTool!
    var touchDrawingMode: TouchDrawingMode!
    
    var timeMachineVM: TimeMachineViewModel!
    var timerTouchesEnded: Timer?
    var canvasRenderer: UIGraphicsImageRenderer!
    
    init(_ lengthOfOneSide: CGFloat, _ numsOfPixels: Int, _ drawingVC: DrawingViewController?) {
        self.grid = Grid()
        self.selectedDrawingMode = "pen"
        self.selectedDrawingTool = CoreData.shared.selectedMainTool
        self.activatedDrawing = false
        self.lengthOfOneSide = lengthOfOneSide
        self.numsOfPixels = numsOfPixels
        self.onePixelLength = lengthOfOneSide / CGFloat(numsOfPixels)
        self.canvasRenderer = UIGraphicsImageRenderer(
            size: CGSize(width: lengthOfOneSide, height: lengthOfOneSide)
        )
        self.isTouchesBegan = false
        self.isTouchesMoved = false
        self.isTouchesEnded = false
        self.moveTouchPosition = CGPoint()
        self.initTouchPosition = CGPoint()
        self.drawingVC = drawingVC
        super.init(
            frame: CGRect(x: 0, y: 0, width: self.lengthOfOneSide, height: self.lengthOfOneSide)
        )
        
        self.lineTool = LineTool(self)
        self.squareTool = SquareTool(self)
        self.eraserTool = EraserTool(self)
        self.pencilTool = PencilTool(self)
        self.pickerTool = PickerTool(self)
        self.selectSquareTool = SelectSquareTool(self)
        self.magicTool = MagicTool(self)
        self.paintTool = PaintTool(self)
        self.photoTool = PhotoTool(self)
        self.undoTool = UndoTool(self)
        self.handTool = HandTool(self)
        self.touchDrawingMode = TouchDrawingMode(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reload() {
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        drawLayers(context)
        if isTouchesEnded {
            switchToolsTouchesEnded(context)
            isTouchesEnded = false
            isTouchesMoved = false
            isTouchesBegan = true
            draw(rect)
            updateViewModelImages(targetLayerIndex)
            updateAnimatedPreview()
            return
        }
        switchToolsAlwaysUnderGirdLine(context)
        if (!isGridHidden) { drawGridLine(context) }
        if (isDrawingSelectLine) { drawSelectedAreaOutline(context) }
        if isTouchesMoved {
            switchToolsTouchesMoved(context)
            isTouchesBegan = false
            return
        }
        if isTouchesBegan {
            switchToolsTouchesBeganOnDraw(context)
            return
        }
        switchToolsNoneTouches(context)
    }
    
    // layer의 순서대로 image와 grid데이터를 그린다.
    func drawLayers(_ context: CGContext) {
        let layerImages = drawingVC.layerVM.getVisibleLayerImages()
        let selectedLayerIndex = drawingVC.layerVM.selectedLayerIndex
        
        for idx in 0..<layerImages.count {
            guard layerImages[idx] != nil else { continue }
            if (idx != selectedLayerIndex) {
                let flipedImage = flipImageVertically(originalImage: layerImages[idx]!)
                context.draw(flipedImage.cgImage!, in: CGRect(x: 0, y: 0, width: self.lengthOfOneSide, height: self.lengthOfOneSide))
            } else {
                drawGridPixels(context, grid: grid.gridLocations, pixelWidth: onePixelLength)
            }
        }
    }
    
    // 캔버스의 그리드 선을 그린다
    func drawGridLine(_ context: CGContext) {
        context.setLineWidth(0.5)
        context.setStrokeColor(UIColor.init(named: "Color_gridLine")!.cgColor)
        
        for i in 1...Int(numsOfPixels - 1) {
            let gridWidth = onePixelLength * CGFloat(i)
            context.move(to: CGPoint(x: gridWidth, y: 0))
            context.addLine(to: CGPoint(x: gridWidth, y: lengthOfOneSide))
            context.move(to: CGPoint(x: 0, y: gridWidth))
            context.addLine(to: CGPoint(x: lengthOfOneSide, y: gridWidth))
        }
        context.strokePath()
    }
    
    // 점선으로 선택된 영역을 그린다.
    func drawSelectedAreaOutline(_ context: CGContext) {
        let addX = Int(accX / onePixelLength)
        let addY = Int(accY / onePixelLength)
        
        for posX in selectedPixels {
            for posY in posX.value {
                let x = (onePixelLength * CGFloat(posX.key)) + CGFloat(accX)
                let y = (onePixelLength * CGFloat(posY)) + CGFloat(accY)
                
                if (!isSelectedPixel(posX.key + addX, posY + addY - 1)) { drawSelectedAreaOutline(context, isVertical: false, x, y) }
                if (!isSelectedPixel(posX.key + addX, posY + addY + 1)) { drawSelectedAreaOutline(context, isVertical: false, x, y + onePixelLength) }
                if (!isSelectedPixel(posX.key + addX - 1, posY + addY)) { drawSelectedAreaOutline(context, isVertical: true, x, y) }
                if (!isSelectedPixel(posX.key + addX + 1, posY + addY)) { drawSelectedAreaOutline(context, isVertical: true, x + onePixelLength, y) }
            }
        }
    }
    
    func drawSelectedAreaOutline(_ context: CGContext, isVertical: Bool, _ x: CGFloat, _ y: CGFloat) {
        let term = onePixelLength / 4
        context.setLineWidth(1.5)
        
        drawLineWithColorAndDiection(context, outlineToggle, isVertical, CGPoint(x: x, y: y))
        drawLineWithColorAndDiection(context, !outlineToggle, isVertical, CGPoint(x: x + (isVertical ? 0 : term), y: y + (isVertical ? term : 0)))
        drawLineWithColorAndDiection(context, !outlineToggle, isVertical, CGPoint(x: x + (isVertical ? 0 : term * 2), y: y + (isVertical ? term * 2 : 0)))
        drawLineWithColorAndDiection(context, outlineToggle, isVertical, CGPoint(x: x + (isVertical ? 0 : term * 3), y: y + (isVertical ? term * 3 : 0)))
    }
    
    func drawLineWithColorAndDiection(_ context: CGContext, _ isWhite: Bool, _ isVertical: Bool, _ start: CGPoint) {
        let color = isWhite ? UIColor.white : UIColor.lightGray
        let len = onePixelLength / 4
        let x = start.x + (isVertical ? 0 : len)
        let y = start.y + (isVertical ? len : 0)
        
        context.setStrokeColor(color.cgColor)
        context.move(to: start)
        context.addLine(to: CGPoint(x: x, y: y))
        context.strokePath()
    }
    
    // 선택 영역 확인
    func isSelectedPixel(_ x: Int, _ y: Int) -> Bool {
        guard let posX = selectedPixels[x] else { return false }
        if (posX.firstIndex(of: y) != nil) { return true }
        return false
    }
    
    // 선택 영역 외곽선을 위한 인터벌
    func startDrawOutlineInterval() {
        if (!(drawOutlineInterval?.isValid ?? false)) {
            drawingVC.drawingToolBar.addSelectToolControlButtton { [self] in
                drawOutlineInterval?.invalidate()
                updateViewModelImages(targetLayerIndex)
                drawingVC.drawingToolBar.cancelButton.removeFromSuperview()
                drawingVC.drawingToolBar.drawingToolCVTrailing.constant = 5
                isDrawingSelectLine = false
                selectedPixels = [:]
                setNeedsDisplay()
            }
            drawOutlineInterval = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true)
            { (Timer) in
                self.setNeedsDisplay()
                self.outlineToggle = !self.outlineToggle
            }
        }
    }
    
    func alertIsHiddenLayer() {
        let alert = UIAlertController(title: "", message: "현재 선택된 레이어가 숨겨진 상태입니다\n해제하시겠습니까?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: hiddenAlertHandler))
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
        drawingVC.present(alert, animated: true)
    }
    
    func hiddenAlertHandler(_ alert: UIAlertAction) -> Void {
        drawingVC.layerVM.toggleVisibilitySelectedLayer()
    }
    
    // 터치 시작
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (drawingVC.layerVM.isHiddenSelectedLayer) {
            alertIsHiddenLayer()
        } else {
            let position = findTouchPosition(touches: touches)
            if (activatedDrawing) {
                moveTouchPosition = position
            } else {
                initTouchPosition = position
                moveTouchPosition = position
            }
            switchToolsTouchesBegan(initTouchPosition)
            isTouchesBegan = true
            timerTouchesEnded?.invalidate()
            setNeedsDisplay()
        }
    }
    
    // 터치 움직임
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let movePosition = findTouchPosition(touches: touches)
        if (selectedDrawingMode == "touch") {
            moveTouchPosition = CGPoint(
                x: movePosition.x - touchDrawingMode.cursorTerm.x,
                y: movePosition.y - touchDrawingMode.cursorTerm.y
            )
        } else {
            moveTouchPosition = CGPoint(x: movePosition.x, y: movePosition.y)
        }
        isTouchesMoved = true
        setNeedsDisplay()
    }
    
    // 터치 마침
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isTouchesMoved {
            isTouchesEnded = true
        }
        if (isTouchesBegan && selectedDrawingTool == "Pencil") {
            timerTouchesEnded = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false)
            { (Timer) in
                self.isTouchesBegan = false
                self.setNeedsDisplay()
            }
        }
        updateViewModelImages(targetLayerIndex)
        updateAnimatedPreview()
        self.setNeedsDisplay()
    }
    
    // 터치 좌표 초기화
    func setCenterTouchPosition() {
        let centerOfSide: CGFloat!
        
        centerOfSide = (onePixelLength * 7) + (onePixelLength / 2)
        initTouchPosition = CGPoint(x: centerOfSide, y: centerOfSide)
        moveTouchPosition = CGPoint(x: centerOfSide, y: centerOfSide)
    }
    
    // 보정된 터치 좌표 반환
    func findTouchPosition(touches: Set<UITouch>) -> CGPoint {
        guard var point = touches.first?.location(in: self) else { return CGPoint() }
        point.y = point.y - 5
        return point
    }
    
    // 터치 좌표를 Grid 좌표로 변환
    func transPosition(_ point: CGPoint) -> [String: Int] {
        let x = Int(point.x / onePixelLength)
        let y = Int(point.y / onePixelLength)
        return ["x": x == 16 ? 15 : x, "y": y == 16 ? 15 : y]
    }
    
    // Grid에 좌표 추가
    func selectPixel(pixelPosition: [String: Int]) {
        guard let hex = selectedColor.hexa else { return }
        guard let x = pixelPosition["x"], let y = pixelPosition["y"] else { return }
        if grid.isColored(hex: hex) == false {
            grid.addColor(hex: hex, x: x, y: y)
        } else {
            grid.addLocation(hex: hex, x: x, y: y)
        }
    }
    
    // Grid에서 좌표 제거
    func removePixel(pixelPosition: [String: Int]) {
        guard let x = pixelPosition["x"], let y = pixelPosition["y"] else { return }
        grid.removeLocation(x, y)
    }
    
    // PencilTool의 함수로 픽셀이 선택되는 범위를 확인
    func transPositionWithAllowRange(_ point: CGPoint, range: Int) -> [String: Int]? {
        let pixelSize = Int(onePixelLength)
        let x = Int(point.x) % pixelSize
        let y = Int(point.y) % pixelSize
        if range > pixelSize || range < 0 { return nil }
        if checkPixelRange(x, range, pixelSize) && checkPixelRange(y, range, pixelSize) {
            return transPosition(point)
        }
        return nil
    }
    
    func checkPixelRange(_ point: Int, _ range: Int, _ pixelSize: Int) -> Bool {
        return (range / 2 < point) && (pixelSize - range / 2 > point)
    }
}

// LayerVM Methods
extension Canvas {
    // canvas를 UIImage로 렌더링
    func renderCanvasImage() -> UIImage {
        return canvasRenderer.image { context in
            drawLayers(context.cgContext)
        }
    }
    
    // 하나의 layer를 UIImage로 렌더링
    func renderLayerImage() -> UIImage {
        return canvasRenderer.image { context in
            drawGridPixels(context.cgContext, grid: grid.gridLocations, pixelWidth: onePixelLength)
        }
    }
    
    // viewModel 초기화
    func initViewModelImage(data: String) {
        guard let viewModel = drawingVC.layerVM else { return }
        if (data == "") {
            viewModel.frames = []
            viewModel.selectedFrameIndex = 0
            viewModel.selectedLayerIndex = 0
            viewModel.addEmptyFrame(index: 0)
            changeGrid(index: 0, gridData: "")
            timeMachineVM.addTime()
        } else {
            timeMachineVM.times = [data]
            timeMachineVM.endIndex = 0
            timeMachineVM.startIndex = 0
            timeMachineVM.setTimeToLayerVM()
        }
        drawingVC.previewImageToolBar.animatedPreviewVM.initAnimatedPreview()
    }
    
    // 캔버스의 이미지를 렌더링하여 layerVM의 selectedFrame과 selectedLayer를 업데이트
    func updateViewModelImages(_ layerIndex: Int) {
        guard let viewModel = self.drawingVC.layerVM else { return }
        let previewImage: UIImage
        let layerImage: UIImage
        let gridData: String
        let frameIndex: Int
        
        frameIndex = viewModel.selectedFrameIndex
        layerImage = renderLayerImage()
        previewImage = renderCanvasImage()
        if (viewModel.isExistedFrameAndLayer(frameIndex, layerIndex)) {
            gridData = matrixToString(grid: grid.gridLocations)
            viewModel.updateSelectedLayerAndFrame(previewImage, layerImage, gridData: gridData)
        }
    }
    
    func updateAnimatedPreview() {
        if (drawingVC.previewImageToolBar.changeStatusToggle.selectedSegmentIndex == 0) {
            self.drawingVC.previewImageToolBar.animatedPreviewVM.changeAnimatedPreview()
        } else {
            self.drawingVC.previewImageToolBar.animatedPreviewVM.setSelectedFramePreview()
        }
    }
    
    // 캔버스를 바꿀경우 그리드를 데이터로 변환합니다.
    func changeGrid(index: Int, gridData: String) {
        let canvasArray: [String: [Int: [Int]]]
        
        targetLayerIndex = index
        canvasArray = stringToMatrix(gridData)
        grid.setGrid(newGrid: canvasArray)
        updateViewModelImages(index)
        updateAnimatedPreview()
        setNeedsDisplay()
    }
}
