//
//  Canvas.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/04.
//

import UIKit
import QuartzCore

struct Tools {
    
}

class Canvas: UIView {
    var grid: Grid!
    var panelVC: PanelContainerViewController!
 
    var numsOfPixels: Int!
    var lengthOfOneSide: CGFloat!
    var onePixelLength: CGFloat!
    
    var isTouchesBegan: Bool!
    var isTouchesMoved: Bool!
    var isTouchesEnded: Bool!
    var initTouchPosition: CGPoint!
    var moveTouchPosition: CGPoint!
    var targetIndex: Int = 0
    var selectedColor: UIColor!
    var selectedDrawingMode: String!
 
    // tools
    var lineTool: LineTool!
    var squareTool: SquareTool!
    var eraserTool: EraserTool!
    var pencilTool: PencilTool!
    var pickerTool: PickerTool!
    var selectSquareTool: SelectSquareTool!
    var magicTool: MagicTool!
    var paintTool: PaintTool!
    var undoTool: UndoTool!
    
    var timeMachineVM: TimeMachineViewModel!
    var timerTouchesEnded: Timer?
    
    init(_ lengthOfOneSide: CGFloat, _ numsOfPixels: Int, _ panelVC: PanelContainerViewController) {
        self.grid = Grid()
        self.selectedDrawingMode = "pen"
        self.lengthOfOneSide = lengthOfOneSide
        self.numsOfPixels = numsOfPixels
        self.onePixelLength = lengthOfOneSide / CGFloat(numsOfPixels)
        self.isTouchesBegan = false
        self.isTouchesMoved = false
        self.isTouchesEnded = false
        self.moveTouchPosition = CGPoint()
        self.initTouchPosition = CGPoint()
        self.panelVC = panelVC
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        self.lineTool = LineTool(self)
        self.squareTool = SquareTool(self)
        self.eraserTool = EraserTool(self)
        self.pencilTool = PencilTool(self)
        self.pickerTool = PickerTool(self)
        self.selectSquareTool = SelectSquareTool(self)
        self.magicTool = MagicTool(self)
        self.paintTool = PaintTool(self)
        self.undoTool = UndoTool(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        drawLayers(context)
        if isTouchesMoved {
            isTouchesBegan = false
            if isTouchesEnded {
                switchToolsTouchesEnded(context)
                drawLayers(context)
                updateViewModelImages(targetIndex, isInit: false)
                drawGridLine(context)
                isTouchesEnded = false
                isTouchesMoved = false
                isTouchesBegan = true
            } else {
                drawGridLine(context)
                switchToolsTouchesMoved(context)
            }
        } else {
            drawGridLine(context)
            switchToolsNoneTouches(context)
        }
        if isTouchesBegan {
            switchToolsTouchesBeganOnDraw(context)
        }
    }
    
    // UIImage 뒤집기
    func flipImageVertically(originalImage: UIImage) -> UIImage {
        let tempImageView: UIImageView = UIImageView(image: originalImage)
        UIGraphicsBeginImageContext(tempImageView.frame.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        let flipVertical: CGAffineTransform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: tempImageView.frame.size.height)

        context.concatenate(flipVertical)
        tempImageView.tintColor = UIColor.white
        tempImageView.layer.render(in: context)

        let flippedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return flippedImage
    }
    
    // layer의 순서대로 image와 gird데이터를 그린다.
    func drawLayers(_ context: CGContext) {
        let layerImages = panelVC.layerVM.getVisibleLayerImages()
        let selectedLayerIndex = panelVC.layerVM.selectedLayerIndex
        
        for idx in (0..<layerImages.count).reversed() {
            guard layerImages[idx] != nil else { continue }
            if (idx != selectedLayerIndex) {
                let flipedImage = flipImageVertically(originalImage: layerImages[idx]!)
                context.draw(flipedImage.cgImage!, in: CGRect(x: 0, y: 0, width: self.lengthOfOneSide, height: self.lengthOfOneSide))
            } else {
                drawSeletedPixels(context)
            }
        }
    }
    
    // draw canvas
    func drawSeletedPixels(_ context: CGContext) {
        context.setLineWidth(0)
        let widthOfPixel = Double(onePixelLength)
        for color in grid.colors {
            let locations = grid.getLocations(hex: color)
            for x in locations.keys {
                for y in locations[x]! {
                    context.setFillColor(color.uicolor!.cgColor)
                    let xlocation = Double(x) * widthOfPixel
                    let ylocation = Double(y) * widthOfPixel
                    let rectangle = CGRect(x: xlocation, y: ylocation, width: widthOfPixel, height: widthOfPixel)
                    context.addRect(rectangle)
                    context.drawPath(using: .fillStroke)
                }
            }
        }
        context.strokePath()
    }
    
    // 캔버스의 그리드 선을 그린다
    func drawGridLine(_ context: CGContext) {
        context.setStrokeColor(UIColor.gray.cgColor)
        context.setLineWidth(0.5)
        
        for i in 1...Int(numsOfPixels - 1) {
            let gridWidth = onePixelLength * CGFloat(i)
            context.move(to: CGPoint(x: gridWidth, y: 0))
            context.addLine(to: CGPoint(x: gridWidth, y: lengthOfOneSide))
            context.move(to: CGPoint(x: 0, y: gridWidth))
            context.addLine(to: CGPoint(x: lengthOfOneSide, y: gridWidth))
        }
        context.strokePath()
    }
    
    func alertIsHiddenLayer() {
        let alert = UIAlertController(title: "", message: "현재 선택된 레이어가 숨겨진 상태입니다\n해제하시겠습니까?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: hiddenAlertHandler))
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
        panelVC.present(alert, animated: true)
    }
    
    func hiddenAlertHandler(_ alert: UIAlertAction) -> Void {
        panelVC.layerVM.toggleVisibilitySelectedLayer()
    }
    
    // 터치 시작
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (panelVC.layerVM.isSelectedHiddenLayer) {
            alertIsHiddenLayer()
        } else {
            var position = findTouchPosition(touches: touches)
            position.x -= 10
            position.y -= 10
            let pixelPosition = transPosition(position)
            let halfPixel = onePixelLength / 2
            let initPositionX = CGFloat(pixelPosition["x"]!) * onePixelLength + halfPixel
            let initPositionY = CGFloat(pixelPosition["y"]!) * onePixelLength + halfPixel
            
            initTouchPosition = CGPoint(x: initPositionX, y: initPositionY)
            moveTouchPosition = CGPoint(x: initPositionX - 20, y: initPositionY - 20)
            switchToolsTouchesBegan(transPosition(initTouchPosition))
            isTouchesBegan = true
            timerTouchesEnded?.invalidate()
            setNeedsDisplay()
        }
    }
    
    // 터치 움직임
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let movePosition = findTouchPosition(touches: touches)
        moveTouchPosition = CGPoint(x: movePosition.x - 20, y: movePosition.y - 20)
        isTouchesMoved = true
        setNeedsDisplay()
    }
    
