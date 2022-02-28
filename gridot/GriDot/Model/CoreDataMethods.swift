//
//  CoreDataMethods.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/16.
//

import UIKit
import CoreData
import AuthenticationServices

enum Entities {
    case asset
    case palette
    case tool
    case user
}

class CoreData {
    static let shared: CoreData = CoreData()
    
    private let context: NSManagedObjectContext!
    private var assets: [Asset]
    private var palettes: [Palette]
    private var tools: [Tool]
    private var user: [User]
    var selectedAssetIndex: Int
    var selectedPaletteIndex: Int
    var selectedColorIndex: Int
    var selectedToolIndex: Int
    var hasIndexChanged: Bool
    
    let toolList = [
        DrawingTool(name: "Line", extTools: ["Square", "SquareFilled"]),
        DrawingTool(name: "Undo", extTools: []),
        DrawingTool(name: "Pencil", extTools: []),
        DrawingTool(name: "Redo", extTools: []),
        DrawingTool(name: "Eraser", extTools: []),
        DrawingTool(name: "Picker", extTools: []),
        DrawingTool(name: "SelectSquare", extTools: ["SelectLasso"]),
        DrawingTool(name: "Magic", extTools: []),
        DrawingTool(name: "Hand", extTools: []),
        DrawingTool(name: "Paint", extTools: []),
        DrawingTool(name: "Photo", extTools: []),
        DrawingTool(name: "Light", extTools: []),
        DrawingTool(name: "HideGrid", extTools: [])
    ]
    let subToolList = ["Line", "Pencil", "Eraser", "Picker",
                       "Paint", "Undo", "Hand"]
    
    init() {
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        assets = []
        palettes = []
        tools = []
        user = []

        selectedAssetIndex = 0
        selectedPaletteIndex = 0
        selectedColorIndex = -1
        selectedToolIndex = 0
        hasIndexChanged = false
        
        retriveData(entity: .asset)
        retriveData(entity: .palette)
        retriveData(entity: .tool)
        
        changeOldDataToNewDataType()
        
        if (assets.count == 0)
        { initAsset() }
        if (palettes.count == 0)
        { initPalette() }
        if (tools.count != toolList.count)
        { removeAllTools() }
        if (tools.count == 0)
        { initTouchTool() }
    }
    
    func changeOldDataToNewDataType() {
        for idx in 0..<assets.count {
            if (assets[idx].data!.count != 0) {
                guard var time = decompressData(
                    assets[idx].data!,
                    size: CGSize(width: 10, height: 10)
                ) else { continue }
                
                for frameIdx in 0..<time.frames.count {
                    let frame = time.frames[frameIdx]
                    for layerIdx in 0..<frame.layers.count {
                        let layer = frame.layers[layerIdx]
                        let gridData = matrixToUInt32(stringToMatrix(layer.gridData))
                        time.frames[frameIdx].layers[layerIdx].data = gridData
                        time.frames[frameIdx].layers[layerIdx].gridData = ""
                    }
                }
                let newTime = compressDataInt32(
                    frames: time.frames,
                    selectedFrame: time.selectedFrame,
                    selectedLayer: time.selectedLayer
                )
                assets[idx].gridData = newTime
                assets[idx].data = ""
                saveData(entity: .asset)
            }
        }
    }
    
    func retriveData(entity: Entities, callback: (() -> Void)? = nil) {
        do {
            switch entity {
            case .asset:
                self.assets = try self.context.fetch(Asset.fetchRequest())
            case .palette:
                self.palettes = try self.context.fetch(Palette.fetchRequest())
            case .tool:
                self.tools = try self.context.fetch(Tool.fetchRequest())
            case .user:
                self.user = try self.context.fetch(User.fetchRequest())
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
        case .asset:
            self.context.delete(self.assets[index])
            let isLast = selectedAssetIndex == numsOfAsset - 1
            selectedAssetIndex -= isLast ? 1 : 0
            hasIndexChanged = true
        case .palette:
            self.context.delete(self.palettes[index])
            selectedPaletteIndex -= selectedPaletteIndex == 0 ? 0 : 1
            if numsOfPalette == 0 { addPalette(name: "New Palette", colors: ["#FFFF00"]) }
        case .tool:
            self.context.delete(self.tools[index])
        case .user:
            self.context.delete(self.user[0])
        }
        saveData(entity: entity)
    }
    
    func reorderFunc(itemAt: Int, to: Int, swapFunc: (_ a: Int, _ b: Int)->Void) {
        var start = itemAt
        let dir = start > to ? -1 : 1
        
        while (start != to) {
            swapFunc(start, start + dir)
            start += dir
        }
    }
}

extension CoreData {
    var userId: String? {
        if (user.count == 0) { return nil }
        return user[0].userId
    }

    func addNewUser(authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            if (hasUserId(appleIDCredential.user) == false) { return }
            
            let newUser = User(context: self.context)
            newUser.userId = appleIDCredential.user
            newUser.email = appleIDCredential.email
            
            if let fullName = appleIDCredential.fullName {
                newUser.fullName = "\(fullName.givenName ?? "무명") \(fullName.familyName ?? "이")"
            }
            
            if let authorizationCode = appleIDCredential.authorizationCode,
               let identityToken = appleIDCredential.identityToken
            {
                newUser.authCode = String(data: authorizationCode, encoding: .utf8)
                newUser.idToken = String(data: identityToken, encoding: .utf8)
            }
        case let passwordCredential as ASPasswordCredential:
            print("aspassword", passwordCredential)
            let username = passwordCredential.user
            let password = passwordCredential.password
            print(username, password)
        default:
            break
        }
    }
    
