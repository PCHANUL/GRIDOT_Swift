//
//  ViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/02/19.
//

import UIKit


class Grid {
    private var gridArray: [[Int]] = []
    var count: Int = 0
    
    init(numsOfPixels: Int) {
        self.createGrid(numsOfPixels: numsOfPixels)
    }
    
    func isEmpty(x: Int, y: Int) -> Bool {
        return gridArray[y][x] == 0
    }
    
    func createGrid(numsOfPixels: Int) {
        gridArray = Array(repeating: Array(repeating: 0, count: numsOfPixels), count: numsOfPixels)
    }
    
    func readGrid() -> [[Int]] {
        return gridArray
    }
    
    func updateGrid(targetPos: [String: Int], isEmptyPixel: Bool) {
        self.gridArray[targetPos["y"]!][targetPos["x"]!] = isEmptyPixel ? 1 : 0
        count += isEmptyPixel ? 1 : -1
    }
    
    func changeGrid(newGrid: [[Int]]) {
        self.gridArray = newGrid
    }
}

class Canvas: UIView {
    var positionOfCanvas: CGFloat
    var lengthOfOneSide: CGFloat
    var numsOfPixels: Int
    var onePixelLength: CGFloat
    
    var isEmptyPixel: Bool
    var isTouchesMoved: Bool
    var isTouchesEnded: Bool
    
    var initTouchPosition: CGPoint
    var moveTouchPosition: CGPoint
    
    var convertCanvasToImage: (_ index: Int) -> ()
    var targetIndex: Int = 0
    
    var grid: Grid
    
