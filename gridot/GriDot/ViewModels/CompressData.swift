//
//  CompressData.swift
//  GriDot
//
//  Created by 박찬울 on 2022/02/06.
//

import UIKit

enum DataDiv: Int {
    case category = -3
    case isHidden = -2
    case grid = -16
}

// selectedFrame, selectedLayer, frame category, layer isHidden, layer data
func compressDataInt32(frames: [Frame], selectedFrame: Int, selectedLayer: Int) -> [Int] {
    var data: [Int] = []
    let categoryModel = CategoryListViewModel()
    
    data.append(contentsOf: [selectedFrame, selectedLayer])
    for frame in frames {
        data.append(contentsOf: [-3, categoryModel.indexOfCategory(name: frame.category)])
        for layer in frame.layers {
            data.append(contentsOf: [-2, layer.ishidden ? 1 : 0])
            data.append(-16)
            compressGridData(&data, layer.data)
        }
    }
    return data
}

func compressGridData(_ tarArr: inout [Int], _ grid: [Int]) {
    if (grid.count == 0) {
        tarArr.append(contentsOf: [-1, 256])
        return
    }
    var count = 0
    var prev = grid[0]
    
    for ele in grid {
        if (ele == prev) {
            count += 1
        } else {
            tarArr.append(contentsOf: [prev, count])
            prev = ele
            count = 1
        }
    }
    tarArr.append(contentsOf: [prev, count])
}

func getDataOverwrittenBySelectedArea(frames: [Frame], selectedFrame: Int, selectedLayer: Int, selectedData: [Int]) -> [Frame] {
    var result = frames
    var layerData = result[selectedFrame].layers[selectedLayer].data
    for i in 0..<selectedData.count {
        if (selectedData[i] != -1) {
            layerData[i] = selectedData[i]
        }
    }
    result[selectedFrame].layers[selectedLayer].data = layerData
    return result
}

func decompressDataInt32(_ data: [Int], _ imageSize: CGSize) -> Time? {
    let renderingManager = RenderingManager(imageSize, false)
    print(data)
    var time = Time(frames: [], selectedFrame: Int(data[0]), selectedLayer: Int(data[1]))
    var idx_data = 2
    var idx_frame = -1
    var idx_layer = -1
    
    while (idx_data < data.count) {
        switch DataDiv.init(rawValue: data[idx_data]) {
        case .category:
            idx_data += 1
            idx_frame += 1
            idx_layer = -1
            addNewFrame(&time.frames, data, &idx_data)
            idx_data += 1
        case .isHidden:
            idx_data += 1
            idx_layer += 1
            addNewLayer(&time.frames[idx_frame].layers, data, &idx_data)
            idx_data += 1
        case .grid:
            idx_data += 1
            setLayerData(&time.frames[idx_frame].layers[idx_layer], data, &idx_data)
            setLayerImage(&time.frames[idx_frame].layers[idx_layer], renderingManager)
            if (idx_data > data.count - 1 || data[idx_data] == -3) {
                setFrameImage(&time.frames[idx_frame], renderingManager)
            }
        default:
            break
        }
    }
    return time
}

fileprivate func addNewFrame(_ frames: inout [Frame], _ data: [Int], _ idx_data: inout Int) {
    let category = CategoryListViewModel().item(at: Int(data[idx_data])).text
    
    frames.append(Frame(layers: [], category: category))
}

fileprivate func addNewLayer(_ layers: inout [Layer], _ data: [Int], _ idx_data: inout Int) {
    let isHidden = (data[idx_data] == 1)
    
    layers.append(Layer(ishidden: isHidden))
}

fileprivate func setLayerData(_ layer: inout Layer, _ data: [Int], _ idx_data: inout Int) {
    var grid: [Int] = []

    while (idx_data < data.count - 1 && data[idx_data] >= -1) {
        let intColor = data[idx_data]
        let nums = data[idx_data + 1]
        
        grid.append(contentsOf: Array(repeating: intColor, count: nums))
        idx_data += 2
    }
    if (grid.count == 0) {
        grid = generateInitGrid()
    }
    layer.data = grid
}

fileprivate func setLayerImage(_ layer: inout Layer, _ renderer: RenderingManager) {
    let image = renderer.renderLayerImageInt32(data: layer.data)
    layer.renderedImage = image
}

fileprivate func setFrameImage(_ frame: inout Frame, _ renderer: RenderingManager) {
    let frameImage = renderer.renderFrameImage(frame.layers)
    frame.renderedImage = frameImage
}

func decompressData(_ data: String, size: CGSize) -> Time? {
    var resultTime: Time
    let frameStrs: [String.SubSequence]
    let selectedIndex: [Substring.SubSequence]
    
    resultTime = Time(frames: [], selectedFrame: 0, selectedLayer: 0)
    
    // split by line
    frameStrs = data.split(separator: "\n")
    if (frameStrs.count == 0) { return nil }
    
    // set selected index
    selectedIndex = frameStrs[0].split(separator: "|")
    if (selectedIndex.count != 2) { return resultTime }
    resultTime.selectedFrame = Int(selectedIndex[0])!
    resultTime.selectedLayer = Int(selectedIndex[1])!
    
    for frameIndex in 1..<frameStrs.count {
        var strArr: [Substring.SubSequence]
        var newFrame: Frame
        var index: Int
        
        // splited [category, ishidden, gridData, ishidden, gridData, ... ]
        strArr = frameStrs[frameIndex].split(separator: "|")
        newFrame = Frame(
            layers: [],
            renderedImage: UIImage(),
            category: CategoryListViewModel().item(at: Int(strArr[0])!).text
        )
        
        // set layers
        index = 1
        while (index < strArr.count) {
            let image: UIImage
            
            if (strArr[index + 1] == "none") {
                image = UIImage(named: "empty")!
                strArr[index + 1] = ""
            } else {
                image = UIImage(named: "empty")!
            }
            newFrame.layers.append(
                Layer(
                    gridData: String(strArr[index + 1]),
                    data: [],
                    renderedImage: image,
                    ishidden: strArr[index] == "0" ? false : true
                )
            )
            index += 2
        }
        
        // render frame image
        resultTime.frames.append(newFrame)
    }
    return resultTime
}
