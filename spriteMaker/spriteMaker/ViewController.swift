//
//  ViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/02/19.
//

import UIKit

class ViewController: UIViewController {
    
//    var previewListViewController: PreviewListViewController!
    var toolBoxViewController: ToolBoxViewController!
    var canvas: Canvas!
        
    @IBOutlet var viewController: UIView!
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var toolView: UIView!
    
    override func viewSafeAreaInsetsDidChange() {
        // 캔버스의 위치와 크기는 canvasView와 같다
        let lengthOfOneSide = view.bounds.width * 0.9
        let positionOfCanvas = view.bounds.height - lengthOfOneSide - 20 - view.safeAreaInsets.bottom
        let numsOfPixels = 16
        
        canvas = Canvas(positionOfCanvas: positionOfCanvas, lengthOfOneSide: lengthOfOneSide, numsOfPixels: numsOfPixels, toolBoxViewController: toolBoxViewController)
        canvasView.addSubview(canvas)
        canvas.backgroundColor = .darkGray
        canvas.frame = CGRect(x: 0, y: 0, width: lengthOfOneSide, height: lengthOfOneSide)
        canvas.convertCanvasToImage(0)
        
        toolBoxViewController.previewImageToolBar.canvas = canvas
        toolBoxViewController.previewImageToolBar.previewListRect = toolView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        if segue.identifier == "preview" {
//            let destinationVC = segue.destination as? PreviewListViewController
//            previewListViewController = destinationVC
//        } else
        if segue.identifier == "toolbox" {
            let destinationVC = segue.destination as? ToolBoxViewController
            toolBoxViewController = destinationVC
//            toolBoxViewController.
        }
        
        
    }
}

