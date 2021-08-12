//
//  HomeViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/05.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var userStatusView: UIView!
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBAction func tappedCloseBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setOneSideCorner(target: backgroundView, side: "all", radius: backgroundView.bounds.width / 20)
        setOneSideCorner(target: userStatusView, side: "all", radius: userStatusView.bounds.width / 15)
        setOneSideCorner(target: mainView, side: "all", radius: mainView.bounds.width / 20)
        setOneSideCorner(target: loginBtn, side: "all", radius: loginBtn.bounds.width / 20)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let destinationVC = segue.destination as? HomeMenuPanelViewController
//        
//    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeMenuCollectionViewCell", for: indexPath) as! HomeMenuCollectionViewCell
        switch indexPath.row {
        case 0:
            cell.label.text = "gallery"
        case 1:
            cell.label.text = "user"
        case 2:
            cell.label.text = "option"
        default:
            break
        }
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: mainView.bounds.width / 3 - 10, height: 30)
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected")
    }
}

class HomeMenuCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    
}
