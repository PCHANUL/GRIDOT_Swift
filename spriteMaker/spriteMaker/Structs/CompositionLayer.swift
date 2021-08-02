//
//  CompositionLayer.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/07/28.
//

import UIKit

struct Time {
    var frames: [Frame]
    var selectedFrame: Int
    var selectedLayer: Int
}

struct Frame {
    var layers: [Layer?]
    var renderedImage: UIImage
    var category: String
}

struct Layer {
    var gridData: String
    var renderedImage: UIImage
    var ishidden: Bool
}
