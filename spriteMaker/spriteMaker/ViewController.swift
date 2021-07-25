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
    @IBOutlet weak var panelContainerView: UIView!
    @IBOutlet weak var scrollNav: UIView!
    @IBOutlet weak var scrollNavBar: UIView!
    
    @IBOutlet weak var sideButtonView: UIView!
    @IBOutlet weak var topSideBtn: UIView!
    @IBOutlet weak var midSideBtn: UIView!
    @IBOutlet weak var botSideBtn: UIView!
    @IBOutlet weak var topSideBtnImage: UIImageView!
    @IBOutlet weak var midSideBtnImage: UIImageView!
    @IBOutlet weak var botSideBtnImage: UIImageView!
    
    @IBOutlet weak var sideButtonViewGroup: UIView!
    var panelConstraint: NSLayoutConstraint!
    var sideButtonGroupConstraint: NSLayoutConstraint!
    var sideButtonToCanvasConstraint: NSLayoutConstraint!
    var sideButtonToGroupConstraint: NSLayoutConstraint!
    var currentSide: String!
    var prevToolIndex: Int!
    
    @IBOutlet weak var bottomNav: UIView!
    @IBOutlet weak var undoBtn: UIButton!
    @IBOutlet weak var redoBtn: UIButton!
    var timeMachineVM: TimeMachineViewModel!
    
    var panelContainerViewController: PanelContainerViewController!
    var canvas: Canvas!
    
    var scrollPosition: CGFloat!
    var scrollPanelNum: CGFloat!
    var scrollBeganPos: CGFloat!
    var scrollMovedPos: CGFloat!
    
    override func viewDidLoad() {
        currentSide = "left"
        setOneSideCorner(target: bottomNav, side: "top", radius: bottomNav.bounds.height / 5)
        setOneSideCorner(target: sideButtonView, side: "all", radius: sideButtonView.bounds.width / 7)
        setOneSideCorner(target: topSideBtn, side: "all", radius: topSideBtn.bounds.width / 5)
        setOneSideCorner(target: midSideBtn, side: "all", radius: midSideBtn.bounds.width / 5)
        setOneSideCorner(target: botSideBtn, side: "all", radius: botSideBtn.bounds.width / 5)
        scrollPosition = 0
        scrollPanelNum = 0
        scrollBeganPos = 0
        scrollMovedPos = 0
    }
    
    override func viewDidLayoutSubviews() {
        scrollNav.isHidden = (panelContainerView.frame.height > (panelContainerView.frame.width * 0.9))
        let heightRatio = panelContainerView.frame.height / (panelContainerView.frame.width + 20)
        let height = scrollNav.bounds.height * heightRatio
        let heightConstraint = scrollNavBar.heightAnchor.constraint(equalToConstant: height)
        heightConstraint.priority = UILayoutPriority(500)
        heightConstraint.isActive = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as? PanelContainerViewController
        panelContainerViewController = destinationVC
        
        let numsOfPixels = 16
        let lengthOfOneSide = viewController.bounds.width * 0.9
        canvas = Canvas(lengthOfOneSide, numsOfPixels, panelContainerViewController)
        self.timeMachineVM = TimeMachineViewModel(canvas, undoBtn, redoBtn)
        canvas.timeMachineVM = self.timeMachineVM
        canvas.frame = CGRect(x: 0, y: 0, width: lengthOfOneSide, height: lengthOfOneSide)
        canvas.backgroundColor = .darkGray
        canvasView.addSubview(canvas)
        
        panelContainerViewController.canvas = canvas
        panelContainerViewController.superViewController = self
    }
    
    @IBAction func tappedUndo(_ sender: Any) {
        switch panelContainerViewController.drawingToolVM.selectedTool.name {
        case "SelectSquare":
            canvas.selectSquareTool.setClearTool()
        case "Magic":
            canvas.magicTool.setClearTool()
        default:
            break
        }
        canvas.timeMachineVM.undo()
    }
    
    @IBAction func tappedRedo(_ sender: Any) {
        switch panelContainerViewController.drawingToolVM.selectedTool.name {
        case "SelectSquare":
            canvas.selectSquareTool.setClearTool()
        case "Magic":
            canvas.magicTool.setClearTool()
        default:
            break
        }
        canvas.timeMachineVM.redo()
    }
    
}

// side button view
extension ViewController {
    @IBAction func tappedChangeSide(_ sender: Any) {
        if (panelConstraint != nil) {
            panelConstraint.priority = UILayoutPriority(500)
            sideButtonGroupConstraint.priority = UILayoutPriority(500)
            sideButtonToCanvasConstraint.priority = UILayoutPriority(500)
            sideButtonToGroupConstraint.priority = UILayoutPriority(500)
        }
        switch currentSide {
        case "left":
            panelConstraint = panelContainerView.leftAnchor.constraint(equalTo: canvasView.leftAnchor)
            sideButtonGroupConstraint = sideButtonViewGroup.rightAnchor.constraint(equalTo: viewController.rightAnchor)
            sideButtonToCanvasConstraint = sideButtonView.rightAnchor.constraint(equalTo: canvasView.rightAnchor)
            sideButtonToGroupConstraint = sideButtonView.leftAnchor.constraint(equalTo: sideButtonViewGroup.leftAnchor)
            topSideBtnImage.image = UIImage(systemName: "rectangle.righthalf.inset.fill")
            currentSide = "right"
        case "right":
            panelConstraint = panelContainerView.rightAnchor.constraint(equalTo: canvasView.rightAnchor)
            sideButtonGroupConstraint = sideButtonViewGroup.leftAnchor.constraint(equalTo: viewController.leftAnchor)
            sideButtonToCanvasConstraint = sideButtonView.leftAnchor.constraint(equalTo: canvasView.leftAnchor)
            sideButtonToGroupConstraint = sideButtonView.rightAnchor.constraint(equalTo: sideButtonViewGroup.rightAnchor)
            topSideBtnImage.image = UIImage(systemName: "rectangle.lefthalf.inset.fill")
            currentSide = "left"
        default:
            return
        }
        panelConstraint.isActive = true
        sideButtonGroupConstraint.isActive = true
        sideButtonToGroupConstraint.isActive = true
        sideButtonToCanvasConstraint.isActive = true
    }
    
    @IBAction func touchDownBottomBtn(_ sender: Any) {
        if (canvas.selectedDrawingMode == "touch") {
            print("touchDown")
            canvas.activatedDrawing = true
            canvas.initTouchPosition = canvas.touchDrawingMode.cursorPosition
            canvas.switchToolsButtonDown()
            canvas.setNeedsDisplay()
        }
    }
    
    @IBAction func tappedDrawBottomBtn(_ sender: Any) {
        if (canvas.selectedDrawingMode == "touch") {
            print("touchUp")
            canvas.activatedDrawing = false
            canvas.switchToolsButtonUp()
            canvas.setNeedsDisplay()
        }
    }
    
    @IBAction func touchDownMiddleBtn(_ sender: Any) {
        prevToolIndex = panelContainerViewController.drawingToolVM.selectedToolIndex
        panelContainerViewController.drawingToolVM.selectedToolIndex = 1
        
        canvas.activatedDrawing = true
        canvas.initTouchPosition = canvas.touchDrawingMode.cursorPosition
        canvas.switchToolsButtonDown()
        canvas.setNeedsDisplay()
    }
    
    @IBAction func touchUpMiddleBtn(_ sender: Any) {
        canvas.activatedDrawing = false
        canvas.switchToolsButtonUp()
        
        panelContainerViewController.drawingToolVM.selectedToolIndex = prevToolIndex
        canvas.setNeedsDisplay()
    }
}
