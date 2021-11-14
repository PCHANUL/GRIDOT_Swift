//
//  DrawingViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/11/05.
//

import UIKit

class DrawingViewController: UIViewController {
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var canvasViewWidth: NSLayoutConstraint!
    @IBOutlet weak var scrollNav: UIView!
    @IBOutlet weak var scrollNavBar: UIView!
    
    @IBOutlet weak var panelCollectionView: UICollectionView!
    @IBOutlet weak var panelWidthContraint: NSLayoutConstraint!
    
    @IBOutlet weak var sideButtonViewGroup: UIView!
    @IBOutlet weak var sideButtonView: UIView!
    @IBOutlet weak var topSideBtn: UIView!
    @IBOutlet weak var midSideBtn: UIView!
    @IBOutlet weak var botSideBtn: UIView!
    @IBOutlet weak var topSideBtnImage: UIImageView!
    @IBOutlet weak var midSideBtnImage: UIImageView!
    @IBOutlet weak var botSideBtnImage: UIImageView!

    var canvas: Canvas!
    var coreData: CoreData = CoreData()
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
    
    // loading label
    var loadingImageView: UIView!
    var loadingImages: [UIImage] = []
    
    // drawing mode values
    var buttonViewWidth: CGFloat!
    var panelViewWidth: CGFloat!
    
    override func awakeFromNib() {
        currentSide = "left"
        
        scrollPosition = 0
        scrollPanelNum = 0
        scrollBeganPos = 0
        scrollMovedPos = 0
        
        drawingToolVM = DrawingToolViewModel()
        layerVM = LayerListViewModel()
        animatedPreviewVM = AnimatedPreviewViewModel()
        colorPaletteVM = ColorPaletteListViewModel()
        
        
        for index in 0...15 {
            loadingImages.append(UIImage(named: "loading\(index)")!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let numsOfPixels: CGFloat = 16
        let frameWidth = self.view.frame.width * 0.9
        let lengthOfOneSide = round(frameWidth / numsOfPixels) * numsOfPixels
        
        canvas = Canvas(lengthOfOneSide, Int(numsOfPixels), self)
        canvas.frame = CGRect(x: 0, y: 0, width: lengthOfOneSide, height: lengthOfOneSide)
        canvas.backgroundColor = .clear
        canvasView.addSubview(canvas)
        
        self.timeMachineVM = TimeMachineViewModel(canvas, self)
        canvas.timeMachineVM = self.timeMachineVM
        panelWidthContraint.constant = 0
        canvasViewWidth.constant = lengthOfOneSide
        
        setSideCorner(target: sideButtonView, side: "all", radius: sideButtonView.bounds.width / 4)
        setSideCorner(target: topSideBtn, side: "all", radius: topSideBtn.bounds.width / 4)
        setSideCorner(target: midSideBtn, side: "all", radius: midSideBtn.bounds.width / 4)
        setSideCorner(target: botSideBtn, side: "all", radius: botSideBtn.bounds.width / 4)
        setScrollNavBarConstraint(panelCollectionView)
        
        scrollNav.isHidden = (panelCollectionView.frame.height > (panelCollectionView.frame.width * 0.9))
        let heightRatio = panelCollectionView.frame.height / (panelCollectionView.frame.width + 20)
        let height = scrollNav.bounds.height * heightRatio
        let heightConstraint = scrollNavBar.heightAnchor.constraint(equalToConstant: height)
        
        heightConstraint.priority = UILayoutPriority(500)
        heightConstraint.isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (coreData.hasIndexChanged) {
            DispatchQueue.main.async { [self] in
                setLabelView(self)
                DispatchQueue.main.async { [self] in
                    updateCanvasData()
                    removeLoadingCanvasView()
                    
                    previewImageToolBar.setOffsetForSelectedFrame()
                    previewImageToolBar.setOffsetForSelectedLayer()
                    coreData.changeHasIndexChanged(false)
                }
            }
        }
    }
    
    func changeDrawingMode() {
        let constantValue: CGFloat!
        let widthValue: CGFloat!
        
        if (buttonViewWidth == nil) {
            buttonViewWidth = sideButtonView.frame.width
            panelViewWidth = panelCollectionView.frame.size.width
        }
        
        switch canvas.selectedDrawingMode {
        case "pen":
            constantValue = 0
            widthValue = panelViewWidth + buttonViewWidth
        case "touch":
            constantValue = -1 * buttonViewWidth
            widthValue = panelViewWidth - buttonViewWidth
        default:
            return
        }
        panelWidthContraint.constant = constantValue
        panelCollectionView.frame.size.width = widthValue
        panelCollectionView.collectionViewLayout.invalidateLayout()
        previewImageToolBar.previewAndLayerCVC.collectionViewLayout.invalidateLayout()
    }
    
    func updateCanvasData() {
        let data = coreData.selectedData.data!
        
        canvas.initViewModelImage(data: data)
    }
    
    func setLabelView(_ targetView: UIViewController) {
        setLoadingCanvasView()
        layerVM.frames = []
        layerVM.reloadRemovedList()
        layerVM.reloadLayerList()
        previewImageToolBar.animatedPreview.image = UIImage(named: "empty")
    }
    
    func removeLabelView() {
        DispatchQueue.main.async { [self] in
            removeLoadingCanvasView()
        }
    }
    
    func setLoadingCanvasView() {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: canvasView.frame.width, height: canvasView.frame.height))
        imageView.animationImages = loadingImages
        imageView.animationDuration = TimeInterval(1)
        imageView.startAnimating()
        
        loadingImageView = UIView(frame: CGRect(x: 0, y: 0, width: canvasView.frame.width, height: canvasView.frame.height))
        loadingImageView.backgroundColor = .clear
        
        loadingImageView.addSubview(imageView)
        canvasView.insertSubview(loadingImageView, at: 0)
        
        addSubviewLoadingText(target: canvasView)
    }
    
