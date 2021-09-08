//
//  ToolBoxViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/03.
//

import UIKit

class PanelContainerViewController: UIViewController {
    @IBOutlet weak var panelCollectionView: UICollectionView!
    var superViewController: ViewController!
    var scrollConstraint: NSLayoutConstraint!
    
    var canvas: Canvas!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawingToolVM = DrawingToolViewModel(superViewController)
        layerVM = LayerListViewModel()
        animatedPreviewVM = AnimatedPreviewViewModel()
        colorPaletteVM = ColorPaletteListViewModel()
        setScrollNavBarConstraint(panelCollectionView)
    }
}

extension PanelContainerViewController: UICollectionViewDataSource {
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
            cell.panelContainerVC = self
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DrawingToolCollectionViewCell", for: indexPath) as! DrawingToolCollectionViewCell
            cell.drawingToolVM = drawingToolVM
            cell.panelCVC = self
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

extension PanelContainerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat!
        let drawingModeWidth: CGFloat!
        let ModeHeight: CGFloat!
        let height: CGFloat!
        
        width = superViewController.panelContainerView.frame.width
        drawingModeWidth = superViewController.panelContainerViewController.drawingToolVM.buttonViewWidth
        ModeHeight = superViewController.canvas.selectedDrawingMode == "touch" ? drawingModeWidth : 0
        height = (width + ModeHeight) * 0.3
        return CGSize(width: width, height: height)
    }
}

extension PanelContainerViewController: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        superViewController.scrollPosition = panelCollectionView.contentOffset.y
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
        scrollOffset = scrollView.contentOffset.y - superViewController.scrollPosition
        if (scrollOffset > height / 4) {
            superViewController.scrollPanelNum += 1
        } else if (scrollOffset < height / -4){
            superViewController.scrollPanelNum -= 1
        }
        targetContentOffset.pointee = CGPoint(x: 0, y: height * superViewController.scrollPanelNum)
    }
    
    func setScrollNavBarConstraint(_ scrollView: UIScrollView) {
        let viewHeight = scrollView.frame.width
        let scrollRatio = scrollView.contentOffset.y / viewHeight
        scrollConstraint = superViewController.scrollNavBar.topAnchor.constraint(
            equalTo: superViewController.scrollNav.topAnchor,
            constant: superViewController.scrollNav.bounds.height * scrollRatio + 5
        )
        scrollConstraint.priority = UILayoutPriority(500)
        scrollConstraint.isActive = true
    }
}
