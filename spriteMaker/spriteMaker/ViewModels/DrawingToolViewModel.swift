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
    var superViewController: ViewController!
    var selectedToolIndex: Int = 0
    var constraint: NSLayoutConstraint!
    
    init(_ VC: ViewController) {
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
        constraint = superViewController.panelContainerViewController.panelCollectionView.leadingAnchor.constraint(equalTo: superViewController.panelContainerView.leadingAnchor, constant: 30)
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
        switch drawingMode {
        case "pen":
            constantValue = 0
            widthValue = superViewController.panelContainerView.frame.size.width + 30
        case "touch":
            constantValue = -30
            widthValue = superViewController.panelContainerView.frame.size.width - 30
        default:
            return
        }
        constraint.priority = UILayoutPriority(200)
        constraint = superViewController.panelContainerView.widthAnchor.constraint(equalTo: superViewController.canvasView.widthAnchor, constant: constantValue)
        superViewController.panelContainerView.frame.size.width = widthValue
        constraint.priority = UILayoutPriority(1000)
        constraint.isActive = true
        superViewController.panelContainerViewController.panelCollectionView.collectionViewLayout.invalidateLayout()
        superViewController.panelContainerViewController.previewImageToolBar.previewAndLayerCVC.collectionViewLayout.invalidateLayout()
    }
}
