//
//  DrawingToolCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/03.
//

import UIKit

class DrawingToolCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var drawingToolCollection: UICollectionView!
    
    var drawingToolViewModel: DrawingToolViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

extension DrawingToolCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return drawingToolViewModel.numsOfTool
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DrawingToolCell", for: indexPath) as? DrawingToolCell else {
            return UICollectionViewCell()
        }
        let drawingTool = drawingToolViewModel.getItem(index: indexPath.row)
        cell.toolImage.image = UIImage(named: drawingTool.name)
        
        if indexPath.row == drawingToolViewModel.selectedToolIndex {
            cell.cellBG.backgroundColor = UIColor.black
        } else {
            cell.cellBG.backgroundColor = UIColor.clear
        }
        cell.cellHeight = cell.bounds.height
        return cell
    }
}

extension DrawingToolCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sideLength = drawingToolCollection.bounds.height / 2.2
        return CGSize(width: sideLength, height: sideLength)
    }
}

extension DrawingToolCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == drawingToolViewModel.selectedToolIndex {
            print("open options")
        }
        drawingToolViewModel.selectedToolIndex = indexPath.row
        drawingToolCollection.reloadData()
    }
}

class DrawingToolCell: UICollectionViewCell {
    @IBOutlet weak var toolImage: UIImageView!
    @IBOutlet weak var cellBG: UIView!
    var cellHeight: CGFloat!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cellBG.layer.cornerRadius = cellHeight / 7
        let triangle = TriangleView(frame: CGRect(x: 0, y: 0, width: cellHeight, height: cellHeight))
        triangle.backgroundColor = .clear
        self.addSubview(triangle)
    }
}

class DrawingToolViewModel {
    private var drawingToolList: [DrawingTool] = []
    private var quickDrawingToolList: [DrawingTool] = []
    var selectedToolIndex: Int = 0
    
    init() {
        drawingToolList = [
            DrawingTool(name: "Line"),
            DrawingTool(name: "Eraser"),
            DrawingTool(name: "Line"),
            DrawingTool(name: "Eraser"),
            DrawingTool(name: "Line"),
            DrawingTool(name: "Eraser"),
            DrawingTool(name: "Line"),
            DrawingTool(name: "Eraser"),
            DrawingTool(name: "Line"),
            DrawingTool(name: "Eraser"),
            DrawingTool(name: "Line"),
            DrawingTool(name: "Eraser"),
            DrawingTool(name: "Line"),
            DrawingTool(name: "Eraser"),
            DrawingTool(name: "Line"),
            DrawingTool(name: "Eraser"),
            DrawingTool(name: "Line"),
            DrawingTool(name: "Eraser"),
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
}

struct DrawingTool {
    var name: String
}


class TriangleView : UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let pos = rect.maxX
        
        context.beginPath()
        context.move(to: CGPoint(x: pos, y: pos * 0.85))
        context.addLine(to: CGPoint(x: pos, y: pos))
        context.addLine(to: CGPoint(x: pos * 0.85, y: pos))
        context.addLine(to: CGPoint(x: pos, y: pos * 0.85))
        context.closePath()

        context.setFillColor(UIColor.white.cgColor)
        context.fillPath()
    }
}
