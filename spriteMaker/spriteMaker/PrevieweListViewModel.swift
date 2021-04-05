//
//  PrevieweListViewModel.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/05.
//

import UIKit

class PreviewListViewModel {
    private var items: [PreviewImage] = []
    var reloadPreviewList: () -> ()
    var reloadRemovedList: () -> ()
    
    init(reloadCanvas: @escaping () -> (), reloadPreviewList: @escaping () -> (), subtractSelectedCell: @escaping () -> ()) {
        self.reloadPreviewList = reloadPreviewList
        self.reloadRemovedList = {
            subtractSelectedCell()
            reloadCanvas()
            reloadPreviewList()
        }
    }
    
    var numsOfItems: Int {
        return items.count
    }
    
    func checkExist(at index: Int) -> Bool {
        return index + 1 <= self.numsOfItems
    }
    
    func addItem(previewImage: PreviewImage, selectedIndex: Int) {
        items.insert(previewImage, at: selectedIndex)
        reloadPreviewList()
    }
    
    func insertItem(at index: Int, _ item: PreviewImage) {
        items.insert(item, at: index)
    }
    
    func item(at index: Int) -> PreviewImage {
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
    
    func updateItem(at index: Int, previewImage: PreviewImage) {
        items[index] = previewImage
        reloadPreviewList()
    }
    
    func removeItem(at index: Int) -> PreviewImage {
        if numsOfItems == 1 { return item(at: 0) }
        let item = items.remove(at: index)
        reloadRemovedList()
        return item
    }
}
