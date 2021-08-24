//
//  ExportViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/07.
//

import UIKit
import ImageIO
import MobileCoreServices
import Photos
import AssetsLibrary

class ExportViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var pngBtn: UIButton!
    @IBOutlet weak var gifBtn: UIView!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var speedPickerView: UIPickerView!
    @IBOutlet weak var selectionPanelCV: UICollectionView!
    
    var superViewController: ViewController!
    var framePanelCVC: FramePanelCVC!
    var categoryPanelCVC: CategoryPanelCVC!
    var frameData: [Frame]!
    var categoryData: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSideCorner(target: backgroundView, side: "top", radius: backgroundView.frame.width / 25)
        setSideCorner(target: pngBtn, side: "all", radius: pngBtn.frame.height / 4)
        setSideCorner(target: gifBtn, side: "all", radius: gifBtn.frame.height / 4)
        setSideCorner(target: clearBtn, side: "all", radius: clearBtn.frame.height / 4)
        setViewShadow(target: pngBtn, radius: 3, opacity: 0.3)
        setViewShadow(target: gifBtn, radius: 3, opacity: 0.3)
        setViewShadow(target: clearBtn, radius: 3, opacity: 0.3)
        
        speedPickerView.selectRow(1, inComponent: 0, animated: true)
        guard let time = superViewController.timeMachineVM.presentTime else { return }
        frameData = time.frames
        categoryData = []
        for frame in frameData {
            if categoryData.last == frame.category {
                // 중복된 수를 카운트
                categoryData[categoryData.count - 2] = String(Int(categoryData[categoryData.count - 2])! + 1)
            } else {
                categoryData.append("0")
                categoryData.append(frame.category)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // start animated image
        let view = superViewController.panelContainerViewController.previewImageToolBar.animatedPreview!
        view.startAnimating()
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
    
    @IBAction func tappedBackground(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedSave(_ sender: Any) {
        guard let time = superViewController.timeMachineVM.presentTime else {
            return
        }
        let images = time.frames.map { frame in
            return frame.renderedImage
        }

        if generateGif(photos: images, filename: "/file.gif") {
            saveGifToCameraRoll(filename: "/file.gif")
            print("success")
        } else {
            print("failed")
        }
    }
    
    func generateGif(photos: [UIImage], filename: String) -> Bool {
        let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = documentsDirectoryPath.appending(filename)
        let cfURL = URL(fileURLWithPath: path) as CFURL
        
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 2]]
        let gifProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: 0.125]]
        
        if let destination = CGImageDestinationCreateWithURL(cfURL, kUTTypeGIF, photos.count, nil) {
                CGImageDestinationSetProperties(destination, fileProperties as CFDictionary?)
                for photo in photos {
                    CGImageDestinationAddImage(destination, photo.cgImage!, gifProperties as CFDictionary?)
                }
                return CGImageDestinationFinalize(destination)
            }
        return false
    }
    
    func saveGifToCameraRoll(filename: String) {
        if let docsDirectory = getDocumentsDirectory() {
            let fileUrl: URL = docsDirectory.appendingPathComponent(filename)
            do {
                let data = try Data(contentsOf: fileUrl)
                if let _ = UIImage(data: data) {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileUrl)
                        }, completionHandler: {completed, error in
                            if error != nil {
                                print("error")
                            } else if completed {
                                print("completed")
                            } else {
                                print("not completed")
                            }
                    })
                }
            } catch let error {
                print(error)
            }
        }
    }
    
    func getDocumentsDirectory() -> URL?  {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FramePanelCVC", for: indexPath) as! FramePanelCVC
            framePanelCVC = cell
            cell.superCollectionView = self
            cell.frames = frameData
            setViewShadow(target: cell, radius: 5, opacity: 0.3)
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryPanelCVC", for: indexPath) as! CategoryPanelCVC
            categoryPanelCVC = cell
            cell.superCollectionView = self
            cell.categorys = categoryData
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

class FramePanelCVC: UICollectionViewCell {
    @IBOutlet weak var frameCV: UICollectionView!
    var superCollectionView: ExportViewController!
    var frames: [Frame]!
    
}

extension FramePanelCVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return frames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FrameItemCVC", for: indexPath) as! FrameItemCVC
        cell.frameImage.image = frames[indexPath.row].renderedImage
        return cell
    }
}

extension FramePanelCVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.height - 5, height: self.frame.height - 5)
    }
}

extension FramePanelCVC: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        superCollectionView.categoryPanelCVC.categoryCV.contentOffset.x = scrollView.contentOffset.x
    }
}

class FrameItemCVC: UICollectionViewCell {
    @IBOutlet weak var frameImage: UIImageView!
    
}



class CategoryPanelCVC: UICollectionViewCell {
    @IBOutlet weak var categoryCV: UICollectionView!
    var superCollectionView: ExportViewController!
    var categorys: [String]!
    var categoryVM = CategoryListViewModel()
    var frameOneSideLen: CGFloat!
    
}

extension CategoryPanelCVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categorys.count / 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryItemCVC", for: indexPath) as! CategoryItemCVC
        let category = categorys[(indexPath.row * 2) + 1]
        cell.categoryLabel.text = category
        cell.backgroundColor = categoryVM.getCategoryColor(category: category)
        setSideCorner(target: cell, side: "all", radius: cell.frame.height / 2)
        return cell
    }
}

extension CategoryPanelCVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = frameOneSideLen! + ((frameOneSideLen! + 5) * CGFloat(Int(categorys[indexPath.row * 2])!))
        return CGSize(width: width, height: self.frame.height - 10)
    }
}

extension CategoryPanelCVC: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        superCollectionView.framePanelCVC.frameCV.contentOffset.x = scrollView.contentOffset.x
    }
}

class CategoryItemCVC: UICollectionViewCell {
    @IBOutlet weak var categoryLabel: UILabel!
    
}
