//
//  ExportDataStructs.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/26.
//

import UIKit

struct FrameData {
    let data: Frame
    var isSelected: Bool
}

struct ExportData {
    let title: String
    let imageSize: CGSize
    let imageBackgroundColor: CGColor
    let isCategoryAdded: Bool
    let frameDataArr: [FrameData]
}
