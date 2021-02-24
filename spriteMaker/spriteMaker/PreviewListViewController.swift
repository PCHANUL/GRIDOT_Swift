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
    var canvas: Canvas!
    
    var selectedCell = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tappedAdd(_ sender: Any) {
        // 마지막 아이템을 복제하여 추가합니다.
        // [] 현재 셀을 마지막으로 바꾼다.
        // [] 마지막 셀의 이미지를 변환하여 추가한다.
        // [] 새로 추가된 셀로 selectedCell을 바꾼다
        
        let lastIndex = viewModel.numsOfItems - 1
        let lastItem = viewModel.item(at: lastIndex)
        viewModel.addItem(image: lastItem.image, item: lastItem.imageCanvasData)
        canvas.setNeedsDisplay()
        previewCollectionView.reloadData()
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
        
        if  indexPath.item == selectedCell {
            cell.contentView.layer.borderWidth = 2
            cell.contentView.layer.borderColor = UIColor.white.cgColor
        }
        
        cell.index = indexPath.item
        return cell
    }
}

extension PreviewListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // [] 만약에 이전에 선택한 셀과 같은 셀을 선택한다면 선택 옵션팝업을 띄운다.
        // [] 셀을 클릭하면 캔버스 화면이 변경된다.
        
        selectedCell = indexPath.item
        let canvasData = viewModel.item(at: indexPath.item).imageCanvasData
        
        canvas.changeCanvas(index: indexPath.item, canvasData: canvasData)
    }
}

extension PreviewListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sideLength = view.bounds.height
        return CGSize(width: sideLength, height: sideLength)
    }
}

class PreviewListViewModel {
    var items: [PreviewImage] = []
    
    var numsOfItems: Int {
        return items.count
    }
    
    func checkExist(at index: Int) -> Bool {
        return index + 1 <= self.numsOfItems
    }
    
    func addItem(image item: UIImage, item imageCanvasData: String) {
        items.append(PreviewImage(image: item, imageCanvasData: imageCanvasData))
    }
    
    func item(at index: Int) -> PreviewImage {
        return items[index]
    }
    
    func updateItem(at index: Int, image item: UIImage, item imageCanvasData: String) {
        items[index] = PreviewImage(image: item, imageCanvasData: imageCanvasData)
    }
}

class PreviewCell: UICollectionViewCell {
    
    @IBOutlet weak var previewCell: UIView!
    @IBOutlet weak var previewImage: UIImageView!
    
    var index: Int!
    var isSelectedCell: Bool = false
    
    func updatePreview(item: PreviewImage, index: Int) {
        previewImage.image = item.image
        self.index = index
    }
    
}

struct PreviewImage {
    let image: UIImage
    let imageCanvasData: String
}
