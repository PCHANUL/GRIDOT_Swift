//
//  DrawingToolViewModel.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/23.
//

import UIKit

class DrawingToolViewModel {
    private var drawingToolList: [DrawingTool] = []
    private var quickDrawingToolList: [DrawingTool] = []
    var superViewController: DrawingCollectionViewCell!
    var selectedToolIndex: Int = 0
    var buttonViewWidth: CGFloat!
    
    init(_ VC: DrawingCollectionViewCell) {
        superViewController = VC
        drawingToolList = [
            DrawingTool(name: "Line", extTools: [
                DrawingTool(name: "Line"),
                DrawingTool(name: "Square"),
            ]),
            DrawingTool(name: "Eraser"),
            DrawingTool(name: "Pencil"),
            DrawingTool(name: "Picker"),
            DrawingTool(name: "SelectSquare", extTools: [
                DrawingTool(name: "SelectSquare"),
                DrawingTool(name: "SelectLasso"),
            ]),
            DrawingTool(name: "Magic"),
            DrawingTool(name: "Paint"),
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
    
    func changeDrawingMode() {
        let constantValue: CGFloat!
        let widthValue: CGFloat!
        let drawingMode: String!
        
        drawingMode = superViewController.canvas.selectedDrawingMode
        buttonViewWidth = superViewController.canvas.frame.size.width / 7.5
        switch drawingMode {
        case "pen":
            constantValue = 0
            widthValue = superViewController.panelCollectionView.frame.size.width + buttonViewWidth
        case "touch":
            constantValue = -1 * buttonViewWidth
            widthValue = superViewController.panelCollectionView.frame.size.width - buttonViewWidth
        default:
            return
        }
        superViewController.panelWidthContraint.constant = constantValue
        superViewController.panelCollectionView.frame.size.width = widthValue
        superViewController.panelCollectionView.collectionViewLayout.invalidateLayout()
        superViewController.previewImageToolBar.previewAndLayerCVC.collectionViewLayout.invalidateLayout()
    }
}
