//
//  PreviewListViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/02/22.
//

import UIKit

class PreviewListViewController: UIViewController {
    
    @IBOutlet weak var previewCollectionView: UICollectionView!
    let viewModel = PreviewListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension PreviewListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numsOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewCell", for: indexPath) as? PreviewCell else {
            return UICollectionViewCell()
        }
        
        let preview = viewModel.item(at: indexPath.item)
        cell.updatePreview(item: preview, index: indexPath.item)
        
        if cell.seletedIndex == indexPath.item {
            cell.previewCell.layer.borderWidth = 3
            cell.previewCell.layer.borderColor = UIColor.yellow.cgColor
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FooterCell", for: indexPath)
            footerView.backgroundColor = UIColor.gray
            return footerView
        default:
           assert(false, "Unexpected element kind")
        }
    }
}

extension PreviewListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PreviewCell else { return }
        
        // [] 만약에 이전에 선택한 셀과 같은 셀을 선택한다면 선택 옵션팝업을 띄운다.
        cell.contentView.backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
        cell.tappedPreview(index: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PreviewCell else { return }
        cell.contentView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }
}

extension PreviewListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sideLength = view.bounds.height
        return CGSize(width: sideLength, height: sideLength)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let sideLength = view.bounds.height
        return CGSize(width: sideLength, height: sideLength)
    }
}

class PreviewListViewModel {
    private var items: [PreviewImage] = []
    
    var numsOfItems: Int {
        return items.count
    }
    
    func addItem(image item: UIImage) {
        items.append(PreviewImage(image: item))
        print(items)
    }
    
    func item(at index: Int) -> PreviewImage {
        return items[index]
    }
    
    func updateItem(at index: Int, image item: UIImage) {
        items[index] = PreviewImage(image: item)
    }
}

class PreviewCell: UICollectionViewCell {
    
    @IBOutlet weak var previewCell: UIView!
    @IBOutlet weak var previewImage: UIImageView!
    
    var index: Int!
    var seletedIndex: Int!
    
    func updatePreview(item: PreviewImage, index: Int) {
        previewImage.image = item.image
        self.index = index
    }
    
    func tappedPreview(index: Int) {
        self.seletedIndex = index
    }
}

class FooterCell: UICollectionViewCell {
    @IBOutlet weak var addButton: UIButton!
    
    // [] addButton을 클릭하면 새로운 화면을 생성합니다.
    // - [] 마지막 화면의 내용을 복제하여 생성
    // - [] 분류선택(배경색 선택)
    
    
}

struct PreviewImage {
    let image: UIImage
}
