//
//  ViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/02/19.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var viewController: UIView!
    @IBOutlet weak var canvasView: UIView!
    
    var toolBoxViewController: ToolBoxViewController!
    var canvas: Canvas!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as? ToolBoxViewController
        toolBoxViewController = destinationVC
        
        let numsOfPixels = 16
        let lengthOfOneSide = viewController.bounds.width * 0.9
        canvas = Canvas(lengthOfOneSide: lengthOfOneSide, numsOfPixels: numsOfPixels, toolBoxViewController: toolBoxViewController)
        canvas.frame = CGRect(x: 0, y: 0, width: lengthOfOneSide, height: lengthOfOneSide)
        canvas.backgroundColor = .darkGray
        canvasView.addSubview(canvas)
        
        toolBoxViewController.canvas = canvas
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 초기화면 프레임 생성
        if toolBoxViewController.viewModel.numsOfItems == 0 {
            canvas.convertCanvasToImage(0)
        }
    }
}

