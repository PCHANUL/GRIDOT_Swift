//
//  DrawingToolCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/10/20.
//

import UIKit

class DrawingToolCell: UICollectionViewCell {
    @IBOutlet weak var toolImage: UIImageView!
    @IBOutlet weak var cellBG: UIView!
    var cellHeight: CGFloat!
    var isExtToolExist: Bool!
    var cellIndex: Int!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setSideCorner(target: cellBG, side: "all", radius: cellHeight / 7)
        drawExtToolTriangle()
    }
    
    func drawExtToolTriangle() {
        if isExtToolExist {
            let triangle = TriangleCornerView(frame: CGRect(x: 0, y: 0, width: cellHeight, height: cellHeight))
            triangle.backgroundColor = .clear
            self.addSubview(triangle)
        } else {
            for subview in self.subviews where subview is TriangleCornerView {
                subview.removeFromSuperview()
            }
        }
    }
}
