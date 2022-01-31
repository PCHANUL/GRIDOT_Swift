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
}

struct Frame {
    var layers: [Layer]
    var renderedImage: UIImage
    var category: String
}

struct Layer {
    var gridData: String
    var data: [String: [Int32]]
    var renderedImage: UIImage
    var ishidden: Bool
}
