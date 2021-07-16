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
    var previewVM: PreviewListViewModel!
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
        drawingToolVM = DrawingToolViewModel()
        previewVM = PreviewListViewModel()
        layerVM = LayerListViewModel()
        animatedPreviewVM = AnimatedPreviewViewModel()
        colorPaletteVM = ColorPaletteListViewModel()
        
        setScrollNavBarConstraint(panelCollectionView)
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
            cell.previewVM = previewVM
            cell.animatedPreviewVM = animatedPreviewVM
            cell.panelContainerVC = self
            previewImageToolBar = cell
            previewVM.previewAndLayerCVC = cell
            layerVM.previewAndLayerCVC = cell
            animatedPreviewVM.targetView = cell.animatedPreviewUIView
            animatedPreviewVM.viewModel = previewVM
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
            cell.panelCollectionView = panelCollectionView
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
        let width: CGFloat = panelCollectionView.bounds.width
        let height: CGFloat = panelCollectionView.bounds.width * 0.3
        return CGSize(width: width, height: height)
    }
}

// 한 단계씩 올리고 내리기
extension PanelContainerViewController: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        superViewController.scrollPosition = panelCollectionView.contentOffset.y
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollConstraint.priority = UILayoutPriority(200)
        setScrollNavBarConstraint(scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let height = (panelCollectionView.bounds.width * 0.3) + 10
        let scrollOffset = scrollView.contentOffset.y - superViewController.scrollPosition
        
        if (scrollOffset > height / 4) {
            superViewController.scrollPanelNum += 1
        } else if (scrollOffset < height / -4){
            superViewController.scrollPanelNum -= 1
        }
        targetContentOffset.pointee = CGPoint(x: 0, y: height * superViewController.scrollPanelNum)
    }
}
