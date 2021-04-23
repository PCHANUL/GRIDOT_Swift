//
//  ColorPaletteListViewModel.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/01.
//

import UIKit

class ColorPaletteListViewModel {
    private var colorPaletteList: [ColorPalette] = []
    var selectedPaletteIndex: Int = 0
    var selectedColorIndex: Int = -1
    
    var colorCollectionList: UICollectionView!
    var paletteCollectionList: UICollectionView!
    
    init() {
        // 기본 팔레트를 넣거나 저장되어있는 팔레트를 불러옵니다
        colorPaletteList = [
            ColorPalette(name: "Fantasy 24", colors: ["#1f240a", "#39571c", "#a58c27", "#efac28", "#efd8a1", "#ab5c1c", "#183f39", "#ef692f", "#efb775", "#a56243", "#773421", "#724113", "#2a1d0d", "#392a1c", "#684c3c", "#927e6a", "#276468", "#ef3a0c", "#45230d", "#3c9f9c", "#9b1a0a", "#36170c", "#550f0a", "#300f0a"]),
            ColorPalette(name: "Sweetie 16", colors: ["#1a1c2c", "#5d275d", "#b13e53", "#ef7d57", "#ffcd75", "#a7f070", "#38b764", "#257179", "#29366f", "#3b5dc9", "#41a6f6", "#73eff7", "#f4f4f4", "#94b0c2", "#566c86", "#333c57"]),
            ColorPalette(name: "Vinik 24", colors: ["#000000", "#6f6776", "#9a9a97", "#c5ccb8", "#8b5580", "#c38890", "#a593a5", "#666092", "#9a4f50", "#c28d75", "#7ca1c0", "#416aa3", "#8d6268", "#be955c", "#68aca9", "#387080", "#6e6962", "#93a167", "#6eaa78", "#557064", "#9d9f7f", "#7e9e99", "#5d6872", "#433455"]),
            ColorPalette(name: "Resurrect 64", colors: ["#2e222f", "#3e3546", "#625565", "#966c6c", "#ab947a", "#694f62", "#7f708a", "#9babb2", "#c7dcd0", "#ffffff", "#6e2727", "#b33831", "#ea4f36", "#f57d4a", "#ae2334", "#e83b3b", "#fb6b1d", "#f79617", "#f9c22b", "#7a3045", "#9e4539", "#cd683d", "#e6904e", "#fbb954", "#4c3e24", "#676633", "#a2a947", "#d5e04b", "#fbff86", "#165a4c", "#239063", "#1ebc73", "#91db69", "#cddf6c", "#313638", "#374e4a", "#547e64", "#92a984", "#b2ba90", "#0b5e65", "#0b8a8f", "#0eaf9b", "#30e1b9", "#8ff8e2", "#323353", "#484a77", "#4d65b4", "#4d9be6", "#8fd3ff", "#45293f", "#6b3e75", "#905ea9", "#a884f3", "#eaaded", "#753c54", "#a24b6f", "#cf657f", "#ed8099", "#831c5d", "#c32454", "#f04f78", "#f68181", "#fca790", "#fdcbb0"]),
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
        if selectedColorIndex == -1 { return "#e0e0e0" }
        print(selectedColorIndex)
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
}