    init(positionOfCanvas: CGFloat, lengthOfOneSide: CGFloat, numsOfPixels: Int, convertCanvasToImage: @escaping (_ index: Int) -> ()) {
        self.positionOfCanvas = positionOfCanvas
        self.lengthOfOneSide = lengthOfOneSide
        self.numsOfPixels = numsOfPixels
        self.onePixelLength = lengthOfOneSide / CGFloat(numsOfPixels)
        
        self.isEmptyPixel = false
        self.isTouchesMoved = false
        self.isTouchesEnded = false
        self.moveTouchPosition = CGPoint()
        self.initTouchPosition = CGPoint()
        
        self.convertCanvasToImage = convertCanvasToImage
        
        grid = Grid(numsOfPixels: numsOfPixels)
        
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // draw
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        if isTouchesMoved {
            if isTouchesEnded {
                addDiagonalPixels(context: context)
                self.convertCanvasToImage(targetIndex)
            } else {
                drawTouchGuideLine(context: context)
            }
        }
        drawSeletedPixels(context: context)
        drawGridLine(context: context)
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
    
    func drawSeletedPixels(context: CGContext) {
        // grid.gridArray를 참조하여 해당 칸을 색칠
        context.setStrokeColor(UIColor.yellow.cgColor)
        context.setFillColor(UIColor.yellow.cgColor)
        context.setLineWidth(0)
        let widthOfPixel = Double(onePixelLength)
        
        for i in 0..<numsOfPixels {
            for j in 0..<numsOfPixels {
                if (grid.isEmpty(x: j, y: i) == false) {
                    let xIndex = Double(j)
                    let yIndex = Double(i)
                    let x = xIndex * widthOfPixel
                    let y = yIndex * widthOfPixel
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
        
        context.setFillColor(UIColor.yellow.cgColor)
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
        // 가상의 상자를 만들고 비율에 따라서 중앙에 선을 긋는다
        let startPoint = transPosition(point: initTouchPosition)
        let endPoint = transPosition(point: moveTouchPosition)
        let quadrant = getQuadrant(start: startPoint, end: endPoint)
        
        print("--> start: ", startPoint)
        print("--> end: ", endPoint)
        
        // 긴 변을 짧은 변으로 나눈 몫이 하나의 계단이 된다
        let yLength = abs(startPoint["y"]! - endPoint["y"]!) + 1
        let xLength = abs(startPoint["x"]! - endPoint["x"]!) + 1
        let stairsLength = max(xLength, yLength) / min(xLength, yLength)
        
        for j in 0..<yLength {
            for i in 0..<stairsLength {
                let targetPos = [
                    "x": startPoint["x"]! + (i + j * stairsLength) * quadrant["x"]!,
                    "y": startPoint["y"]! + (j) * quadrant["y"]!
                ]
                grid.updateGrid(targetPos: targetPos, isEmptyPixel: true)
            }
        }
        
        isTouchesEnded = false
        isTouchesMoved = false
        context.strokePath()
    }
    
    
    // touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // [] 더블클릭시 도형툴 활성화
        
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
        let movePosition = findTouchPosition(touches: touches)
        moveTouchPosition = CGPoint(x: movePosition.x - 20, y: movePosition.y - 20)
        isTouchesMoved = true
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
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
        guard var point = touches.first?.location(in: nil) else { return CGPoint() }
        point.x -= 22
        point.y = point.y - positionOfCanvas - 5
        return point
    }
    
    func transPosition(point: CGPoint) -> [String: Int]{
        let x = Int(point.x / onePixelLength)
        let y = Int(point.y / onePixelLength)
        return ["x": x == 16 ? 15 : x, "y": y == 16 ? 15 : y]
    }
    
    func selectPixel(pixelPosition: [String: Int]) {
        isEmptyPixel = grid.isEmpty(x: pixelPosition["x"]!, y: pixelPosition["y"]!)
        grid.updateGrid(targetPos: pixelPosition, isEmptyPixel: isEmptyPixel)
    }
    
    // change canvas method
    func changeCanvas(index: Int, canvasData: String) {
        let canvasArray = stringToMatrix(string: canvasData)
        grid.changeGrid(newGrid: canvasArray)
        targetIndex = index
        convertCanvasToImage(index)
        setNeedsDisplay()
    }
}

class ViewController: UIViewController {
    
    var previewListViewController: PreviewListViewController!
    var canvas: Canvas!
        
    @IBOutlet var viewController: UIView!
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var previewList: UIView!
    @IBOutlet weak var toolView: UIView!
    
    override func viewSafeAreaInsetsDidChange() {
        // 캔버스의 위치와 크기는 canvasView와 같다
        let lengthOfOneSide = view.bounds.width * 0.9
        let positionOfCanvas = view.bounds.height - lengthOfOneSide - 20 - view.safeAreaInsets.bottom
        let numsOfPixels = 16
        
        canvas = Canvas(positionOfCanvas: positionOfCanvas, lengthOfOneSide: lengthOfOneSide, numsOfPixels: numsOfPixels, convertCanvasToImage: convertCanvasToImage)
        canvasView.addSubview(canvas)
        canvas.backgroundColor = .darkGray
        canvas.frame = CGRect(x: 0, y: 0, width: lengthOfOneSide, height: lengthOfOneSide)
        
        convertCanvasToImage(0)
        
        previewListViewController.canvas = canvas
        previewListViewController.previewListRect = toolView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as? PreviewListViewController
        previewListViewController = destinationVC
    }
    
    public func convertCanvasToImage(_ index: Int) {
        let oneSideLength = canvas.lengthOfOneSide
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: oneSideLength, height: oneSideLength))
        let image = renderer.image { context in
            guard let canvas = canvas else { return }
            canvas.drawSeletedPixels(context: context.cgContext)
        }
        
        let checkExist = self.previewListViewController.viewModel.checkExist(at: index)
        let imageCanvasData = matrixToString(matrix: canvas.grid.readGrid())
        
        if checkExist {
            self.previewListViewController.viewModel.updateItem(at: index, image: image, item: imageCanvasData)
        } else {
            self.previewListViewController.viewModel.addItem(image: image, item: imageCanvasData)
        }
        previewListViewController.changeAnimatedPreview()
    }
}

func matrixToString(matrix: [[Int]]) -> String {
    var result: String = ""
    for i in 0..<matrix.count {
        for j in 0..<matrix[i].count {
            result = result + String(matrix[i][j])
        }
        result = result + " "
    }
    return result
}

func stringToMatrix(string: String) -> [[Int]] {
    let splited = string.split(separator: " ")
    return splited.map { Substring in
        Substring.digits
    }
}

extension StringProtocol  {
    var digits: [Int] { compactMap(\.wholeNumberValue) }
}





