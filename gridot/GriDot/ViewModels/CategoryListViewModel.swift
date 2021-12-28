//
//  CategoryListViewModel.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/07/31.
//

import UIKit

class CategoryListViewModel {
    private var categorys: [Category] = [
        Category(text: "Default", color: UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1)),
        Category(text: "Move", color: UIColor(red: 25/255, green: 122/255, blue: 60/255, alpha: 1)),
        Category(text: "Jump", color: UIColor(red: 158/255, green: 146/255, blue: 13/255, alpha: 1)),
        Category(text: "Attack", color: UIColor(red: 153/255, green: 53/255, blue: 14/255, alpha: 1)),
        Category(text: "Skill", color: UIColor(red: 90/255, green: 0/255, blue: 146/255, alpha: 1)),
    ]
    
    func addCategory(newCategory: Category) {
        categorys.append(newCategory)
    }
    
    var numsOfCategory: Int {
        return categorys.count
    }
    
    func getCategoryColor(category: String) -> UIColor {
        let index = indexOfCategory(name: category)
        if (index == -1) {
            return UIColor.clear
        }
        let category = item(at: index)
        return category.color
    }
    
    func item(at index: Int) -> Category {
        return categorys[index]
    }
    
    func indexOfCategory(name text: String) -> Int {
        return categorys.firstIndex(where: { $0.text == text }) ?? -1
    }
    
    func updateCategory(category: Category) {
        let index = self.indexOfCategory(name: category.text)
        if index != -1 {
            categorys[index] = category
        }
    }
    
    func removeCategory(category: Category) {
        let index = self.indexOfCategory(name: category.text)
        categorys.remove(at: index)
    }
}

struct Category {
    let text: String
    let color: UIColor
}
