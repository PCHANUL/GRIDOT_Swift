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
    private var selectedDataIndex: Int
    var hasIndexChanged: Bool = false
    
    override init() {
        let defaults = UserDefaults.standard
        if let dataIndex = (defaults.object(forKey: "selectedDataIndex") as? Int) {
            selectedDataIndex = dataIndex
        } else {
            defaults.setValue(0, forKey: "selectedDataIndex")
            selectedDataIndex = 0
        }
        
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        items = []
        super.init()
        retriveData()
        
        // create first data
        if (items.count == 0) {
            guard let emptyImage = UIImage(named: "empty")?.pngData() else { return }
            createData(title: "untitled", data: "", thumbnail: emptyImage)
        }
    }
    
    var selectedIndex: Int {
        return selectedDataIndex
    }
    
    func changeSelectedIndex(index: Int) {
        let defaults = UserDefaults.standard
        defaults.setValue(index, forKey: "selectedDataIndex")
        selectedDataIndex = index
        hasIndexChanged = true
    }
    
    func setSelectedIndexToFirst() {
        changeSelectedIndex(index: items.count - 1)
    }
    
    var numsOfData: Int {
        return items.count
    }
    
    var selectedData: Item {
        return items[selectedDataIndex]
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
    
    func createData(title: String, data: String, thumbnail: Data) {
        let newEntity = Item(context: self.context)
        newEntity.title = title
        newEntity.data = data
        newEntity.thumbnail = thumbnail
        saveData()
    }
    
    func copySelectedData() {
        let newEntity = Item(context: self.context)
        newEntity.title = items[selectedDataIndex].title
        newEntity.data = items[selectedDataIndex].data
        newEntity.thumbnail = items[selectedDataIndex].thumbnail
        saveData()
    }
    
    func deleteData(index: Int) {
        let itemToRemove = self.items[index]
        self.context.delete(itemToRemove)
        saveData()
    }
    
    func updateTitle(title: String, index: Int) {
        let itemToUpdate = self.items[index]
        itemToUpdate.title = title
        saveData()
    }
    
    func updateDataSelected(data: String) {
        let itemToUpdate = self.items[self.selectedDataIndex]
        itemToUpdate.data = data
        saveData()
    }
    
    func updateThumbnailSelected(thumbnail: Data) {
        let itemToUpdate = self.items[self.selectedDataIndex]
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
}


