//
//  ViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/02/19.
//

import UIKit

class Canvas: UIView {
    
    var positionOfCanvas: CGFloat
    var lengthOfOneSide: CGFloat
    
    init(positionOfCanvas: CGFloat, lengthOfOneSide: CGFloat) {
        self.positionOfCanvas = positionOfCanvas
        self.lengthOfOneSide = lengthOfOneSide
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawGridLine(context: CGContext, numsOfRows: CGFloat) {
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(0.5)
        
        let term = lengthOfOneSide / numsOfRows
        for i in 1...Int(numsOfRows) {
            let gridWidth = term * CGFloat(i)
            context.move(to: CGPoint(x: gridWidth, y: 0))
            context.addLine(to: CGPoint(x: gridWidth, y: lengthOfOneSide))
            context.move(to: CGPoint(x: 0, y: gridWidth))
            context.addLine(to: CGPoint(x: lengthOfOneSide, y: gridWidth))
        }
        
    }
    
    func findPosition(touches: Set<UITouch>) -> CGPoint {
        guard var point = touches.first?.location(in: nil) else { return CGPoint() }
        point.x -= 20
        point.y = point.y - positionOfCanvas
        return point
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        drawGridLine(context: context, numsOfRows: 8)
        
        context.strokePath()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let position = findPosition(touches: touches)
        print(position)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        setNeedsDisplay()
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
        
        let canvas = Canvas(positionOfCanvas: positionOfCanvas, lengthOfOneSide: lengthOfOneSide)
        canvasView.addSubview(canvas)
        canvas.backgroundColor = .systemGray2
        canvas.frame = CGRect(x: 0, y: 0, width: lengthOfOneSide, height: lengthOfOneSide)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

