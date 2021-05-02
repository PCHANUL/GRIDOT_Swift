//
//  ToolBoxViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/03.
//

import UIKit

class PanelContainerViewController: UIViewController {
    @IBOutlet weak var panelCollectionView: UICollectionView!
    
    // view models
    var PreViewVM: PreviewListViewModel!
    var animatedPreviewVM: AnimatedPreviewViewModel!
    var colorPaletteVM: ColorPaletteListViewModel!
    var drawingToolVM: DrawingToolViewModel!
    
    // props
    var canvas: Canvas!
    var previewListRect: UIView!
    
    // tool cells
    var previewImageToolBar: PreviewListCollectionViewCell!
    var colorPickerToolBar: ColorPaletteCollectionViewCell!
    var drawingToolBar: DrawingToolCollectionViewCell!
    
    // values
    var isInit: Bool = true
    var orderOfTools: [Int] = [0, 1, 2]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawingToolVM = DrawingToolViewModel()
        
        // 순서 변경을 위한 제스쳐
        // 패널의 순서 변경의 조건을 바꾸어야 한다.
        // 3. 옵션 패널을 만들어서 순서 변경을 한다.
//        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
//        panelCollectionView.addGestureRecognizer(gesture)
    }

//    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
//        let collectionView = panelCollectionView
//
//        switch gesture.state {
//        case .began:
//            guard let targetIndexPath = collectionView?.indexPathForItem(at: gesture.location(in: collectionView)) else { return }
//            collectionView?.beginInteractiveMovementForItem(at: targetIndexPath)
//            collectionView?.cellForItem(at: targetIndexPath)?.alpha = 0.5
//        case .changed:
//            collectionView?.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
//        case .ended:
//            collectionView?.endInteractiveMovement()
//            collectionView?.reloadData()
//        default:
//            collectionView?.cancelInteractiveMovement()
//        }
//    }
}

extension PanelContainerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orderOfTools.count
    }
    
    // 각각의 셀들은 화면에 나타나지 않으면 렌더링 되지 않는다. 그러므로 초기 화면에서 셀을 세팅 하면 오류가 발생한다.

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case orderOfTools[1]:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewListCollectionViewCell", for: indexPath) as! PreviewListCollectionViewCell
            
            previewImageToolBar = cell
            initViewModel()
            previewImageToolBar.canvas = canvas
            previewImageToolBar.PreViewVM = PreViewVM
            previewImageToolBar.animatedPreviewViewModel = animatedPreviewVM
            previewImageToolBar.panelCollectionView = panelCollectionView
            if PreViewVM.numsOfItems == 0 {
                canvas.convertCanvasToImage(0)
            }
            animatedPreviewVM.changeAnimatedPreview(isReset: true)
            return previewImageToolBar
        case orderOfTools[0]:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorPaletteCollectionViewCell", for: indexPath) as! ColorPaletteCollectionViewCell
            colorPickerToolBar = cell
            colorPaletteVM = colorPickerToolBar.colorPaletteViewModel
            colorPickerToolBar.canvas = canvas
            colorPickerToolBar.viewController = self
            colorPickerToolBar.panelCollectionView = panelCollectionView
            return cell
        case orderOfTools[2]:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DrawingToolCollectionViewCell", for: indexPath) as! DrawingToolCollectionViewCell
            drawingToolBar = cell
            
            cell.drawingToolViewModel = drawingToolVM
            cell.panelCollectionView = panelCollectionView
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func initViewModel() {
        guard let cell = previewImageToolBar else { return }
        let reloadPreviewList = cell.previewImageCollection.reloadData
        if isInit {
            PreViewVM = PreviewListViewModel(reloadPreviewList: reloadPreviewList)
        } else {
            PreViewVM.reloadPreviewList = reloadPreviewList
            PreViewVM.reloadRemovedList = {
                reloadPreviewList()
            }
        }
        animatedPreviewVM = AnimatedPreviewViewModel(viewModel: PreViewVM, targetView: previewImageToolBar.animatedPreviewUIView)
        isInit = false
    }
}

extension PanelContainerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = panelCollectionView.bounds.width
        let height: CGFloat = panelCollectionView.bounds.width * 0.3
        return CGSize(width: width, height: height)
    }
    
    // Re-order
//    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        let item = orderOfTools.remove(at: sourceIndexPath.row)
//        print(sourceIndexPath.row)
//        orderOfTools.insert(item, at: destinationIndexPath.row)
//        panelCollectionView.reloadData()
//    }
}





