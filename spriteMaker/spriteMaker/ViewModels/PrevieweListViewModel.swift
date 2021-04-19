//
//  PrevieweListViewModel.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/05.
//

import UIKit

class PreviewListViewModel {
    var items: [PreviewImage] = []
    var reloadPreviewList: () -> ()
    var reloadRemovedList: () -> ()
    var selectedCellIndex = 0
    
    init(reloadCanvas: @escaping () -> (), reloadPreviewList: @escaping () -> ()) {
        self.reloadPreviewList = reloadPreviewList
        self.reloadRemovedList = {
            reloadCanvas()
            reloadPreviewList()
        }
    }
    
    var numsOfItems: Int {
        return items.count
    }
    
    var selectedCellItem: PreviewImage {
        return items[selectedCellIndex]
    }
    
    func changeSelectedCellIndex(index: Int) {
        selectedCellIndex = index
    }
    
    func checkExist(at index: Int) -> Bool {
        return index + 1 <= self.numsOfItems
    }
    
    func initItem(previewImage: PreviewImage) {
        items.insert(previewImage, at: 0)
        reloadPreviewList()
    }
    
    func addItem() {
        items.insert(selectedCellItem, at: selectedCellIndex)
        selectedCellIndex += 1;
        reloadPreviewList()
    }
    
    func insertItem(at index: Int, _ item: PreviewImage) {
        items.insert(item, at: index)
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
        updateItem(at: selectedCellIndex, previewImage: previewImage)
    }
    
    func updateItem(at index: Int, previewImage: PreviewImage) {
        items[index] = previewImage
        reloadPreviewList()
    }
    
    func removeCurrentItem() {
        let _ = removeItem(at: selectedCellIndex)
    }
    
    func removeItem(at index: Int) -> PreviewImage {
        if numsOfItems == 1 { return item(at: 0) }
        let item = items.remove(at: selectedCellIndex)
        if (selectedCellIndex != 0) {
            selectedCellIndex -= 1
        }
        reloadRemovedList()
        return item
    }
}
