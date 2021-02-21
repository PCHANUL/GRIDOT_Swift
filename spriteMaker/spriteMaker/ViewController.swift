//
//  ViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/02/19.
//

import UIKit


class Grid {
    var girdArray: [[Int]] = []
    var count: Int = 0
    
    init(numsOfPixels: Int) {
        self.createGrid(numsOfPixels: numsOfPixels)
    }
    
    func isEmpty(targetPos: [Int]) -> Bool{
        return girdArray[targetPos[1]][targetPos[0]] == 0
    }
    
    func createGrid(numsOfPixels: Int) {
        girdArray = Array(repeating: Array(repeating: 0, count: numsOfPixels), count: numsOfPixels)
    }
    
    func updateGrid(targetPos: [Int], isEmptyPixel: Bool) {
        self.girdArray[targetPos[1]][targetPos[0]] = isEmptyPixel ? 1 : 0
        count += isEmptyPixel ? 1 : -1
    }
}

class Canvas: UIView {
    var positionOfCanvas: CGFloat
    var lengthOfOneSide: CGFloat
    var numsOfPixels: Int
    
    var isEmptyPixel: Bool
    var isTouchesMoved: Bool
    var isTouchesEnded: Bool
    
    var initTouchPosition: CGPoint
    var moveTouchPosition: CGPoint
    
    var grid: Grid
    
    init(positionOfCanvas: CGFloat, lengthOfOneSide: CGFloat, numsOfPixels: Int) {
        self.positionOfCanvas = positionOfCanvas
        self.lengthOfOneSide = lengthOfOneSide
        self.numsOfPixels = numsOfPixels
        self.isEmptyPixel = false
        self.isTouchesMoved = false
        self.isTouchesEnded = false
        
        self.moveTouchPosition = CGPoint()
        self.initTouchPosition = CGPoint()
        
        grid = Grid(numsOfPixels: numsOfPixels)
        
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawGridLine(context: CGContext) {
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(0.5)
        
        let term = lengthOfOneSide / CGFloat(numsOfPixels)
        for i in 1...Int(numsOfPixels - 1) {
            let gridWidth = term * CGFloat(i)
            context.move(to: CGPoint(x: gridWidth, y: 0))
            context.addLine(to: CGPoint(x: gridWidth, y: lengthOfOneSide))
            context.move(to: CGPoint(x: 0, y: gridWidth))
            context.addLine(to: CGPoint(x: lengthOfOneSide, y: gridWidth))
        }
        context.strokePath()
    }
    
    func drawSeletedPixels(context: CGContext) {
        // grid.gridArray를 참조하여 해당 칸을 색칠
        context.setFillColor(UIColor.yellow.cgColor)
        let widthOfPixel = Double(Int(lengthOfOneSide) / numsOfPixels)
        
        for i in 0..<numsOfPixels {
            for j in 0..<numsOfPixels {
                if (grid.girdArray[i][j] == 1) {
                    let xIndex = Double(j)
                    let yIndex = Double(i)
                    let x = xIndex * Double(widthOfPixel) + xIndex * 0.5
                    let y = yIndex * Double(widthOfPixel) + yIndex * 0.5
                    let rectangle = CGRect(x: x, y: y, width: widthOfPixel, height: widthOfPixel)
                    
                    context.addRect(rectangle)
                    context.drawPath(using: .fillStroke)
                }
            }
        }
        context.strokePath()
    }
    
    func drawTouchGuideLine(context: CGContext) {
        // 터치가 시작된 곳에서 부터 움직인 곳까지 경로를 표시
        context.setStrokeColor(UIColor.yellow.cgColor)
        context.setLineWidth(3)
        
        context.move(to: initTouchPosition)
        context.addLine(to: moveTouchPosition)
        context.strokePath()
    }
    
    func drawDiagonal(context: CGContext) {
        // 가상의 상자를 만들고 비율에 따라서 중앙에 선을 긋습니다.
        let startPoint = transPosition(point: initTouchPosition)
        let endPoint = transPosition(point: moveTouchPosition)
        
        print("--> start: ", startPoint)
        print("--> end: ", endPoint)
        
        
        
        for i in startPoint[1]...endPoint[1] {
            for j in startPoint[0]...endPoint[0] {
                grid.girdArray[i][j] = 1
            }
        }
        isTouchesEnded = false
        context.strokePath()
    }
    
    func transPosition(point: CGPoint) -> [Int]{
        let pixelLength = Int(lengthOfOneSide) / numsOfPixels
        let x = Int(point.x) / pixelLength
        let y = Int(point.y) / pixelLength
        return [x == 16 ? 15 : x, y == 16 ? 15 : y]
    }
    
    func findTouchPosition(touches: Set<UITouch>) -> CGPoint {
        guard var point = touches.first?.location(in: nil) else { return CGPoint() }
        point.x -= 20
        point.y = point.y - positionOfCanvas
        return point
    }
    
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        drawGridLine(context: context)
        if isTouchesMoved {
            drawTouchGuideLine(context: context)
        } else if isTouchesEnded {
            // 터치 가이드 라인에 따라서 픽셀을 선택
            drawDiagonal(context: context)
        }
        drawSeletedPixels(context: context)
        
    }
    
    func selectPixel(pixelPosition: [Int]) {
        isEmptyPixel = grid.isEmpty(targetPos: pixelPosition)
        grid.updateGrid(targetPos: pixelPosition, isEmptyPixel: isEmptyPixel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let position = findTouchPosition(touches: touches)
        let pixelPosition = transPosition(point: position)
        initTouchPosition = position
        moveTouchPosition = position
        
        selectPixel(pixelPosition: pixelPosition)
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouchesMoved = true
        moveTouchPosition = findTouchPosition(touches: touches)
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetTouchStatus()
        isTouchesEnded = true
        setNeedsDisplay()
    }
    
    func resetTouchStatus() {
        isEmptyPixel = false
        isTouchesMoved = false
    }
}

class ViewController: UIViewController {
        
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet var viewController: UIView!
    
    override func viewSafeAreaInsetsDidChange() {
        // 캔버스의 위치와 크기는 canvasView와 같다
        let margin: CGFloat = 20
        let lengthOfOneSide = (view.bounds.width - margin * 2)
        let positionOfCanvas = view.bounds.height - lengthOfOneSide - 20 - view.safeAreaInsets.bottom
        let numsOfPixels = 16
        
        let canvas = Canvas(positionOfCanvas: positionOfCanvas, lengthOfOneSide: lengthOfOneSide, numsOfPixels: numsOfPixels)
        canvasView.addSubview(canvas)
        canvas.backgroundColor = .systemGray2
        canvas.frame = CGRect(x: 0, y: 0, width: lengthOfOneSide, height: lengthOfOneSide)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

