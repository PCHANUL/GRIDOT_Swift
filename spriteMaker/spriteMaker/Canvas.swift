//
//  Canvas.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/04.
//

import UIKit

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
 
    // tools
    var lineTool: LineTool!
    var squareTool: SquareTool!
    var eraserTool: EraserTool!
    var pencilTool: PencilTool!
    var pickerTool: PickerTool!
    var paintTool: PaintTool!
    var undoTool: UndoTool!
    
    var timerTouchesEnded: Timer?
    
    init(_ lengthOfOneSide: CGFloat, _ numsOfPixels: Int, _ panelVC: PanelContainerViewController) {
        
        self.grid = Grid()
        
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
        self.paintTool = PaintTool(self)
        self.undoTool = UndoTool(self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        drawSeletedPixels(context: context)
        if isTouchesMoved {
            isTouchesBegan = false
            if isTouchesEnded == false {
                drawGridLine(context: context)
                switchToolsTouchesMoved(context)
            } else {
                switchToolsTouchesEnded(context)
                updateViewModelImages(targetIndex, isInit: false)
                drawSeletedPixels(context: context)
                drawGridLine(context: context)
                isTouchesEnded = false
                isTouchesMoved = false
            }
        } else {
            drawGridLine(context: context)
        }
        if isTouchesBegan {
            switchToolsTouchesBeganOnDraw(context)
        }
    }
    
    // draw canvas
    func drawSeletedPixels(context: CGContext) {
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
    func drawGridLine(context: CGContext) {
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
    
    // 터치 시작
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let position = findTouchPosition(touches: touches)
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
        if isTouchesBegan {
            timerTouchesEnded = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false)
            { (Timer) in
                self.isTouchesBegan = false
                self.setNeedsDisplay()
            }
        }
        updateViewModelImages(targetIndex, isInit: false)
        setNeedsDisplay()
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

// todo
// [] updateLayerVMImage 함수 작성
// [] 렌더링된 이미지를 canvas에 띄우기
// []

// PreviewVM, LayerVM 관련 함수들
extension Canvas {
    
    // canvas를 UIImage로 렌더링
    func renderCanvasImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: lengthOfOneSide, height: lengthOfOneSide))
        return renderer.image { context in
            drawSeletedPixels(context: context.cgContext)
        }
    }
    
    // PreviewVM의 image 변경
    func updatePreviewVMImage(index: Int, image: UIImage) {
        guard let previewList = self.panelVC.previewVM else { return }
        if previewList.checkExist(at: index) {
            let category = previewList.item(at: index).category
            let imageCanvasData = matrixToString(grid: grid.gridLocations)
            let previewImage = PreviewImage(image: image, category: category, imageCanvasData: imageCanvasData)
            previewList.updateItem(at: index, previewImage: previewImage)
        } else {
            let previewImage = PreviewImage(image: image, category: "Default", imageCanvasData: "")
            previewList.initItem(previewImage: previewImage)
        }
    }
    
    // LayerVM의 image 변경
    func updateLayerVMImage(index: Int, image: UIImage) {
        guard let layerList = self.panelVC.layerVM else { return }
        if layerList.isExistLayer(index: index) {
            return
        } else {
            let item = CompositionLayer(Layers: [ Layer(layerImage: image, gridData: "") ])
            layerList.initItem(comLayer: item)
        }
        
    }
    
    // 캔버스 이미지를 렌더링하여 previewVM과 layerVM을 업데이트
    func updateViewModelImages(_ index: Int, isInit: Bool) {
        let image = renderCanvasImage()
        updatePreviewVMImage(index: index, image: image)
        updateLayerVMImage(index: index, image: image)
        self.panelVC.previewImageToolBar.animatedPreviewVM.changeAnimatedPreview(isReset: isInit)
    }
    
    // 그리드 2차원 배열을 변환하여 previewVM에 할당
    func uploadGridDataToPreviewList() {
        guard let viewModel = self.panelVC.previewVM else { return }
        let imageCanvasData = matrixToString(grid: grid.gridLocations)
        let item = viewModel.item(at: targetIndex)
        let previewImage = PreviewImage(image: item.image, category: item.category, imageCanvasData: imageCanvasData)
        viewModel.updateItem(at: targetIndex, previewImage: previewImage)
    }
    
    // 캔버스를 바꿀경우 그리드를 데이터로 변환합니다.
    func changeCanvas(index: Int, canvasData: String) {
        targetIndex = index
        uploadGridDataToPreviewList()
        let canvasArray = stringToMatrix(canvasData)
        grid.changeGrid(newGrid: canvasArray)
        updateViewModelImages(index, isInit: false)
        setNeedsDisplay()
    }
}


// undo 이전의 수정사항으로 뒤돌린다.
// 구현 방법
// 1. 프레임 별로 각자 수정사항을 가지고 있는다.
//      - previewImage struct에 스택으로 쌓는다.
// 2. 프레임 수정 사항까지 저장된다.
//      - 특정 함수가 실행될때 현재 상황을 저장한다.
//      - 현재 상황을 저장하는 것은 프레임, 캔버스

// 저장해야하는 상황의 덩어리를 정해야 한다.
// touchEnd(픽셀을 지우거나 생성하는 툴), 프레임을 제거, 생성, 그룹변경, 순서변경, selectedIndex는 저장만
// canvas의 matrixToString, PreviewListViewModel의 item
// 타임머신 모델이 필요함



