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
    @IBOutlet weak var speedPickerView: UIPickerView!
    @IBOutlet weak var selectionPanelCV: UICollectionView!
    
    @IBOutlet weak var gifView: UIView!
    @IBOutlet weak var pngView: UIView!
    @IBOutlet weak var gifBtn: UIButton!
    @IBOutlet weak var pngBtn: UIButton!
    @IBOutlet weak var pngLabel: UILabel!
    
    var superViewController: ViewController!
    var exportFramePanelCVC: ExportFramePanelCVC!
    var exportCategoryPanelCVC: ExportCategoryPanelCVC!
    var frameDataArr: [FrameData]!
    var selectedFrameCount: Int!
    var categoryData: [String]!
    var categoryDataNums: [Int]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSideCorner(target: backgroundView, side: "top", radius: backgroundView.frame.width / 25)
        setSideCorner(target: pngView, side: "all", radius: pngView.frame.height / 4)
        setSideCorner(target: gifView, side: "all", radius: gifView.frame.height / 4)
        setViewShadow(target: pngView, radius: 3, opacity: 0.3)
        setViewShadow(target: gifView, radius: 3, opacity: 0.3)
        
        // init picker row
        speedPickerView.selectRow(1, inComponent: 0, animated: true)
        
        // init various
        frameDataArr = []
        categoryData = []
        categoryDataNums = []
        selectedFrameCount = 0
        
        // get time data
        guard let time = superViewController.timeMachineVM.presentTime else { return }
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
    
    override func viewWillDisappear(_ animated: Bool) {
        // start animated image
        let view = superViewController.panelContainerViewController.previewImageToolBar.animatedPreview!
        view.startAnimating()
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
        
    }
    
    @IBAction func tappedSave(_ sender: Any) {
        var images: [UIImage]
        
        images = []
        for frameData in frameDataArr {
            if (frameData.isSelected) {
                images.append(frameData.data.renderedImage)
            }
        }

        if ExportImageManager().generateGif(photos: images, filename: "/file.gif", speed: "1") {
            ExportImageManager().saveGifToCameraRoll(filename: "/file.gif")
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
        return 10
    }
}

extension ExportViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (row == 0) {
            return "Speed"
        }
        return String(row)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel

        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "System", size: 16)
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = row == 0 ? "Speed" : String(row)
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
