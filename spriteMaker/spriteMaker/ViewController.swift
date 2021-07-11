//
//  ViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/02/19.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var viewController: UIView!
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var scrollNav: UICollectionView!
    
    var panelContainerViewController: PanelContainerViewController!
    var canvas: Canvas!
    
    var scrollPosition: CGFloat!
    var scrollPanelNum: CGFloat!
    
    var scrollBeganPos: CGFloat!
    var scrollMovedPos: CGFloat!
    
    override func viewDidLoad() {
        scrollPosition = 0
        scrollPanelNum = 0
        scrollBeganPos = 0
        scrollMovedPos = 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as? PanelContainerViewController
        panelContainerViewController = destinationVC
        
        let numsOfPixels = 16
        let lengthOfOneSide = viewController.bounds.width * 0.9
        canvas = Canvas(lengthOfOneSide, numsOfPixels, panelContainerViewController)
        canvas.frame = CGRect(x: 0, y: 0, width: lengthOfOneSide, height: lengthOfOneSide)
        canvas.backgroundColor = .darkGray
        canvasView.addSubview(canvas)
        
        panelContainerViewController.canvas = canvas
        panelContainerViewController.superViewController = self
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NavCell", for: indexPath) as! NavCell
        if (indexPath.row == Int(scrollPanelNum) || indexPath.row == Int(scrollPanelNum) + 1) {
            cell.backgroundColor = UIColor.white
        } else {
            cell.backgroundColor = UIColor.darkGray
        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = (scrollNav.bounds.height / 4)
        return CGSize(width: 3, height: height)
    }
}

extension ViewController: UICollectionViewDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: scrollNav) else { return }
        scrollBeganPos = point.y
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: scrollNav) else { return }
        if (scrollBeganPos < point.y - 30 && scrollPanelNum != 2) {
            scrollPanelNum += 1
            scrollBeganPos = point.y
            scrollNav.reloadData()
            let height = (panelContainerViewController.panelCollectionView.bounds.width * 0.3) + 10
            panelContainerViewController.panelCollectionView.setContentOffset(CGPoint(x: 0, y: height * scrollPanelNum), animated: true)
        } else if (scrollBeganPos > point.y + 30 && scrollPanelNum != 0) {
            scrollPanelNum -= 1
            scrollBeganPos = point.y
            scrollNav.reloadData()
            let height = (panelContainerViewController.panelCollectionView.bounds.width * 0.3) + 10
            panelContainerViewController.panelCollectionView.setContentOffset(CGPoint(x: 0, y: height * scrollPanelNum), animated: true)
        }
    }
}

class NavCell: UICollectionViewCell {
}

