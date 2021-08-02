//
//  PreviewOptionPopupViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/02/26.
//

import UIKit

class PreviewOptionPopupViewController: UIViewController {
    @IBOutlet var popupSuperView: UIView!
    @IBOutlet weak var popupOption: UIView!
    @IBOutlet weak var popupArrow: UIImageView!
    @IBOutlet weak var popupNum: UILabel!
    @IBOutlet weak var removeView: UIView!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var duplicateView: UIView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var previewList: UIView!
    @IBOutlet weak var popupView: UIView!
    var previewListCVC: PreviewListCollectionViewCell!
    
    var popupArrowX: CGFloat!
    var popupPositionY: CGFloat!
    
    var viewModel: LayerListViewModel!
    var animatedPreviewVM: AnimatedPreviewViewModel!
    let categoryListVM = CategoryListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let leadingAnchor: CGFloat
        
        setOneSideCorner(target: popupOption, side: "all", radius: popupOption.bounds.width / 20)
        setOneSideCorner(target: removeView, side: "all", radius: removeView.bounds.width / 4)
        setOneSideCorner(target: duplicateView, side: "all", radius: duplicateView.bounds.width / 4)
        setViewShadow(target: popupArrow, radius: 15, opacity: 0.7)
        setViewShadow(target: popupOption, radius: 15, opacity: 0.7)
        
        leadingAnchor = popupArrowX! - popupArrow.frame.width / 2 + 5
        popupNum.text = "#\(viewModel.selectedFrameIndex + 1)"
        previewList.topAnchor.constraint(equalTo: popupView.topAnchor, constant: popupPositionY).isActive = true
        popupArrow.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: leadingAnchor).isActive = true
    }
    
    @IBAction func tappedRemoveButton(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        viewModel.removeCurrentFrame()
    }
    
    @IBAction func tappedDuplicateButton(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        viewModel.copyPreFrame()
        viewModel.selectedLayerIndex = 0
        
        let contentX = CGFloat(viewModel.selectedFrameIndex) * previewListCVC.cellWidth
        previewListCVC.previewImageCollection.contentOffset.x = contentX
        previewListCVC.reloadPreviewListItems()
    }
    
    @IBAction func tappedBackground(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}

extension PreviewOptionPopupViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryListVM.numsOfCategory
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else {
            return UICollectionViewCell()
        }
        let selectedFrame: Frame
        let category: Category
        let sizeUnit: CGFloat
        
        selectedFrame = viewModel.selectedFrame!
        category = categoryListVM.item(at: indexPath.row)
        sizeUnit = cell.layer.frame.height * 0.4
        cell.categoryName.font = UIFont.systemFont(ofSize: sizeUnit, weight: UIFont.Weight.heavy)
        cell.categoryName.text = category.text
        cell.backgroundColor = category.color
        cell.layer.cornerRadius = sizeUnit
        cell.layer.borderWidth = selectedFrame.category == category.text ? (sizeUnit / 7) : 0
        cell.layer.borderColor = UIColor.white.cgColor
        return cell
    }
}

extension PreviewOptionPopupViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let categoryName: String
        let oldFrame: Frame
        let newFrame: Frame
        
        categoryName = categoryListVM.item(at: indexPath.row).text
        oldFrame = viewModel.selectedFrame!
        newFrame = Frame(layers: oldFrame.layers, renderedImage: oldFrame.renderedImage, category: categoryName)
        viewModel.updateCurrentFrame(frame: newFrame)
        animatedPreviewVM.changeAnimatedPreview()
        categoryCollectionView.reloadData()
    }
}

extension PreviewOptionPopupViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat
        let width: CGFloat
        
        height = categoryCollectionView.bounds.height * 0.8
        width = height * 2
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let halfOfCellWidth: CGFloat
        let sideInset: CGFloat
        let selectedFrame: Frame
        let selectedIndex: CGFloat
        
        halfOfCellWidth = categoryCollectionView.bounds.height * 0.8
        sideInset = categoryCollectionView.bounds.width / 2 - halfOfCellWidth
        selectedFrame = viewModel.selectedFrame!
        selectedIndex = CGFloat(categoryListVM.indexOfCategory(name: selectedFrame.category))
        categoryCollectionView.setContentOffset(CGPoint(x: (halfOfCellWidth * 2 + 10) * selectedIndex, y: 0), animated: true)
        return UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
    }
}

class CategoryCell: UICollectionViewCell {
    @IBOutlet weak var categoryName: UILabel!
}
