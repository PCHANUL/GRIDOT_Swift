//
//  DataStructs.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/07/28.
//

import UIKit

struct Time {
    var frames: [Frame]
    var selectedFrame: Int
    var selectedLayer: Int
    var categoryList: [String] {
        var list: [String] = []
        for frame in frames {
            if (list.firstIndex(of: frame.category) == nil) {
                list.append(frame.category)
            }
        }
        return list
    }
    
    init(
        frames: [Frame] = [Frame()],
        selectedFrame: Int = 0,
        selectedLayer: Int = 0
    ) {
        self.frames = frames
        self.selectedFrame = selectedFrame
        self.selectedLayer = selectedLayer
    }
}

struct Frame {
    var layers: [Layer] = [Layer()]
    var renderedImage: UIImage = UIImage(named: "empty")!
    var category: String = "Default"
}

struct Layer {
    var gridData: String = ""
    var data: [Int] = generateInitGrid()
    var renderedImage: UIImage = UIImage(named: "empty")!
    var ishidden: Bool = false
}
