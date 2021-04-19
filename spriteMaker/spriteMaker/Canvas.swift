//
//  Canvas.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/04.
//

import UIKit

class Canvas: UIView {
    var lengthOfOneSide: CGFloat!
    var numsOfPixels: Int!
    var onePixelLength: CGFloat!
    
    var isEmptyPixel: Bool!
    var isTouchesMoved: Bool!
    var isTouchesEnded: Bool!
    
    var initTouchPosition: CGPoint!
    var moveTouchPosition: CGPoint!
    var targetIndex: Int = 0
    var selectedColor: UIColor = UIColor.lightGray
    var grid: Grid!
    
    var panelContainerViewController: PanelContainerViewController!
    
    init(lengthOfOneSide: CGFloat, numsOfPixels: Int, panelContainerViewController: PanelContainerViewController) {
        
        self.grid = Grid()
        
        self.lengthOfOneSide = lengthOfOneSide
        self.numsOfPixels = numsOfPixels
        self.onePixelLength = lengthOfOneSide / CGFloat(numsOfPixels)
        
        self.isEmptyPixel = false
        self.isTouchesMoved = false
        self.isTouchesEnded = false
        self.moveTouchPosition = CGPoint()
        self.initTouchPosition = CGPoint()
        
        self.panelContainerViewController = panelContainerViewController
        
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // draw
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        drawSeletedPixels(context: context)
        if isTouchesMoved {
            if isTouchesEnded {
                addDiagonalPixels(context: context)
                self.convertCanvasToImage(targetIndex)
                drawSeletedPixels(context: context)
            } else {
                drawTouchGuideLine(context: context)
            }
        }
        drawGridLine(context: context)
    }
    
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
    
    // draw_method
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
    
    func drawTouchGuideLine(context: CGContext) {
        // 터치가 시작된 곳에서 부터 움직인 곳까지 경로를 표시
        context.setStrokeColor(selectedColor.cgColor)
        context.setLineWidth(3)
        
        context.move(to: initTouchPosition)
        context.addLine(to: moveTouchPosition)
        context.strokePath()
        
        context.setFillColor(selectedColor.cgColor)
        context.addArc(center: moveTouchPosition, radius: onePixelLength / 2, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        context.fillPath()
    }
    
    func getQuadrant(start: [String: Int], end: [String: Int]) -> [String: Int]{
        // start를 기준으로한 사분면
        let x = (end["x"]! - start["x"]!).signum()
        let y = (end["y"]! - start["y"]!).signum()
        return ["x": x, "y": y]
    }
    
    func addDiagonalPixels(context: CGContext) {
        let startPoint = transPosition(point: initTouchPosition)
        let endPoint = transPosition(point: moveTouchPosition)
        let quadrant = getQuadrant(start: startPoint, end: endPoint)
        
        print("--> start: ", startPoint)
        print("--> end: ", endPoint)
        
        // 긴 변을 짧은 변으로 나눈 몫이 하나의 계단이 된다
        let yLength = abs(startPoint["y"]! - endPoint["y"]!) + 1
        let xLength = abs(startPoint["x"]! - endPoint["x"]!) + 1
        let stairsLength = max(xLength, yLength) / min(xLength, yLength)
        
        // x, y길이를 비교하여 대각선을 그리는 방향을 설정
        let targetSide = xLength > yLength ? yLength : xLength
        let posArray = xLength > yLength ? ["x", "y"] : ["y", "x"]
        
        // 한 계단의 길이가
        for j in 0..<targetSide {
            for i in 0..<stairsLength {
                let targetPos = [
                    posArray[0]: startPoint[posArray[0]]! + (i + j * stairsLength) * quadrant[posArray[0]]!,
                    posArray[1]: startPoint[posArray[1]]! + (j) * quadrant[posArray[1]]!
                ]
                grid.addLocation(hex: selectedColor.hexa!, x: targetPos["x"]!, y: targetPos["y"]!)
            }
        }
        isTouchesEnded = false
        isTouchesMoved = false
        context.strokePath()
    }

    
    // touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan")
        let position = findTouchPosition(touches: touches)
        let pixelPosition = transPosition(point: position)
        
        let halfPixel = onePixelLength / 2
        let initPositionX = CGFloat(pixelPosition["x"]!) * onePixelLength + halfPixel
        let initPositionY = CGFloat(pixelPosition["y"]!) * onePixelLength + halfPixel
        
        initTouchPosition = CGPoint(x: initPositionX, y: initPositionY)
        moveTouchPosition = position
        
        selectPixel(pixelPosition: pixelPosition)
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
        isEmptyPixel = false
        if isTouchesMoved {
            isTouchesEnded = true
        }
        // render canvas image preview
        self.convertCanvasToImage(targetIndex)
        setNeedsDisplay()
    }
    
    // touch_method
    func findTouchPosition(touches: Set<UITouch>) -> CGPoint {
        guard var point = touches.first?.location(in: self) else { return CGPoint() }
        point.y = point.y - 5
        return point
    }
    
    func transPosition(point: CGPoint) -> [String: Int]{
        let x = Int(point.x / onePixelLength)
        let y = Int(point.y / onePixelLength)
        return ["x": x == 16 ? 15 : x, "y": y == 16 ? 15 : y]
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
    
    // change canvas method
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
        guard let viewModel = self.panelContainerViewController.viewModel else { return }
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
        guard let previewList = self.panelContainerViewController.viewModel else { return }
        let checkExist = previewList.checkExist(at: index)
        print(checkExist)
        if checkExist {
            let category = previewList.item(at: index).category
            let imageCanvasData = matrixToString(grid: grid.gridLocations)
            let previewImage = PreviewImage(image: image, category: category, imageCanvasData: imageCanvasData)
            previewList.updateItem(at: index, previewImage: previewImage)
        } else {
            let previewImage = PreviewImage(image: image, category: "Default", imageCanvasData: "")
            previewList.initItem(previewImage: previewImage)
        }
        self.panelContainerViewController.previewImageToolBar.animatedPreviewViewModel.changeAnimatedPreview(isReset: false)
    }
}




