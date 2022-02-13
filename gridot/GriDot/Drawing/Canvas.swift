//
//  Canvas.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/04.
//

import UIKit
import QuartzCore

class Canvas: UIView {
    var drawingVC: DrawingViewController!
    var grid: Grid!
    var selectedArea: SelectedArea!
 
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
        
        self.selectedArea = SelectedArea(self)
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
            updateLayerImage(targetLayerIndex)
            updateAnimatedPreview()
            return
        }
        switchToolsAlwaysUnderGirdLine(context)
        if (!isGridHidden) { drawGridLine(context) }
        if (selectedArea.isDrawing) {
            selectedArea.drawSelectedAreaOutline(context)
        }
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
            if (idx != selectedLayerIndex) {
                guard let image = layerImages[idx] else { continue }
                if (image.size.height == 0 && image.size.width == 0) { continue }
                guard let flipedCgImage = flipImageVertically(originalImage: image).cgImage else { continue }
                let imageRect = CGRect(x: 0, y: 0, width: self.lengthOfOneSide, height: self.lengthOfOneSide)
                context.draw(flipedCgImage, in: imageRect)
            } else {
                drawGridPixelsInt32(context, grid.intGrid, onePixelLength)
                if (selectedArea.isDrawing) {
                    selectedArea.drawSelectedAreaPixels(context)
                }
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
    
    // 숨겨진 레이어
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
        updateLayerImage(targetLayerIndex)
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
    func transPosition(_ point: CGPoint) -> CGPoint {
        let x = Int(point.x / onePixelLength)
        let y = Int(point.y / onePixelLength)
        return CGPoint(x: x == 16 ? 15 : x, y: y == 16 ? 15 : y)
    }
    
    // Grid에서 픽셀 추가
    func addPixel(_ pos: CGPoint, _ color: String? = nil) {
        guard var hex = selectedColor.hexa else { return }
        
        if (color != nil) { hex = color! }
        if (selectedArea.isDrawing) {
            if (selectedArea.selectedPixelArrContains(pos)) {
                selectedArea.addLocation(hex, pos)
                grid.addLocation(hex, pos)
            }
        } else {
            grid.addLocation(hex, pos)
        }
    }
    
    // Grid에서 픽셀 제거
    func removePixel(_ pos: CGPoint) {
        if (selectedArea.isDrawing) {
            if (selectedArea.selectedPixelArrContains(pos)) {
                selectedArea.removeLocation(pos)
                grid.removeLocation(pos)
            }
        } else {
            grid.removeLocation(pos)
        }
    }
    
    // PencilTool의 함수로 픽셀이 선택되는 범위를 확인
    func transPositionWithAllowRange(_ point: CGPoint, range: Int) -> CGPoint? {
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
 
    func renderLayerImageIntData() -> UIImage {
        return canvasRenderer.image { context in
            drawGridPixelsInt32(context.cgContext, grid.intGrid, onePixelLength)
            if (selectedArea.isDrawing) {
                selectedArea.drawSelectedAreaPixels(context.cgContext)
            }
        }
    }
  
    func initViewModelImageIntData() {
        guard let viewModel = drawingVC.layerVM else { return }
        guard let data = CoreData.shared.selectedAsset.dataInt else { return }
        
        if (data.count == 0) {
            viewModel.frames = []
            viewModel.selectedFrameIndex = 0
            viewModel.selectedLayerIndex = 0
            viewModel.addEmptyFrame(index: 0)
            changeGrid(index: 0, gridData: [:])
            timeMachineVM.addTime()
        } else {
            timeMachineVM.timeData = [data]
            timeMachineVM.selectedData = [[:]]
            timeMachineVM.endIndex = 0
            timeMachineVM.startIndex = 0
            timeMachineVM.setTimeToLayerVMIntData()
        }
        drawingVC.previewImageToolBar.animatedPreviewVM.initAnimatedPreview()
    }

    func updateLayerImage(_ layerIndex: Int) {
        guard let viewModel = self.drawingVC.layerVM else { return }
        let frameIndex = viewModel.selectedFrameIndex
        let layerImage = renderLayerImageIntData()
        let previewImage = renderCanvasImage()
        
        if (viewModel.isExistedFrameAndLayer(frameIndex, layerIndex)) {
            viewModel.updateSelectedLayerAndFrame(previewImage, layerImage, data: grid.intGrid)
        }
    }
    
    func updateAnimatedPreview() {
        if(drawingVC.previewImageToolBar.changeStatusToggle.selectedSegmentIndex == 0) {
            self.drawingVC.previewImageToolBar.animatedPreviewVM.changeAnimatedPreview()
        } else {
            self.drawingVC.previewImageToolBar.animatedPreviewVM.setSelectedFramePreview()
        }
    }
    
    func changeGrid(index: Int, gridData: [String: [Int32]]) {
        targetLayerIndex = index
        grid.intGrid = gridData
        updateLayerImage(index)
        updateAnimatedPreview()
        setNeedsDisplay()
    }
}