    func addSubviewLoadingText(target: UIView) {
        let loadingLabel = UILabel(frame: CGRect(
            x: (canvasView.frame.width / 2) - 50, y: (canvasView.frame.width / 2) - 10,
            width: 100, height: 22
        ))
        loadingLabel.text = "Loading"
        loadingLabel.textAlignment = .center
        loadingLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        loadingLabel.alpha = 0.5
        target.insertSubview(loadingLabel, at: 2)
    }
    
    func removeLoadingCanvasView() {
        let canvasSubviews = canvasView.subviews
        if (canvasSubviews.count == 3) {
            canvasSubviews[0].removeFromSuperview()
            canvasSubviews[2].removeFromSuperview()
        }
    }
    
    // undo 또는 redo하는 경우, 변경되는 Frame, Layer를 확인하기 쉽게 CollectionView 스크롤을 이동
    func checkSelectedFrameAndScroll(index: Int) {
        if (timeMachineVM.isSameSelectedFrameIndex(timeIndex: index) == false) {
            previewImageToolBar.setScrollToFrameList()
        } else if (timeMachineVM.isSameSelectedLayerIndex(timeIndex: index) == false) {
            previewImageToolBar.setScrollToLayerList()
        }
    }
}

// side button view
extension DrawingViewController {
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
            sideButtonGroupConstraint = sideButtonViewGroup.rightAnchor.constraint(equalTo: view.rightAnchor)
            sideButtonToCanvasConstraint = sideButtonView.rightAnchor.constraint(equalTo: canvasView.rightAnchor, constant: 6)
            sideButtonToGroupConstraint = sideButtonView.leftAnchor.constraint(equalTo: sideButtonViewGroup.leftAnchor)
            topSideBtnImage.image = UIImage(systemName: "rectangle.righthalf.inset.fill")
            currentSide = "right"
        case "right":
            panelConstraint = panelCollectionView.rightAnchor.constraint(equalTo: canvasView.rightAnchor)
            sideButtonGroupConstraint = sideButtonViewGroup.leftAnchor.constraint(equalTo: view.leftAnchor)
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
    
    @IBAction func touchUpBottomBtn(_ sender: Any) {
        botSideBtn.backgroundColor = UIColor.black
        if (canvas.selectedDrawingMode == "touch") {
            print("touchUp")
            canvas.activatedDrawing = false
            canvas.switchToolsButtonUp()
            canvas.setNeedsDisplay()
        }
    }
}

extension DrawingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orderOfTools.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case orderOfTools[0]:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewAndLayerCollectionViewCell", for: indexPath) as? PreviewAndLayerCollectionViewCell else { return UICollectionViewCell() }
            cell.canvas = canvas
            cell.layerVM = layerVM
            cell.animatedPreviewVM = animatedPreviewVM
            cell.drawingVC = self
            previewImageToolBar = cell
            layerVM.previewAndLayerCVC = cell
            animatedPreviewVM.targetView = cell.animatedPreviewUIView
            animatedPreviewVM.targetImageView = animatedPreviewVM.findImageViewOfUIView(cell.animatedPreviewUIView)
            animatedPreviewVM.viewModel = layerVM
            cell.clipsToBounds = true
            cell.layer.cornerRadius = cell.frame.height / 15
            return cell
            
        case orderOfTools[1]:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorPaletteCollectionViewCell", for: indexPath) as? ColorPaletteCollectionViewCell else { return UICollectionViewCell() }
            cell.canvas = canvas
            cell.viewController = self
            cell.panelCollectionView = panelCollectionView
            cell.colorPaletteViewModel = colorPaletteVM
            colorPickerToolBar = cell
            // viewModel
            colorPaletteVM.colorCollectionList = cell.colorCollectionList
            cell.clipsToBounds = true
            cell.layer.cornerRadius = cell.frame.height / 15
            return cell
            
        case orderOfTools[2]:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DrawingToolCollectionViewCell", for: indexPath) as? DrawingToolCollectionViewCell else { return UICollectionViewCell() }
            cell.drawingToolVM = drawingToolVM
            cell.timeMachineVM = timeMachineVM
            cell.drawingVC = self
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

extension DrawingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let modeHeight: CGFloat!
        let height: CGFloat!
        
        modeHeight = canvas.selectedDrawingMode == "touch" ? buttonViewWidth : 0
        height = (panelCollectionView.frame.width + modeHeight) * 0.3
        return CGSize(width: panelCollectionView.frame.width, height: height)
    }
}

extension DrawingViewController: UICollectionViewDelegate {
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

        drawingMode = canvas.selectedDrawingMode
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

