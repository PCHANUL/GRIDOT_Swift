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
    @IBOutlet weak var popupArror: UIImageView!
    @IBOutlet weak var popupNum: UILabel!
    @IBOutlet weak var removeView: UIView!
    @IBOutlet weak var removeButton: UIButton!
    
    var popupRectY: CGFloat!
    var popupArrorX: CGFloat!
    
    var selectedCell: Int!
    var viewModel: PreviewListViewModel!
    var previewListViewController: PreviewListViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bottomInset = UIApplication.shared.windows[0].safeAreaInsets.bottom / 2
        let topSafeArea = UIApplication.shared.windows[0].safeAreaInsets.top
        let topAnchor = popupRectY! - topSafeArea
        let leadingAnchor = popupArrorX! - popupArror.frame.width / 2
        
        removeView.heightAnchor.constraint(equalToConstant: removeView.frame.height + bottomInset).isActive = true
        removeButton.centerYAnchor.constraint(equalTo: removeView.centerYAnchor, constant: bottomInset / -2).isActive = true
        popupOption.topAnchor.constraint(equalTo: popupSuperView.topAnchor, constant: topAnchor).isActive = true
        popupArror.leadingAnchor.constraint(equalTo: popupOption.leadingAnchor, constant: leadingAnchor).isActive = true
        
        popupNum.text = "#\(selectedCell!)"
    }
    
    @IBAction func handlePan(_ gesture: UIPanGestureRecognizer) {
        let center = popupSuperView.frame.height / 2
        
        switch gesture.state {
        case .changed:
            let movement = popupSuperView.center.y + gesture.translation(in: popupOption).y
            if movement > center {
                popupSuperView.center.y = popupSuperView.center.y + gesture.translation(in: popupOption).y
                gesture.setTranslation(CGPoint.zero, in: popupSuperView)
            }
        case .ended:
            if popupSuperView.frame.minY > popupSuperView.frame.height / 10 {
                dismiss(animated: true, completion: nil)
            } else {
                popupSuperView.center.y = center
            }
        default: break
        }
    }
    
    @IBAction func tappedRemoveButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        let _ = viewModel.removeItem(at: selectedCell!)
    }
    @IBAction func closePopup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    let category = ["Default", "Jump", "Attack"]
}

extension PreviewOptionPopupViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return category.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else {
            return UICollectionViewCell()
        }
        cell.categoryName.text = category[indexPath.row]
        return cell
    }
}

extension PreviewOptionPopupViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(category[indexPath.row])
    }
}

extension PreviewOptionPopupViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let margin: CGFloat = 10
        let height = categoryCollectionView.bounds.height - margin * 2
        let width = height * 2
        
        return CGSize(width: width, height: height)
    }
}

class CategoryCell: UICollectionViewCell {
    @IBOutlet weak var categoryName: UILabel!
}



// [] 팝업창에 들어가는 옵션들
// - [x] 셀 제거
// - [x] 셀 정보
// - [] 셀 배경변경

// 만약에 셀 분류가 되면 animatedPreview를 클릭하여 특정 분류만 볼 수 있어야 한다.
// [] 특정 분류만 보기
// [] 일시정지
//


