//
//  PrevieweListViewModel.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/05.
//

import UIKit

class PreviewListViewModel {
    var items: [PreviewImage] = []
    var selectedPreview = 0
    var previewAndLayerCVC: PreviewAndLayerCollectionViewCell!
    
    init(_ cell: PreviewAndLayerCollectionViewCell) {
        previewAndLayerCVC = cell
    }
    
    var numsOfItems: Int {
        return items.count
    }
    
    var selectedCellItem: PreviewImage {
        return items[selectedPreview]
    }
    
    func reloadPreviewList() {
        guard let previewCell = previewAndLayerCVC else { return }
        guard let collection = previewCell.previewListCell.previewImageCollection else { return }
        collection.reloadData()
    }
    
    func reloadRemovedList() {
        let previewCell = previewAndLayerCVC.previewListCell
        previewCell.updateCanvasData()
        previewCell.previewImageCollection.reloadData()
    }
    
    func changeSelectedPreview(index: Int) {
        selectedPreview = index
    }
    
    func checkExist(at index: Int) -> Bool {
        return index + 1 <= self.numsOfItems
    }
    
    func addEmptyItem(isInit: Bool) {
        guard let image = UIImage(named: "empty") else { return }
        let previewImage = PreviewImage(image: image, category: "Default", imageCanvasData: "")
        if isInit {
            items.append(previewImage)
            reloadPreviewList()
        } else {
            insertItem(at: selectedPreview + 1, previewImage)
        }
    }
    
    func copyItem() {
        items.insert(selectedCellItem, at: selectedPreview)
        selectedPreview += 1
        reloadPreviewList()
    }
    
    func insertItem(at index: Int, _ item: PreviewImage) {
        items.insert(item, at: index)
        selectedPreview += 1
        reloadPreviewList()
    }
    
    func item(at index: Int) -> PreviewImage {
        if (index >= numsOfItems) {
            print("index: \(index)")
        }
        return items[index]
    }
    
    func getAllImages() -> [UIImage] {
        let images = items.map { item in
            return item.image
        }
        return images
    }
    
    func getCategorys() -> [String] {
        var categorys: [String] = []
        for item in items {
            if categorys.contains(where: { $0 == item.category }) == false {
                categorys.append(item.category)
            }
        }
        return categorys
    }
    
    func getCategoryImages(category: String) -> [UIImage] {
        var categoryImages: [UIImage] = []
        for item in items {
            if item.category == category {
                categoryImages.append(item.image)
            }
        }
        return categoryImages
    }
    
    func updateCurrentItem(previewImage: PreviewImage) {
        updateItem(at: selectedPreview, previewImage: previewImage)
    }
    
    func updateItem(at index: Int, previewImage: PreviewImage) {
        items[index] = previewImage
        reloadPreviewList()
    }
    
    func removeCurrentItem() {
        let _ = removeItem(at: selectedPreview)
    }
    
    func removeItem(at index: Int) -> PreviewImage {
        if numsOfItems == 1 { return item(at: 0) }
        let item = items.remove(at: index)
        if (selectedPreview != 0) {
            selectedPreview -= 1
        }
        reloadRemovedList()
        return item
    }
}
