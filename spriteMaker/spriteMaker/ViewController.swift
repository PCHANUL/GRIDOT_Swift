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
    @IBOutlet weak var panelWidthContraint: NSLayoutConstraint!
    
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
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var timeMachineVM: TimeMachineViewModel!
    
    weak var panelContainerViewController: PanelContainerViewController!
    var canvas: Canvas!
    
    var scrollPosition: CGFloat!
    var scrollPanelNum: CGFloat!
    var scrollBeganPos: CGFloat!
    var scrollMovedPos: CGFloat!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        print("View")
        currentSide = "left"
        setSideCorner(target: bottomNav, side: "top", radius: bottomNav.bounds.width / 25)
        setSideCorner(target: sideButtonView, side: "all", radius: sideButtonView.bounds.width / 4)
        setSideCorner(target: topSideBtn, side: "all", radius: topSideBtn.bounds.width / 4)
        setSideCorner(target: midSideBtn, side: "all", radius: midSideBtn.bounds.width / 4)
        setSideCorner(target: botSideBtn, side: "all", radius: botSideBtn.bounds.width / 4)
        
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
        switch segue.identifier {
        case "toolbox":
            prepareToolBox(segue)
        case "home":
            print("home")
            let destinationVC = segue.destination as? HomeViewController
            destinationVC?.superViewController = self
        case "export":
            print("export")
            let destinationVC = segue.destination as? ExportViewController
            destinationVC?.superViewController = self
        default:
            return
        }
    }
    
    func prepareToolBox(_ segue: UIStoryboardSegue) {
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
