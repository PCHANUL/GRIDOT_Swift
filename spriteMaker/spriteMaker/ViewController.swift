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
    
    weak var drawingCVC: DrawingCollectionViewCell!
    var canvas: Canvas!
    var mainViewController: MainViewController!
    
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
            mainViewController = segue.destination as? MainViewController
            mainViewController.superViewController = self
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
    
    @IBAction func toggleValueChanged(_ sender: UISegmentedControl) {
        let pos: CGPoint
        
        if (sender.selectedSegmentIndex == 0) {
            pos = CGPoint(x: 0, y: 0)
        } else {
            pos = CGPoint(x: mainContainerView.frame.width, y: 0)
        }
        mainViewController.mainCollectionView.setContentOffset(pos, animated: true)
    }
    
    // undo 또는 redo하는 경우, 변경되는 Frame, Layer를 확인하기 쉽게 CollectionView 스크롤을 이동
    func checkSelectedFrameAndScroll(index: Int) {
        let previewAndLayerCVC: UICollectionView
        let previewAndLayerToggle: UISegmentedControl
        let maxYoffset: CGFloat
        
        previewAndLayerCVC = drawingCVC.previewImageToolBar.previewAndLayerCVC
        previewAndLayerToggle = drawingCVC.previewImageToolBar.changeStatusToggle
        
        // index값이 selected된 Frame 또는 Layer의 index와 같지 않다면 CollectionView의 스크롤을 변경
        if (canvas.timeMachineVM.isSameSelectedFrame(index: index) == false) {
            // Frame으로 스크롤
            previewAndLayerCVC.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            previewAndLayerToggle.selectedSegmentIndex = 0
            drawingCVC.previewImageToolBar.setAnimatedPreviewLayerForFrameList()
        } else if (canvas.timeMachineVM.isSameSelectedLayer(index: index) == false) {
            // Layer로 스크롤
            maxYoffset = previewAndLayerCVC.contentSize.height - previewAndLayerCVC.frame.size.height
            previewAndLayerCVC.setContentOffset(CGPoint(x: 0, y: maxYoffset), animated: true)
            previewAndLayerToggle.selectedSegmentIndex = 1
            drawingCVC.previewImageToolBar.setAnimatedPreviewLayerForLayerList()
        }
    }
}
