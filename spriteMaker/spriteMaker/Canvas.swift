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
    
    var isTouchesMoved: Bool!
    var isTouchesEnded: Bool!
    var initTouchPosition: CGPoint!
    var moveTouchPosition: CGPoint!
    var targetIndex: Int = 0
    var selectedColor: UIColor!
 
    // tools
    var lineTool: LineTool!
    var eraserTool: EraserTool!
    
    init(_ lengthOfOneSide: CGFloat, _ numsOfPixels: Int, _ panelVC: PanelContainerViewController) {
        
        self.grid = Grid()
        
        self.lengthOfOneSide = lengthOfOneSide
        self.numsOfPixels = numsOfPixels
        self.onePixelLength = lengthOfOneSide / CGFloat(numsOfPixels)
        
        self.isTouchesMoved = false
        self.isTouchesEnded = false
        self.moveTouchPosition = CGPoint()
        self.initTouchPosition = CGPoint()
        
        self.panelVC = panelVC
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.lineTool = LineTool(self)
        self.eraserTool = EraserTool(self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // 초기 설정에서 선택된 색이 팔레트에서 선택되어 보이는 색과 다르다.
    // 선택된 색만 지우는 지우개의 확장 기능을 추가할때 색을 어떤 방식으로 선택할 수 있고, 선택된 색을 어디서 볼 수 있도록 만들어야 하는가?
    // [] 지우개로 처음 클릭하여 지운 색을 지울 수 있다. 선택된 색은 지우개 탭에서 볼 수 있다. 선택된 색은 팔레트에 적용되지 않는다.
    // 나중에 스포이드를 구현할 때 팔레트에서 선택되지 않은 색을 보여주어야 한다. 그래서 지금 팔레트 패널을 수정해서 선택되지 않은 색이 선택된 경우를 다루어야 한다.
    
//    override class func awakeFromNib() {
//        self.selectedColor = panelVC.colorPaletteVM!.currentColor.uicolor
//    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 도구마다 움직일때 호출되고, 움직인 후에 호출되기도 한다.
        // 선택된 도구가 무엇인지 확인하고 함수를 호출해주는 함수가 필요하다.
        
        drawSeletedPixels(context: context)
        if isTouchesMoved {
            if isTouchesEnded == false {
                switchToolsTouchesMoved(context)
            } else {
                switchToolsTouchesEnded(context)
                convertCanvasToImage(targetIndex)
                drawSeletedPixels(context: context)
                isTouchesEnded = false
                isTouchesMoved = false
            }
        }
        drawGridLine(context: context)
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
    
    // touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan")
        let position = findTouchPosition(touches: touches)
        let pixelPosition = transPosition(position)
        
        let halfPixel = onePixelLength / 2
        let initPositionX = CGFloat(pixelPosition["x"]!) * onePixelLength + halfPixel
        let initPositionY = CGFloat(pixelPosition["y"]!) * onePixelLength + halfPixel
        
        initTouchPosition = CGPoint(x: initPositionX, y: initPositionY)
        moveTouchPosition = position
        switchToolsTouchesBegan()
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesMoved")
        let movePosition = findTouchPosition(touches: touches)
        moveTouchPosition = CGPoint(x: movePosition.x - 20, y: movePosition.y - 20)
        isTouchesMoved = true
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesEnded")
        if isTouchesMoved { isTouchesEnded = true }
        convertCanvasToImage(targetIndex)
        setNeedsDisplay()
    }
    
    // touch canvas
    func findTouchPosition(touches: Set<UITouch>) -> CGPoint {
        guard var point = touches.first?.location(in: self) else { return CGPoint() }
        point.y = point.y - 5
        return point
    }
    
    func selectPixel(pixelPosition: [String: Int]) {
        guard let hex = selectedColor.hexa else { return }
        guard let x = pixelPosition["x"], let y = pixelPosition["y"] else { return }
        if grid.isColored(hex: hex) == false {
            grid.addColor(hex: hex, x: x, y: y)
        } else {
            grid.addLocation(hex: hex, x: x, y: y)
        }
    }
    
    func removePixel(pixelPosition: [String: Int]) {
        guard let hex = selectedColor.hexa else { return }
        guard let x = pixelPosition["x"], let y = pixelPosition["y"] else { return }
        if grid.isColored(hex: hex) {
            grid.removeLocation(hex: hex, x: x, y: y)
        }
    }
    
    func transPosition(_ point: CGPoint) -> [String: Int]{
        let x = Int(point.x / onePixelLength)
        let y = Int(point.y / onePixelLength)
        return ["x": x == 16 ? 15 : x, "y": y == 16 ? 15 : y]
    }
    
    // manage canvas
    func changeCanvas(index: Int, canvasData: String) {
        targetIndex = index
        // 캔버스를 바꿀경우 그리드를 데이터로 변환합니다.
        uploadCanvsDataToPreviewList()
        let canvasArray = stringToMatrix(canvasData)
        grid.changeGrid(newGrid: canvasArray)
        convertCanvasToImage(index)
        setNeedsDisplay()
    }
    
    func uploadCanvsDataToPreviewList() {
        guard let viewModel = self.panelVC.viewModel else { return }
        let imageCanvasData = matrixToString(grid: grid.gridLocations)
        let item = viewModel.item(at: targetIndex)
        let previewImage = PreviewImage(image: item.image, category: item.category, imageCanvasData: imageCanvasData)
        viewModel.updateItem(at: targetIndex, previewImage: previewImage)
    }
    
    func convertCanvasToImage(_ index: Int) {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: lengthOfOneSide, height: lengthOfOneSide))
        let image = renderer.image { context in
            drawSeletedPixels(context: context.cgContext)
        }
        guard let previewList = self.panelVC.viewModel else { return }
        let checkExist = previewList.checkExist(at: index)
        if checkExist {
            let category = previewList.item(at: index).category
            let imageCanvasData = matrixToString(grid: grid.gridLocations)
            let previewImage = PreviewImage(image: image, category: category, imageCanvasData: imageCanvasData)
            previewList.updateItem(at: index, previewImage: previewImage)
        } else {
            let previewImage = PreviewImage(image: image, category: "Default", imageCanvasData: "")
            previewList.initItem(previewImage: previewImage)
        }
        self.panelVC.previewImageToolBar.animatedPreviewViewModel.changeAnimatedPreview(isReset: false)
    }
}


