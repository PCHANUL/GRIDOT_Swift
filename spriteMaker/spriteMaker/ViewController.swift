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
        girdArray[0][0] = 1
        girdArray[1][1] = 1
        girdArray[2][2] = 1
        girdArray[3][3] = 1
        girdArray[4][4] = 1
        girdArray[5][5] = 1
        girdArray[6][6] = 1
        girdArray[7][7] = 1
        girdArray[8][8] = 1
        girdArray[9][9] = 1
        girdArray[10][10] = 1
        girdArray[11][11] = 1
        girdArray[12][12] = 1
        girdArray[13][13] = 1
        girdArray[14][14] = 1
        girdArray[15][15] = 1
        
        girdArray[15][10] = 1
        girdArray[15][11] = 1
        girdArray[15][12] = 1
        girdArray[15][13] = 1
        girdArray[15][14] = 1
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
    var onePixelLength: CGFloat
    
    var isEmptyPixel: Bool
    var isTouchesMoved: Bool
    var isTouchesEnded: Bool
    
    var initTouchPosition: CGPoint
    var moveTouchPosition: CGPoint
    
    var convertCanvasToImage: (_ isUpdate: Bool) -> ()
    
    var grid: Grid
    
    init(positionOfCanvas: CGFloat, lengthOfOneSide: CGFloat, numsOfPixels: Int, convertCanvasToImage: @escaping (_ isUpdate: Bool) -> ()) {
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
                self.convertCanvasToImage(true)
            } else {
                drawTouchGuideLine(context: context)
            }
        }
        drawSeletedPixels(context: context)
        drawGridLine(context: context)
    }
    
    // draw_method
    func drawGridLine(context: CGContext) {
        context.setStrokeColor(UIColor.white.cgColor)
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
        let widthOfPixel = Double(onePixelLength)
        
        for i in 0..<numsOfPixels {
            for j in 0..<numsOfPixels {
                if (grid.girdArray[i][j] == 1) {
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
    func getQuadrant(start: [Int], end: [Int]) -> [Int]{
        // start를 기준으로한 사분면
        return [(end[0] - start[0]).signum(), (end[1] - start[1]).signum()]
    }
    func addDiagonalPixels(context: CGContext) {
        // 가상의 상자를 만들고 비율에 따라서 중앙에 선을 긋는다
        let startPoint = transPosition(point: initTouchPosition)
        let endPoint = transPosition(point: moveTouchPosition)
        let quadrant = getQuadrant(start: startPoint, end: endPoint)
        
        print("--> start: ", startPoint)
        print("--> end: ", endPoint)
        
        // 긴 변을 짧은 변으로 나눈 몫이 하나의 계단이 된다
        let yLength = abs(startPoint[1] - endPoint[1]) + 1
        let xLength = abs(startPoint[0] - endPoint[0]) + 1
        let stairsLength = max(xLength, yLength) / min(xLength, yLength)
        
        for j in 0..<yLength {
            for i in 0..<stairsLength {
                let x = startPoint[0] + (i + j * stairsLength) * quadrant[0]
                let y = startPoint[1] + (j) * quadrant[1]
                grid.girdArray[y][x] = 1
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
        let initPositionX = CGFloat(pixelPosition[0]) * onePixelLength + halfPixel
        let initPositionY = CGFloat(pixelPosition[1]) * onePixelLength + halfPixel
        
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
        self.convertCanvasToImage(true)
        setNeedsDisplay()
        
    }
    
    // touch_method
    func findTouchPosition(touches: Set<UITouch>) -> CGPoint {
        guard var point = touches.first?.location(in: nil) else { return CGPoint() }
        point.x -= 22
        point.y = point.y - positionOfCanvas - 5
        return point
    }
    func transPosition(point: CGPoint) -> [Int]{
        let x = Int(point.x / onePixelLength)
        let y = Int(point.y / onePixelLength)
        return [x == 16 ? 15 : x, y == 16 ? 15 : y]
    }
    func selectPixel(pixelPosition: [Int]) {
        isEmptyPixel = grid.isEmpty(targetPos: pixelPosition)
        grid.updateGrid(targetPos: pixelPosition, isEmptyPixel: isEmptyPixel)
    }
}

class ViewController: UIViewController {
    
    var previewListViewController: PreviewListViewController!
    var canvas: Canvas!
        
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet var viewController: UIView!
    
    override func viewSafeAreaInsetsDidChange() {
        // 캔버스의 위치와 크기는 canvasView와 같다
        let margin: CGFloat = 20
        let lengthOfOneSide = (view.bounds.width - margin * 2)
        let positionOfCanvas = view.bounds.height - lengthOfOneSide - 20 - view.safeAreaInsets.bottom
        let numsOfPixels = 16
        
        canvas = Canvas(positionOfCanvas: positionOfCanvas, lengthOfOneSide: lengthOfOneSide, numsOfPixels: numsOfPixels, convertCanvasToImage: convertCanvasToImage)
        canvasView.addSubview(canvas)
        canvas.backgroundColor = .systemGray2
        canvas.frame = CGRect(x: 0, y: 0, width: lengthOfOneSide, height: lengthOfOneSide)
        
        convertCanvasToImage(isUpdate: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as? PreviewListViewController
        previewListViewController = destinationVC
    }
    
    public func convertCanvasToImage(isUpdate: Bool) {
        let oneSideLength = canvas.lengthOfOneSide
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: oneSideLength, height: oneSideLength))
        let image = renderer.image { context in
            guard let canvas = canvas else { return }
            canvas.drawSeletedPixels(context: context.cgContext)
        }
        if isUpdate {
            self.previewListViewController.viewModel.updateItem(at: 0, image: image)
        } else {
            self.previewListViewController.viewModel.addItem(image: image)
        }
        previewListViewController.previewCollectionView.reloadData()
    }
}



