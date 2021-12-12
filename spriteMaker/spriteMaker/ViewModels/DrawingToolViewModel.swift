//
//  DrawingToolViewModel.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/23.
//

import UIKit

class DrawingToolViewModel {
    private var drawingToolList: [DrawingTool] = []
    var selectedToolIndex: Int = 0
    
    init() {
        drawingToolList = [
            DrawingTool(name: "Line", extTools: [
                DrawingTool(name: "Square"),
            ]),
            DrawingTool(name: "Undo"),
            DrawingTool(name: "Pencil"),
            DrawingTool(name: "Redo"),
            DrawingTool(name: "Eraser"),
            DrawingTool(name: "Picker"),
            DrawingTool(name: "SelectSquare", extTools: [
                DrawingTool(name: "SelectLasso"),
            ]),
            DrawingTool(name: "Magic"),
            DrawingTool(name: "Paint"),
            DrawingTool(name: "Photo"),
            DrawingTool(name: "Light")
        ]
    }
    
    var numsOfTool: Int {
        return drawingToolList.count
    }
    
    var selectedTool: DrawingTool {
        return drawingToolList[selectedToolIndex]
    }
    
    func getItem(index: Int) -> DrawingTool {
        return drawingToolList[index]
    }
    
    func currentItem() -> DrawingTool {
        return getItem(index: selectedToolIndex)
    }
    
    func changeCurrentItemName(name: String) {
        drawingToolList[selectedToolIndex].name = name
    }
}
