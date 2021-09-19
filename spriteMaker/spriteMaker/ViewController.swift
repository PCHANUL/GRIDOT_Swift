//
//  ViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/02/19.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var viewController: UIView!
    @IBOutlet weak var mainContainerView: UIView!
    
    @IBOutlet weak var bottomNav: UIView!
    @IBOutlet weak var undoBtn: UIButton!
    @IBOutlet weak var redoBtn: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var timeMachineVM: TimeMachineViewModel!
    
    weak var panelContainerViewController: PanelContainerViewController!
    var canvas: Canvas!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        print("View")
        
        setSideCorner(target: bottomNav, side: "top", radius: bottomNav.bounds.width / 25)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "home":
            print("home")
            let destinationVC = segue.destination as? HomeViewController
            destinationVC?.superViewController = self
        case "export":
            print("export")
            let destinationVC = segue.destination as? ExportViewController
            destinationVC?.superViewController = self
        case "main":
            print("main")
            let destinationVC = segue.destination as? MainViewController
            destinationVC?.superViewController = self
        default:
            return
        }
    }
    
    @IBAction func tappedUndo(_ sender: Any) {
        canvas.initCanvasDrawingTools()
        checkSelectedFrameAndScroll(index: canvas.timeMachineVM.endIndex - 1)
        canvas.timeMachineVM.undo()
    }
    
    @IBAction func tappedRedo(_ sender: Any) {
        canvas.initCanvasDrawingTools()
        checkSelectedFrameAndScroll(index: canvas.timeMachineVM.endIndex + 1)
        canvas.timeMachineVM.redo()
    }
    
    @IBAction func toggleValueChanged(_ sender: Any) {
        let view = self.storyboard?.instantiateViewController(identifier: "TestViewController") as! TestViewController
        view.modalPresentationStyle = .fullScreen
        view.segmentedControl = segmentedControl
        self.present(view, animated: false, completion: nil)
    }
    
    // undo 또는 redo하는 경우, 변경되는 Frame, Layer를 확인하기 쉽게 CollectionView 스크롤을 이동
    func checkSelectedFrameAndScroll(index: Int) {
        let previewAndLayerCVC: UICollectionView
        let previewAndLayerToggle: UISegmentedControl
        let maxYoffset: CGFloat
        
        previewAndLayerCVC = panelContainerViewController.previewImageToolBar.previewAndLayerCVC
        previewAndLayerToggle = panelContainerViewController.previewImageToolBar.changeStatusToggle
        
        // index값이 selected된 Frame 또는 Layer의 index와 같지 않다면 CollectionView의 스크롤을 변경
        if (canvas.timeMachineVM.isSameSelectedFrame(index: index) == false) {
            // Frame으로 스크롤
            previewAndLayerCVC.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            previewAndLayerToggle.selectedSegmentIndex = 0
            panelContainerViewController.previewImageToolBar.setAnimatedPreviewLayerForFrameList()
        } else if (canvas.timeMachineVM.isSameSelectedLayer(index: index) == false) {
            // Layer로 스크롤
            maxYoffset = previewAndLayerCVC.contentSize.height - previewAndLayerCVC.frame.size.height
            previewAndLayerCVC.setContentOffset(CGPoint(x: 0, y: maxYoffset), animated: true)
            previewAndLayerToggle.selectedSegmentIndex = 1
            panelContainerViewController.previewImageToolBar.setAnimatedPreviewLayerForLayerList()
        }
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
            sideButtonToCanvasConstraint = sideButtonView.rightAnchor.constraint(equalTo: canvasView.rightAnchor, constant: 6)
            sideButtonToGroupConstraint = sideButtonView.leftAnchor.constraint(equalTo: sideButtonViewGroup.leftAnchor)
            topSideBtnImage.image = UIImage(systemName: "rectangle.righthalf.inset.fill")
            currentSide = "right"
        case "right":
            panelConstraint = panelContainerView.rightAnchor.constraint(equalTo: canvasView.rightAnchor)
            sideButtonGroupConstraint = sideButtonViewGroup.leftAnchor.constraint(equalTo: viewController.leftAnchor)
            sideButtonToCanvasConstraint = sideButtonView.leftAnchor.constraint(equalTo: canvasView.leftAnchor, constant: -6)
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
        botSideBtn.backgroundColor = UIColor.lightGray
        if (canvas.selectedDrawingMode == "touch") {
            print("touchDown")
            canvas.activatedDrawing = true
            canvas.initTouchPosition = canvas.touchDrawingMode.cursorPosition
            canvas.switchToolsButtonDown()
            canvas.setNeedsDisplay()
        }
    }
    
    @IBAction func tappedDrawBottomBtn(_ sender: Any) {
        botSideBtn.backgroundColor = UIColor.black
        if (canvas.selectedDrawingMode == "touch") {
            print("touchUp")
            canvas.activatedDrawing = false
            canvas.switchToolsButtonUp()
            canvas.setNeedsDisplay()
        }
    }
    
    @IBAction func touchDownMiddleBtn(_ sender: Any) {
        midSideBtn.backgroundColor = UIColor.lightGray
        prevToolIndex = panelContainerViewController.drawingToolVM.selectedToolIndex
        panelContainerViewController.drawingToolVM.selectedToolIndex = 1
        
        canvas.activatedDrawing = true
        canvas.initTouchPosition = canvas.touchDrawingMode.cursorPosition
        canvas.switchToolsButtonDown()
        canvas.setNeedsDisplay()
    }
    
    @IBAction func touchUpMiddleBtn(_ sender: Any) {
        midSideBtn.backgroundColor = UIColor.black
        canvas.activatedDrawing = false
        canvas.switchToolsButtonUp()
        
        panelContainerViewController.drawingToolVM.selectedToolIndex = prevToolIndex
        canvas.setNeedsDisplay()
    }
}