    func hasUserId(_ userId: String) -> Bool {
        return (user.count != 0 && user[0].userId == userId)
    }
}

// touchTool
extension CoreData {
    func addTouchTool(main: String, sub: String, ext: [String]) {
        let newTool = Tool(context: self.context)
        newTool.main = main
        newTool.sub = sub
        newTool.ext = ext
        saveData(entity: .tool)
    }
    
    func removeAllTools() {
        for i in 0..<tools.count {
            self.context.delete(tools[i])
        }
        retriveData(entity: .tool, callback: nil)
    }
    
    func initTouchTool() {
        let _ = toolList.map { tool in
            addTouchTool(main: tool.name, sub: "none", ext: tool.extTools)
        }
        selectedToolIndex = 0
    }
    
    func getTool(index: Int) -> Tool {
        return tools[index]
    }
    
    var numsOfTools: Int {
        return tools.count
    }
    
    var selectedMainTool: String {
        return tools[selectedToolIndex].main!
    }
    
    var selectedSubTool: String {
        return tools[selectedToolIndex].sub!
    }
    
    var selectedExtTools: [String] {
        return tools[selectedToolIndex].ext!
    }
    
    func changeMainToolName(index: Int, name: String) {
        tools[index].main = name
        saveData(entity: .tool)
    }
    
    func changeSubTool(tool: String) {
        if (toolList.firstIndex(where: { item in
            if (item.name == tool) { return true }
            return item.extTools.firstIndex(of: tool) != nil
        }) == nil) { return }
        tools[selectedToolIndex].sub = tool
        saveData(entity: .tool)
    }
    
    func changeMainToExt(extIndex: Int) {
        let main = selectedMainTool
        let ext = selectedExtTools[extIndex]
        
        tools[selectedToolIndex].ext![extIndex] = main
        tools[selectedToolIndex].main = ext
        saveData(entity: .tool)
    }
    
    func swapTool(_ a: Int, _ b: Int) {
        let aMain = tools[a].main
        let aSub = tools[a].sub
        let aExt = tools[a].ext
        
        tools[a].main = tools[b].main
        tools[a].sub = tools[b].sub
        tools[a].ext = tools[b].ext
        tools[b].main = aMain
        tools[b].sub = aSub
        tools[b].ext = aExt
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
        selectedPaletteIndex = 0
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
    
    func getColorIndex(_ hex: String) -> Int {
        guard let palette = selectedPalette else { return -1 }
        
        if let index = palette.colors!.firstIndex(where: { $0 == hex }) {
            return index
        }
        return -1
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

// asset
extension CoreData {
    func changeSelectedAssetIndex(index: Int) {
        selectedAssetIndex = index
        hasIndexChanged = true
    }
    
    func setSelectedIndexToFirst() {
        changeSelectedAssetIndex(index: assets.count - 1)
    }
    
    var numsOfAsset: Int {
        return assets.count
    }
    
    var selectedAsset: Asset {
        return assets[selectedAssetIndex]
    }
    
    func getAsset(index: Int) -> Asset? {
        if (index < 0 || index >= numsOfAsset) { return nil }
        return assets[index]
    }
    
    func createAsset(title: String, data: String, gridData: [Int], thumbnail: UIImage) {
        let newAsset = Asset(context: self.context)
        let pngData = transUIImageToPngData(image: thumbnail)
        newAsset.title = title
        newAsset.data = data
        newAsset.gridData = gridData
        newAsset.thumbnail = pngData
        saveData(entity: .asset)
    }
    
    func createEmptyAsset() {
        createAsset(
            title: "untitled",
            data: "",
            gridData: [0, 0, -3, 0, -2, 0, -16, -1, 256],
            thumbnail: UIImage(named: "empty")!
        )
    }
    
    func initAsset() {
        createEmptyAsset()
        selectedAssetIndex = 0
    }
    
    func copySelectedAsset() {
        let newEntity = Asset(context: self.context)
        newEntity.title = assets[selectedAssetIndex].title
        newEntity.data = assets[selectedAssetIndex].data
        newEntity.thumbnail = assets[selectedAssetIndex].thumbnail
        saveData(entity: .asset)
    }
    
    func updateTitle(title: String, index: Int) {
        let assetToUpdate = assets[index]
        assetToUpdate.title = title
        saveData(entity: .asset)
    }
    
    func updateAssetSelected(data: String) {
        let assetToUpdate = assets[selectedAssetIndex]
        assetToUpdate.data = data
        saveData(entity: .asset)
    }
    
    func updateAssetSelectedDataInt(data: [Int]) {
        let assetToUpdate = assets[selectedAssetIndex]
        assetToUpdate.gridData = data
        saveData(entity: .asset)
    }
    
    func updateThumbnailSelected(thumbnail: Data) {
        let assetToUpdate = assets[selectedAssetIndex]
        assetToUpdate.thumbnail = thumbnail
        saveData(entity: .asset)
    }
    
    func swapAsset(_ a: Int, _ b: Int) {
        let aTitle = assets[a].title
        let aData = assets[a].data
        let aThumbnail = assets[a].thumbnail
        
        assets[a].title = assets[b].title
        assets[a].data = assets[b].data
        assets[a].thumbnail = assets[b].thumbnail
        
        assets[b].title = aTitle
        assets[b].data = aData
        assets[b].thumbnail = aThumbnail
    }
    
    func transUIImageToPngData(image: UIImage) -> Data {
        if let data = image.pngData() {
            return data
        } else {
            return (UIImage(named: "empty")?.pngData())!
        }
    }
}
