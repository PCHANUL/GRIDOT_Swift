//
//  ExportViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/07.
//

import UIKit

class ExportViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var selectionPanelCV: UICollectionView!
    @IBOutlet weak var speedPickerView: UIPickerView!
    
    @IBOutlet weak var gifView: UIView!
    @IBOutlet weak var pngView: UIView!
    @IBOutlet weak var gifBtn: UIButton!
    @IBOutlet weak var pngBtn: UIButton!
    @IBOutlet weak var pngLabel: UILabel!
    
    var exportFramePanelCVC: ExportFramePanelCVC!
    var exportCategoryPanelCVC: ExportCategoryPanelCVC!
    var frameDataArr: [FrameData]!
    var selectedFrameCount: Int!
    var categoryData: [String]!
    var categoryDataNums: [Int]!
    var selectedData: Item!
    
    var speedPickerItems = ["0.2", "0.4", "0.6", "Speed", "1.0", "1.2", "1.5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSideCorner(target: backgroundView, side: "top", radius: backgroundView.frame.width / 25)
        setSideCorner(target: pngView, side: "all", radius: pngView.frame.height / 4)
        setSideCorner(target: gifView, side: "all", radius: gifView.frame.height / 4)
        setViewShadow(target: pngView, radius: 3, opacity: 0.3)
        setViewShadow(target: gifView, radius: 3, opacity: 0.3)
        
        // init picker row
        speedPickerView.selectRow(speedPickerItems.firstIndex(of: "Speed")!, inComponent: 0, animated: true)
        
        // init various
        frameDataArr = []
        categoryData = []
        categoryDataNums = []
        selectedFrameCount = 0
        
        // get time data
        selectedData = CoreData().selectedData
        guard let time = TimeMachineViewModel()
                .decompressData(selectedData.data!, size: CGSize(width: 100, height: 100)) else { return }
        for frame in time.frames {
            
            // set frameDataArr
            frameDataArr.append(FrameData(data: frame, isSelected: false))
            
            // set categoryData
            // 중복된 카테고리의 수를 categoryDataNums에 저장
            if categoryData.last == frame.category {
                categoryDataNums[categoryData.count - 1] += 1
            } else {
                categoryData.append(frame.category)
                categoryDataNums.append(0)
            }
        }
    }

    @IBAction func tappedBackground(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedReset(_ sender: Any) {
        for index in 0..<frameDataArr.count {
            frameDataArr[index].isSelected = false
        }
        selectedFrameCount = 0
        checkSelectedFrameStatus()
    }
    
    @IBAction func tappedExportPng(_ sender: Any) {
        let exportImageManager: ExportImageManager
        let renderingManager: RenderingManager
        let sprite: UIImage
        let imageSize: CGSize
        
        imageSize = CGSize(width: 500, height: 500)
        exportImageManager = ExportImageManager()
        renderingManager = RenderingManager(imageSize)
       
        sprite = renderingManager.renderSprite(frameDataArr, selectedFrameCount)
        exportImageManager.savePngToCameraRoll(image: sprite)
    }
    
    @IBAction func tappedSave(_ sender: Any) {
        var images: [UIImage]
        let title: String
        var speed: Double
        
        images = []
        for frameData in frameDataArr {
            if (frameData.isSelected) {
                let newImage = ExportImageManager().getResizedFrameImage(
                    frame: frameData.data, size: CGSize(width: 500, height: 500))
                images.append(newImage)
            }
        }

        title = (selectedData.title == "" ? "untitled" : selectedData.title)!
        speed = Double(0.1) * (7 - Double(speedPickerView.selectedRow(inComponent: 0)))
        
        if ExportImageManager().generateGif(photos: images, filename: "/\(title).gif", speed: String(speed)) {
            ExportImageManager().saveGifToCameraRoll(filename: "/\(title).gif")
            print("success")
        } else {
            print("failed")
        }
    }
    
    func checkSelectedFrameStatus() {
        switch selectedFrameCount {
        case 0:
            resetBtn.layer.opacity = 0.5
            pngView.layer.opacity = 0.5
            gifView.layer.opacity = 0.5
            resetBtn.isEnabled = false
            pngBtn.isEnabled = false
            gifBtn.isEnabled = false
            pngLabel.text = "PNG"
        case 1:
            resetBtn.layer.opacity = 1
            pngView.layer.opacity = 1
            gifView.layer.opacity = 0.5
            resetBtn.isEnabled = true
            pngBtn.isEnabled = true
            gifBtn.isEnabled = false
            pngLabel.text = "PNG"
        default:
            resetBtn.layer.opacity = 1
            pngView.layer.opacity = 1
            gifView.layer.opacity = 1
            resetBtn.isEnabled = true
            pngBtn.isEnabled = true
            gifBtn.isEnabled = true
            pngLabel.text = "Sprite"
        }
        exportFramePanelCVC.frameCV.reloadData()
    }
}

extension ExportViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return speedPickerItems.count
    }
}

extension ExportViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel

        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "System", size: 16)
            pickerLabel?.textAlignment = .center
        }
        
        pickerLabel?.text = speedPickerItems[row]
        return pickerLabel!
    }
}

extension ExportViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExportFramePanelCVC", for: indexPath) as! ExportFramePanelCVC
            exportFramePanelCVC = cell
            cell.superCollectionView = self
            cell.frames = frameDataArr
            setViewShadow(target: cell, radius: 5, opacity: 0.3)
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExportCategoryPanelCVC", for: indexPath) as! ExportCategoryPanelCVC
            exportCategoryPanelCVC = cell
            cell.superCollectionView = self
            cell.categorys = categoryData
            cell.categoryNums = categoryDataNums
            cell.frameOneSideLen = ((selectionPanelCV.frame.height - 65) / 3 * 2) - 5
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

extension ExportViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (indexPath.row == 0) {
            return CGSize(
                width: selectionPanelCV.frame.width,
                height: (selectionPanelCV.frame.height - 65) / 3 * 2
            )
        } else {
            return CGSize(
                width: selectionPanelCV.frame.width,
                height: (selectionPanelCV.frame.height - 65) / 3
            )
        }
    }
}


func animateImages(_ data: Time?, targetImageView: UIImageView) {
    let images: [UIImage]
    
    if (data == nil) { return }
    images = data!.frames.map { frame in
        return frame.renderedImage
    }
    targetImageView.animationImages = images
    targetImageView.animationDuration = TimeInterval(images.count)
    targetImageView.startAnimating()
}
