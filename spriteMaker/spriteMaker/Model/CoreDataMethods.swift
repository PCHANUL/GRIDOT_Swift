//
//  CoreDataMethods.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/16.
//

import UIKit
import CoreData

enum Entities {
    case item
    case palette
    case touchTool
}

class CoreData {
    static let shared: CoreData = CoreData()
    
    private let context: NSManagedObjectContext!
    private var items: [Item]
    private var palettes: [Palette]
    private var touchTools: [TouchTool]
    var selectedPaletteIndex: Int
    var selectedColorIndex: Int
    
    init() {
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        items = []
        palettes = []
        touchTools = []
        selectedPaletteIndex = 0
        selectedColorIndex = -1
        retriveData(entity: .item)
        retriveData(entity: .palette)
        retriveData(entity: .touchTool)
        
        // create first data
        if (items.count == 0)
        { initItem() }
        if (palettes.count == 0)
        { initPalette() }
        if (touchTools.count == 0)
        { initTouchTool() }
    }
    
    func retriveData(entity: Entities, callback: (() -> Void)? = nil) {
        do {
            switch entity {
            case .item:
                self.items = try self.context.fetch(Item.fetchRequest())
            case .palette:
                self.palettes = try self.context.fetch(Palette.fetchRequest())
            case .touchTool:
                self.touchTools = try self.context.fetch(TouchTool.fetchRequest())
            }
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
    
    func saveData(entity: Entities) {
        do {
            try self.context.save()
        }
        catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        retriveData(entity: entity)
    }
    
    func deleteData(entity: Entities, index: Int) {
        switch entity {
        case .item:
            self.context.delete(self.items[index])
        case .palette:
            self.context.delete(self.palettes[index])
            selectedPaletteIndex -= selectedPaletteIndex == 0 ? 0 : 1
            if numsOfPalette == 0 { addPalette(name: "New Palette", colors: ["#FFFF00"]) }
        case .touchTool:
            self.context.delete(self.touchTools[index])
        }
        saveData(entity: entity)
    }
    
    func reorderFunc(itemAt: Int, to: Int, swapFunc: (_ a: Int, _ b: Int)->Void, completion: (()->Void)? = nil) {
        var start = itemAt
        let dir = start > to ? -1 : 1
        
        while (start != to) {
            swapFunc(start, start + dir)
            start += dir
        }
        completion?()
    }
}

// touchTool
extension CoreData {
    func addTouchTool(main: String, sub: String) {
        let newTouchTool = TouchTool(context: self.context)
        newTouchTool.main = main
        newTouchTool.sub = sub
        saveData(entity: .touchTool)
    }
    
    func initTouchTool() {
        let mainArr = ["Line", "Square", "Undo", "Pencil", "Redo", "Eraser", "Picker", "SelectSquare", "SelectLasso", "Magic", "Paint", "Photo", "Light"]
        let _ = mainArr.map { main in
            addTouchTool(main: main, sub: "none")
        }
    }
}

// palette
extension CoreData {
    var numsOfPalette: Int {
        return palettes.count
    }
    
    var selectedPalette: Palette? {
        guard let palette = getPalette(index: selectedPaletteIndex) else { return nil }
        
        return palette
    }
    
    func initPalette() {
        let _ = ColorPaletteListViewModel().colorPaletteList.map { palette in
            addPalette(name: palette.name, colors: palette.colors)
        }
    }
    
    func addPalette(name: String, colors: [String]) {
        let newPalette = Palette(context: self.context)
        newPalette.name = name
        newPalette.colors = colors
        saveData(entity: .palette)
    }
    
    func getPalette(index: Int) -> Palette? {
        if (index > palettes.count) { return nil }
        
        return palettes[index]
    }
    
    func updatePalette(index: Int, palette: Palette) {
        palettes[index] = palette
        saveData(entity: .palette)
    }
    
    func swapPalette(_ a: Int, _ b: Int) {
        let aName = palettes[a].name
        let aColors = palettes[a].colors
        
        palettes[a].name = palettes[b].name
        palettes[a].colors = palettes[b].colors
        palettes[b].name = aName
        palettes[b].colors = aColors
    }
    
    // color
    var selectedColorArr: [String?] {
        guard let selectedPalette = selectedPalette else { return [] }
        
        return selectedPalette.colors!
    }
    
    var selectedColor: String? {
        let colors = selectedColorArr
        if (selectedColorIndex == -1) { return "none" }
        
        return colors[selectedColorIndex]
    }
    
    func addColor(color: String) {
        selectedPalette!.colors?.insert(color, at: 0)
        saveData(entity: .palette)
    }
    
    func removeColor(index: Int) {
        let colors = selectedColorArr
        if (colors.count < index) { return }
        let _ = palettes[selectedPaletteIndex].colors!.remove(at: index)
        
        saveData(entity: .palette)
    }
    
    func insertColor(a: Int, b: Int) {
        let aName = palettes[a].name
        let aColors = palettes[a].colors
        
        palettes[a].name = palettes[b].name
        palettes[a].colors = palettes[b].colors
        palettes[b].name = aName
        palettes[b].colors = aColors
        selectedPaletteIndex = b
        
        saveData(entity: .palette)
    }
    
    func swapColorOfSelectedPalette(_ a: Int, _ b: Int) {
        guard var colors = palettes[selectedPaletteIndex].colors else { return }
        let aColor = colors[a]
        
        colors[a] = colors[b]
        colors[b] = aColor
        palettes[selectedPaletteIndex].colors = colors
    }
    
}

// item
extension CoreData {
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
    
    func createData(title: String, data: String, thumbnail: UIImage) {
        let newEntity = Item(context: self.context)
        let pngData = transUIImageToPngData(image: thumbnail)
        newEntity.title = title
        newEntity.data = data
        newEntity.thumbnail = pngData
        saveData(entity: .item)
    }
    
    func initItem() {
        createData(title: "untitled", data: "", thumbnail: UIImage(named: "empty")!)
    }
    
    func copySelectedData() {
        let newEntity = Item(context: self.context)
        newEntity.title = items[selectedIndex].title
        newEntity.data = items[selectedIndex].data
        newEntity.thumbnail = items[selectedIndex].thumbnail
        saveData(entity: .item)
    }
    
    func updateTitle(title: String, index: Int) {
        let itemToUpdate = items[index]
        itemToUpdate.title = title
        saveData(entity: .item)
    }
    
    func updateDataSelected(data: String) {
        let itemToUpdate = items[selectedIndex]
        itemToUpdate.data = data
        saveData(entity: .item)
    }
    
    func updateThumbnailSelected(thumbnail: Data) {
        let itemToUpdate = items[selectedIndex]
        itemToUpdate.thumbnail = thumbnail
        saveData(entity: .item)
    }
    
    func swapData(_ a: Int, _ b: Int) {
        let aTitle = items[a].title
        let aData = items[a].data
        let aThumbnail = items[a].thumbnail
        
        items[a].title = items[b].title
        items[a].data = items[b].data
        items[a].thumbnail = items[b].thumbnail
        
        items[b].title = aTitle
        items[b].data = aData
        items[b].thumbnail = aThumbnail
    }
    
    func transUIImageToPngData(image: UIImage) -> Data {
        if let data = image.pngData() {
            return data
        } else {
            return (UIImage(named: "empty")?.pngData())!
        }
    }
}


