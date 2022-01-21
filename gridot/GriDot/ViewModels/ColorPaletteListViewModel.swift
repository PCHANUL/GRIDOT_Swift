//
//  ColorPaletteListViewModel.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/01.
//

import UIKit

class ColorPaletteListViewModel {
    var colorPaletteList: [ColorPalette] = []
    var selectedPaletteIndex: Int = 0
    var selectedColorIndex: Int = -1
    var pickerColor: String!
    
    var colorCollectionList: UICollectionView!
    var paletteCollectionList: UICollectionView!
    
    init() {
        // 기본 팔레트를 넣거나 저장되어있는 팔레트를 불러옵니다
        colorPaletteList = [
            ColorPalette(name: "Fantasy 24", colors: ["#1F240A", "#39571C", "#A58C27", "#EFAC28", "#EFD8A1", "#AB5C1C", "#183F39", "#EF692F", "#EFB775", "#A56243", "#773421", "#724113", "#2A1D0D", "#392A1C", "#684C3C", "#927E6A", "#276468", "#EF3A0C", "#45230D", "#3C9F9C", "#9B1A0A", "#36170C", "#550F0A", "#300F0A"]),
            ColorPalette(name: "Sweetie 16", colors: ["#1A1C2C", "#5D275D", "#B13E53", "#EF7D57", "#FFCD75", "#A7F070", "#38B764", "#257179", "#29366F", "#3B5DC9", "#41A6F6", "#73EFF7", "#F4F4F4", "#94B0C2", "#566C86", "#333C57"]),
            ColorPalette(name: "Vinik 24", colors: ["#000000", "#6F6776", "#9A9A97", "#C5CCB8", "#8B5580", "#C38890", "#A593A5", "#666092", "#9A4F50", "#C28D75", "#7CA1C0", "#416AA3", "#8D6268", "#BE955C", "#68ACA9", "#387080", "#6E6962", "#93A167", "#6EAA78", "#557064", "#9D9F7F", "#7E9E99", "#5D6872", "#433455"]),
            ColorPalette(name: "Resurrect 64", colors: ["#2E222F", "#3E3546", "#625565", "#966C6C", "#AB947A", "#694F62", "#7F708A", "#9BABB2", "#C7DCD0", "#FFFFFF", "#6E2727", "#B33831", "#EA4f36", "#f57D4A", "#AE2334", "#E83B3B", "#fB6B1D", "#f79617", "#f9C22B", "#7A3045", "#9E4539", "#CD683D", "#E6904E", "#fBB954", "#4C3E24", "#676633", "#A2A947", "#D5E04B", "#FBFF86", "#165A4C", "#239063", "#1EBC73", "#91DB69", "#CDDF6C", "#313638", "#374E4A", "#547E64", "#92A984", "#B2BA90", "#0B5E65", "#0B8A8F", "#0EAF9B", "#30E1B9", "#8FF8E2", "#323353", "#484A77", "#4D65B4", "#4D9BE6", "#8FD3FF", "#45293F", "#6B3E75", "#905EA9", "#A884F3", "#EAADED", "#753C54", "#A24B6F", "#CF657F", "#ED8099", "#831C5D", "#C32454", "#F04F78", "#F68181", "#FCA790", "#FDCBB0"])
        ]
    }
    
    var currentPalette: ColorPalette {
        return colorPaletteList[selectedPaletteIndex]
    }
    
    var numsOfPalette: Int {
        return colorPaletteList.count
    }
    
    func item(_ index: Int) -> ColorPalette {
        return colorPaletteList[index]
    }
    
    func changeSelectedPalette(index: Int) {
        selectedPaletteIndex = index
        reloadColorListAndPaletteList()
    }
    
    func reloadColorListAndPaletteList() {
        colorCollectionList.reloadData()
        if paletteCollectionList != nil {
            paletteCollectionList.reloadData()
        }
    }
    
    // palette
    func newPalette() {
        let newItem = ColorPalette(name: "New Palette", colors: ["#FFFF00"])
        colorPaletteList.insert(newItem, at: 0)
    }
    
    func renamePalette(index: Int, newName: String) {
        colorPaletteList[index].renamePalette(newName: newName)
    }
    
    func insertPalette(index: Int, palette: ColorPalette) {
        colorPaletteList.insert(palette, at: index)
    }
    
    func deletePalette(index: Int) -> ColorPalette {
        let removed = colorPaletteList.remove(at: index)
        selectedPaletteIndex -= selectedPaletteIndex == 0 ? 0 : 1
        if numsOfPalette == 0 { newPalette() }
        return removed
    }
    
    func updateSelectedPalette(palette: ColorPalette) {
        colorPaletteList[selectedPaletteIndex] = palette
        reloadColorListAndPaletteList()
    }
    
    func swapPalette(a: Int, b: Int) {
        let bPalette = colorPaletteList[b]
        colorPaletteList[b] = colorPaletteList[a]
        colorPaletteList[a] = bPalette
        reloadColorListAndPaletteList()
    }
    
    // color
    var currentColor: String {
        if (selectedColorIndex == -1) {
            if (pickerColor != nil) {
                return pickerColor
            } else {
                return "#ffffff"
            }
        }
        return colorPaletteList[selectedPaletteIndex].colors[selectedColorIndex]
    }
    
    func addColor(color: String) {
        colorPaletteList[selectedPaletteIndex].addColor(color: color)
    }
    
    func updateColor(color: String, colorIndex: Int) {
        colorPaletteList[selectedPaletteIndex].updateColor(index: colorIndex, color: color)
    }
    
    func removeColor(colorIndex: Int) {
        let _ = colorPaletteList[selectedPaletteIndex].removeColor(index: colorIndex)
    }
    
    func setPickerColor(_ color: UIColor) {
        pickerColor = color.hexa
        selectedColorIndex = -1
    }
    
    func initPickerColor() {
        pickerColor = nil
    }
}
