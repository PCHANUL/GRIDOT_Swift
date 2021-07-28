//
//  CompositionLayer.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/07/28.
//

import UIKit

struct Frame {
    var layers: [Layer?]
    var frameImage: UIImage
    var category: String
}

struct Layer {
    var gridData: String
    var layerImage: UIImage
    var ishidden: Bool
}
