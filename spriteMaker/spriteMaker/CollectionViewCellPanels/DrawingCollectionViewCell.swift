//
//  ToolBoxViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/03.
//

import UIKit

class DrawingCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var scrollNav: UIView!
    @IBOutlet weak var scrollNavBar: UIView!
    
    @IBOutlet weak var panelCollectionView: UICollectionView!
    @IBOutlet weak var panelWidthContraint: NSLayoutConstraint!
    
    @IBOutlet weak var sideButtonView: UIView!
    @IBOutlet weak var topSideBtn: UIView!
    @IBOutlet weak var midSideBtn: UIView!
    @IBOutlet weak var botSideBtn: UIView!
    @IBOutlet weak var topSideBtnImage: UIImageView!
    @IBOutlet weak var midSideBtnImage: UIImageView!
    @IBOutlet weak var botSideBtnImage: UIImageView!
    
    @IBOutlet weak var sideButtonViewGroup: UIView!
    
    var canvas: Canvas!
    var superViewController: ViewController!
    var timeMachineVM: TimeMachineViewModel!
    
    var panelConstraint: NSLayoutConstraint!
    var sideButtonGroupConstraint: NSLayoutConstraint!
    var sideButtonToCanvasConstraint: NSLayoutConstraint!
    var sideButtonToGroupConstraint: NSLayoutConstraint!
    var currentSide: String!
    var prevToolIndex: Int!
    
    var scrollPosition: CGFloat!
    var scrollPanelNum: CGFloat!
    var scrollBeganPos: CGFloat!
    var scrollMovedPos: CGFloat!
    
    var scrollConstraint: NSLayoutConstraint!
    var orderOfTools: [Int] = [0, 1, 2]
    
    // view models
    var animatedPreviewVM: AnimatedPreviewViewModel!
    var layerVM: LayerListViewModel!
    var colorPaletteVM: ColorPaletteListViewModel!
    var drawingToolVM: DrawingToolViewModel!
    
    // view cells
    var previewImageToolBar: PreviewAndLayerCollectionViewCell!
    var colorPickerToolBar: ColorPaletteCollectionViewCell!
    var drawingToolBar: DrawingToolCollectionViewCell!
    var optionToolBar: OptionCollectionViewCell!
    
    override func awakeFromNib() {
        currentSide = "left"
        setSideCorner(target: sideButtonView, side: "all", radius: sideButtonView.bounds.width / 4)
        setSideCorner(target: topSideBtn, side: "all", radius: topSideBtn.bounds.width / 4)
        setSideCorner(target: midSideBtn, side: "all", radius: midSideBtn.bounds.width / 4)
        setSideCorner(target: botSideBtn, side: "all", radius: botSideBtn.bounds.width / 4)
        
        scrollPosition = 0
        scrollPanelNum = 0
        scrollBeganPos = 0
        scrollMovedPos = 0
        
        drawingToolVM = DrawingToolViewModel(self)
        layerVM = LayerListViewModel()
        animatedPreviewVM = AnimatedPreviewViewModel()
        colorPaletteVM = ColorPaletteListViewModel()
        setScrollNavBarConstraint(panelCollectionView)
        
        let numsOfPixels = 16
        let lengthOfOneSide = canvasView.bounds.width
        canvas = Canvas(lengthOfOneSide, numsOfPixels, self)
        
        self.timeMachineVM = TimeMachineViewModel(canvas, self)
        canvas.timeMachineVM = self.timeMachineVM
        canvas.frame = CGRect(x: 0, y: 0, width: lengthOfOneSide, height: lengthOfOneSide)
        canvas.backgroundColor = .darkGray
        canvasView.addSubview(canvas)
    }
    
    override func layoutSubviews() {
        scrollNav.isHidden = (panelCollectionView.frame.height > (panelCollectionView.frame.width * 0.9))
        let heightRatio = panelCollectionView.frame.height / (panelCollectionView.frame.width + 20)
        let height = scrollNav.bounds.height * heightRatio
        let heightConstraint = scrollNavBar.heightAnchor.constraint(equalToConstant: height)
        
        heightConstraint.priority = UILayoutPriority(500)
        heightConstraint.isActive = true
    }
}

