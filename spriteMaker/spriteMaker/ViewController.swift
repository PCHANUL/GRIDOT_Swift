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
    @IBOutlet weak var scrollNav: UIView!
    @IBOutlet weak var scrollNavBar: UIView!
    @IBOutlet weak var bottomNav: UIView!
    @IBOutlet weak var panelContainerView: UIView!
    @IBOutlet weak var drawBtn: UIButton!
    @IBOutlet weak var eraseBtn: UIButton!
    @IBOutlet weak var changeSideBtn: UIButton!
    @IBOutlet weak var sideButtonView: UIView!
    var panelContainerViewController: PanelContainerViewController!
    var canvas: Canvas!
    
    var scrollPosition: CGFloat!
    var scrollPanelNum: CGFloat!
    var scrollBeganPos: CGFloat!
    var scrollMovedPos: CGFloat!
    
    var timeMachineVM: TimeMachineViewModel!
    @IBOutlet weak var undoBtn: UIButton!
    @IBOutlet weak var redoBtn: UIButton!
    
    override func viewDidLoad() {
        scrollPosition = 0
        scrollPanelNum = 0
        scrollBeganPos = 0
        scrollMovedPos = 0
        setOneSideCorner(target: bottomNav, side: "top", radius: bottomNav.bounds.height / 5)
        setOneSideCorner(target: drawBtn, side: "all", radius: drawBtn.bounds.width / 5)
        setOneSideCorner(target: eraseBtn, side: "all", radius: eraseBtn.bounds.width / 5)
        setOneSideCorner(target: changeSideBtn, side: "all", radius: changeSideBtn.bounds.width / 5)
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
        canvas.timeMachineVM.undo()
    }
    
    @IBAction func tappedRedo(_ sender: Any) {
        canvas.timeMachineVM.redo()
    }
    @IBAction func tappedDrawBtn(_ sender: Any) {
        print("draw")
    }
}

extension ViewController: UICollectionViewDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: scrollNav) else { return }
        scrollBeganPos = point.y
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: scrollNav) else { return }
        if (point.x < 0) { return }
        if (scrollBeganPos > scrollNav.frame.maxY) { return }
        if (scrollBeganPos < point.y - 30 && scrollPanelNum != 2) {
            scrollPanelNum += 1
            scrollBeganPos = point.y
            let panelHeight = (panelContainerViewController.panelCollectionView.bounds.width * 0.3) + 10
            panelContainerViewController.panelCollectionView.setContentOffset(
                CGPoint(x: 0, y: panelHeight * scrollPanelNum), animated: true)
        } else if (scrollBeganPos > point.y + 30 && scrollPanelNum != 0) {
            scrollPanelNum -= 1
            scrollBeganPos = point.y
            let panelHeight = (panelContainerViewController.panelCollectionView.bounds.width * 0.3) + 10
            panelContainerViewController.panelCollectionView.setContentOffset(
                CGPoint(x: 0, y: panelHeight * scrollPanelNum), animated: true)
        }
    }
}

class NavCell: UICollectionViewCell {
}