    // 터치 마침
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isTouchesMoved {
            isTouchesEnded = true
        }
        if (isTouchesBegan && panelVC.drawingToolVM.selectedTool.name == "Pencil") {
            timerTouchesEnded = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false)
            { (Timer) in
                self.isTouchesBegan = false
                self.setNeedsDisplay()
            }
        }
        updateViewModelImages(targetIndex, isInit: false)
        setNeedsDisplay()
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
        guard let hex = selectedColor.hexa else { return }
        guard let x = pixelPosition["x"], let y = pixelPosition["y"] else { return }
        if grid.isColored(hex: hex) {
            grid.removeLocationIfSelected(hex: hex, x: x, y: y)
        }
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

// PreviewVM, LayerVM 관련 함수들
extension Canvas {
    // canvas를 UIImage로 렌더링
    func renderCanvasImage(isPreview: Bool) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: lengthOfOneSide, height: lengthOfOneSide))
        return renderer.image { context in
            if isPreview {
                drawLayers(context.cgContext)
            } else {
                drawSeletedPixels(context.cgContext)
            }
        }
    }
    
    // PreviewVM의 image 변경
    func updatePreviewVMImage(index: Int, isInit: Bool) {
        guard let previewList = self.panelVC.previewVM else { return }
        let image = renderCanvasImage(isPreview: true)
        if isInit {
            previewList.addEmptyItem(isInit: true)
        } else if previewList.checkExist(at: index) {
            let category = previewList.item(at: index).category
            let imageCanvasData = matrixToString(grid: grid.gridLocations)
            let previewImage = PreviewImage(image: image, category: category, imageCanvasData: imageCanvasData)
            previewList.updateItem(at: index, previewImage: previewImage)
        }
    }
    
    // LayerVM의 image 변경
    func updateLayerVMImage(index: Int, isInit: Bool) {
        guard let layerList = self.panelVC.layerVM else { return }
        let image = renderCanvasImage(isPreview: false)
        if isInit {
            layerList.addEmptyItem(isInit: true)
        } else if layerList.isExistLayer(index: index) {
            let imageCanvasData = matrixToString(grid: grid.gridLocations)
            layerList.updateSelectedLayer(layerImage: image, gridData: imageCanvasData)
        }
    }
    
    // 캔버스 이미지를 렌더링하여 previewVM과 layerVM을 업데이트
    func updateViewModelImages(_ index: Int, isInit: Bool) {
        let previewIndex = self.panelVC.previewImageToolBar.previewVM.selectedPreview
        updatePreviewVMImage(index: previewIndex, isInit: isInit)
        updateLayerVMImage(index: index, isInit: isInit)
        self.panelVC.previewImageToolBar.animatedPreviewVM.changeAnimatedPreview(isReset: isInit)
    }
    
    // 그리드 2차원 배열을 변환하여 previewVM에 할당
    func uploadGridDataToLayerList() {
        guard let viewModel = self.panelVC.layerVM else { return }
        let convertedGridData = matrixToString(grid: grid.gridLocations)
        guard let item = viewModel.getLayer(index: targetIndex) else { return }
        let image = item.layerImage
        viewModel.updateSelectedLayer(layerImage: image, gridData: convertedGridData)
    }
    
    // 캔버스를 바꿀경우 그리드를 데이터로 변환합니다.
    func changeGrid(index: Int, gridData: String) {
        targetIndex = index
        uploadGridDataToLayerList()
        let canvasArray = stringToMatrix(gridData)
        grid.changeGrid(newGrid: canvasArray)
        updateViewModelImages(index, isInit: false)
        setNeedsDisplay()
    }
}

// animation -> [preview] -> [layer]
// layer가 grid 데이터를 가지고 있다.
