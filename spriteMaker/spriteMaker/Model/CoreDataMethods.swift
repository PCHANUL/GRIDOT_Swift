//
//  CoreDataMethods.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/16.
//

import UIKit
import CoreData

class CoreData: NSObject {
    private let context: NSManagedObjectContext!
    private var items: [Item]
    
    override init() {
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        items = []
        super.init()
        retriveData()
        
        // create first data
        if (items.count == 0) {
            createData(title: "untitled", data: "", thumbnail: UIImage(named: "empty")!)
        }
    }
    
    var hasIndexChanged: Bool {
        let defaults = UserDefaults.standard
        if let dataIndex = (defaults.object(forKey: "hasIndexChanged") as? Bool) {
            return dataIndex
        } else {
            defaults.setValue(false, forKey: "hasIndexChanged")
            return false
        }
    }
    
    func changeHasIndexChanged(_ bool: Bool) {
        let defaults = UserDefaults.standard
        defaults.setValue(bool, forKey: "hasIndexChanged")
    }
        
    var selectedIndex: Int {
        let defaults = UserDefaults.standard
        if let dataIndex = (defaults.object(forKey: "selectedDataIndex") as? Int) {
            if (dataIndex >= items.count) { return items.count - 1}
            if (dataIndex < 0) { return 0 }
            return dataIndex
        } else {
            defaults.setValue(0, forKey: "selectedDataIndex")
            return 0
        }
    }
    
    func changeSelectedIndex(index: Int) {
        let defaults = UserDefaults.standard
        defaults.setValue(index, forKey: "selectedDataIndex")
        changeHasIndexChanged(true)
    }
    
    func setSelectedIndexToFirst() {
        changeSelectedIndex(index: items.count - 1)
    }
    
    var numsOfData: Int {
        return items.count
    }
    
    var selectedData: Item {
        return items[selectedIndex]
    }
    
    func getData(index: Int) -> Item? {
        if (index < 0 || index >= numsOfData) { return nil }
        return items[index]
    }
    
    func retriveData(callback: (() -> Void)? = nil) {
        do {
            self.items = try self.context.fetch(Item.fetchRequest())
            DispatchQueue.main.async {
                if ((callback) != nil) {
                    callback!()
                }
            }
        }
        catch let error as NSError {
            print("Failed to get data. \(error), \(error.userInfo)")
        }
    }
    
    func createData(title: String, data: String, thumbnail: UIImage) {
        let newEntity = Item(context: self.context)
        let pngData = transUIImageToPngData(image: thumbnail)
        newEntity.title = title
        newEntity.data = data
        newEntity.thumbnail = pngData
        saveData()
    }
    
    func copySelectedData() {
        let newEntity = Item(context: self.context)
        newEntity.title = items[selectedIndex].title
        newEntity.data = items[selectedIndex].data
        newEntity.thumbnail = items[selectedIndex].thumbnail
        saveData()
    }
    
    func deleteData(index: Int) {
        let itemToRemove = self.items[index]
        self.context.delete(itemToRemove)
        saveData()
        if (selectedIndex >= numsOfData) {
            changeSelectedIndex(index: selectedIndex - 1)
        }
    }
    
    func updateTitle(title: String, index: Int) {
        let itemToUpdate = self.items[index]
        itemToUpdate.title = title
        saveData()
    }
    
    func updateDataSelected(data: String) {
        print(selectedIndex, items.count)
        let itemToUpdate = items[selectedIndex]
        itemToUpdate.data = data
        saveData()
    }
    
    func updateThumbnailSelected(thumbnail: Data) {
        let itemToUpdate = items[selectedIndex]
        itemToUpdate.thumbnail = thumbnail
        saveData()
    }
    
    func saveData() {
        do {
            try self.context.save()
        }
        catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        retriveData()
    }
    
    func transUIImageToPngData(image: UIImage) -> Data {
        if let data = image.pngData() {
            return data
        } else {
            return (UIImage(named: "empty")?.pngData())!
        }
    }
}