// side button view
extension DrawingCollectionViewCell {
    @IBAction func tappedChangeSide(_ sender: Any) {
        if (panelConstraint != nil) {
            panelConstraint.priority = UILayoutPriority(500)
            sideButtonGroupConstraint.priority = UILayoutPriority(500)
            sideButtonToCanvasConstraint.priority = UILayoutPriority(500)
            sideButtonToGroupConstraint.priority = UILayoutPriority(500)
        }
        switch currentSide {
        case "left":
            panelConstraint = panelCollectionView.leftAnchor.constraint(equalTo: canvasView.leftAnchor)
            sideButtonGroupConstraint = sideButtonViewGroup.rightAnchor.constraint(equalTo: self.rightAnchor)
            sideButtonToCanvasConstraint = sideButtonView.rightAnchor.constraint(equalTo: canvasView.rightAnchor, constant: 6)
            sideButtonToGroupConstraint = sideButtonView.leftAnchor.constraint(equalTo: sideButtonViewGroup.leftAnchor)
            topSideBtnImage.image = UIImage(systemName: "rectangle.righthalf.inset.fill")
            currentSide = "right"
        case "right":
            panelConstraint = panelCollectionView.rightAnchor.constraint(equalTo: canvasView.rightAnchor)
            sideButtonGroupConstraint = sideButtonViewGroup.leftAnchor.constraint(equalTo: self.leftAnchor)
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
        prevToolIndex = drawingToolVM.selectedToolIndex
        drawingToolVM.selectedToolIndex = 1
        
        canvas.activatedDrawing = true
        canvas.initTouchPosition = canvas.touchDrawingMode.cursorPosition
        canvas.switchToolsButtonDown()
        canvas.setNeedsDisplay()
    }
    
    @IBAction func touchUpMiddleBtn(_ sender: Any) {
        midSideBtn.backgroundColor = UIColor.black
        canvas.activatedDrawing = false
        canvas.switchToolsButtonUp()
        
        drawingToolVM.selectedToolIndex = prevToolIndex
        canvas.setNeedsDisplay()
    }
}

extension DrawingCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orderOfTools.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case orderOfTools[0]:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewAndLayerCollectionViewCell", for: indexPath) as! PreviewAndLayerCollectionViewCell
            cell.canvas = canvas
            cell.layerVM = layerVM
            cell.animatedPreviewVM = animatedPreviewVM
            cell.drawingCVC = self
            previewImageToolBar = cell
            layerVM.previewAndLayerCVC = cell
            animatedPreviewVM.targetView = cell.animatedPreviewUIView
            animatedPreviewVM.targetImageView = animatedPreviewVM.findImageViewOfUIView(cell.animatedPreviewUIView)
            animatedPreviewVM.viewModel = layerVM
            cell.clipsToBounds = true
            cell.layer.cornerRadius = cell.frame.height / 15
            return cell
            
        case orderOfTools[1]:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorPaletteCollectionViewCell", for: indexPath) as! ColorPaletteCollectionViewCell
            cell.canvas = canvas
            cell.viewController = superViewController
            cell.panelCollectionView = panelCollectionView
            cell.colorPaletteViewModel = colorPaletteVM
            colorPickerToolBar = cell
            // viewModel
            colorPaletteVM.colorCollectionList = cell.colorCollectionList
            cell.clipsToBounds = true
            cell.layer.cornerRadius = cell.frame.height / 15
            return cell
            
        case orderOfTools[2]:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DrawingToolCollectionViewCell", for: indexPath) as! DrawingToolCollectionViewCell
            cell.drawingToolVM = drawingToolVM
            cell.drawingCVC = self
            cell.panelCollectionView = self.panelCollectionView
            drawingToolBar = cell
            cell.clipsToBounds = true
            cell.layer.cornerRadius = cell.frame.height / 15
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
}

extension DrawingCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat!
        let drawingModeWidth: CGFloat!
        let ModeHeight: CGFloat!
        let height: CGFloat!
        
        width = panelCollectionView.frame.width
        drawingModeWidth = drawingToolVM.buttonViewWidth
        ModeHeight = canvas.selectedDrawingMode == "touch" ? drawingModeWidth : 0
        height = (width + ModeHeight) * 0.3
        return CGSize(width: width, height: height)
    }
}

extension DrawingCollectionViewCell: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollPosition = panelCollectionView.contentOffset.y
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollConstraint.priority = UILayoutPriority(200)
        setScrollNavBarConstraint(scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let drawingMode: String!
        let ModeHeight: CGFloat!
        let height: CGFloat!
        let scrollOffset: CGFloat!
        
        drawingMode = superViewController.canvas.selectedDrawingMode
        ModeHeight = drawingMode == "touch" ? 30 : 0
        height = ((panelCollectionView.bounds.width + ModeHeight) * 0.3) + 10
        scrollOffset = scrollView.contentOffset.y - scrollPosition
        if (scrollOffset > height / 4) {
            scrollPanelNum += 1
        } else if (scrollOffset < height / -4){
            scrollPanelNum -= 1
        }
        targetContentOffset.pointee = CGPoint(x: 0, y: height * scrollPanelNum)
    }
    
    func setScrollNavBarConstraint(_ scrollView: UIScrollView) {
        let viewHeight = scrollView.frame.width
        let scrollRatio = scrollView.contentOffset.y / viewHeight
        scrollConstraint = scrollNavBar.topAnchor.constraint(
            equalTo: scrollNav.topAnchor,
            constant: scrollNav.bounds.height * scrollRatio + 5
        )
        scrollConstraint.priority = UILayoutPriority(500)
        scrollConstraint.isActive = true
    }
}
