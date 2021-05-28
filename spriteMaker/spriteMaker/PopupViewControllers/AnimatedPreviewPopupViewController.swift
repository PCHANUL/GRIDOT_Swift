//
//  AnimatedPreviewPopupViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/01.
//

import UIKit

class AnimatedPreviewPopupViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var superCollectionView: UIView!
    @IBOutlet weak var animatedPreview: UIView!
    @IBOutlet weak var previewList: UIView!
    @IBOutlet var superView: UIView!
    @IBOutlet var windowView: UIView!
    var categorys: [String] = []
    let categoryListVM = CategoryListViewModel()
    var nums = 0
    var animatedPreviewVM: AnimatedPreviewViewModel!
    var positionY: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cornerRadius = previewList.bounds.width / 20
        superCollectionView.layer.cornerRadius = cornerRadius
        setViewShadow(target: superCollectionView, radius: 15, opacity: 0.7)
        
        previewList.topAnchor.constraint(equalTo: superView.topAnchor, constant: positionY).isActive = true
    }
    
    @IBAction func tappedBackground(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func tappedResetButton(_ sender: Any) {
        animatedPreviewVM.changeAnimatedPreview(isReset: true)
        dismiss(animated: true, completion: nil)
    }
}

extension AnimatedPreviewPopupViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categorys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnimatedPreviewPopupCell", for: indexPath) as? AnimatedPreviewPopupCell else {
            return AnimatedPreviewPopupCell()
        }
        cell.layer.cornerRadius = 20
        let index = categoryListVM.indexOfCategory(name: categorys[indexPath.row])
        cell.backgroundColor = categoryListVM.item(at: index).color
        cell.updateLabel(text: categorys[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
        
        headerView.layer.cornerRadius = 20
        headerView.layer.borderWidth = 2
        headerView.layer.borderColor = UIColor.white.cgColor
        return headerView
    }
}

extension AnimatedPreviewPopupViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.bounds.width
        let height = width / 2
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width: CGFloat = collectionView.bounds.width
        let height = width / 2
        return CGSize(width: width, height: height)
    }
}

extension AnimatedPreviewPopupViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 클릭시 animatedPreview의 배경색이 바뀌며 해당 카테고리만 재생된다.
        animatedPreviewVM.changeSelectedCategory(category: categorys[indexPath.row])
        animatedPreviewVM.changeAnimatedPreview(isReset: false)
        dismiss(animated: false, completion: nil)
    }
}

class AnimatedPreviewPopupCell: UICollectionViewCell {
    @IBOutlet weak var categoryLabel: UILabel!
    
    func updateLabel(text: String) {
        categoryLabel.text = text
    }
}

