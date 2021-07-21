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
    
    @IBOutlet weak var drawBtn: UIButton!
    @IBOutlet weak var eraseBtn: UIButton!
    @IBOutlet weak var changeSideBtn: UIButton!
    @IBOutlet weak var sideButtonView: UIView!
    var panelConstraint: NSLayoutConstraint!
    var sideBtnConstraint: NSLayoutConstraint!
    var currentSide: String!
    
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
        setOneSideCorner(target: drawBtn, side: "all", radius: drawBtn.bounds.width / 5)
        setOneSideCorner(target: eraseBtn, side: "all", radius: eraseBtn.bounds.width / 5)
        setOneSideCorner(target: changeSideBtn, side: "all", radius: changeSideBtn.bounds.width / 5)
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
        canvas.timeMachineVM.undo()
    }
    
    @IBAction func tappedRedo(_ sender: Any) {
        canvas.timeMachineVM.redo()
    }
}

// side button view
extension ViewController {
    @IBAction func tappedChangeSide(_ sender: Any) {
        if (panelConstraint != nil) {
            panelConstraint.priority = UILayoutPriority(500)
            sideBtnConstraint.priority = UILayoutPriority(500)
        }
        switch currentSide {
        case "left":
            panelConstraint = panelContainerView.leftAnchor.constraint(equalTo: canvasView.leftAnchor)
            sideBtnConstraint = sideButtonView.rightAnchor.constraint(equalTo: canvasView.rightAnchor)
            changeSideBtn.setImage(UIImage(systemName: "rectangle.righthalf.inset.fill"), for: .normal)
            currentSide = "right"
        case "right":
            panelConstraint = panelContainerView.rightAnchor.constraint(equalTo: canvasView.rightAnchor)
            sideBtnConstraint = sideButtonView.leftAnchor.constraint(equalTo: canvasView.leftAnchor)
            changeSideBtn.setImage(UIImage(systemName: "rectangle.lefthalf.inset.fill"), for: .normal)
            currentSide = "left"
        default:
            return
        }
        panelConstraint.isActive = true
        sideBtnConstraint.isActive = true
    }
    
    @IBAction func tappedDrawBtn(_ sender: Any) {
        print("draw")
        canvas.activatedDrawing = false
    }
    
    @IBAction func touchDownDrawBtn(_ sender: Any) {
        print("touch")
        canvas.activatedDrawing = true
    }
}
