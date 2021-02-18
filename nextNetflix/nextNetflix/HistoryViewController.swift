//
//  HistoryViewController.swift
//  nextNetflix
//
//  Created by 박찬울 on 2021/02/17.
//

import UIKit
import Firebase
import Kingfisher
import AVFoundation

class HistoryViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var searchedMovies: [SearchedMovie] = []
    
    let db = Database.database().reference().child("searchHistory")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        db.observeSingleEvent(of: .value) { snapshot in
            guard let searchHistory = snapshot.value as? [String: Any] else { return }
            let data = try! JSONSerialization.data(withJSONObject: Array(searchHistory.values), options: [])
            
            let decoder = JSONDecoder()
            let searchedMovies = try! decoder.decode([SearchedMovie].self, from: data)
            self.searchedMovies = searchedMovies.sorted(by: { (item1, item2) in
                return item1.timestamp > item2.timestamp
            })
            self.collectionView.reloadData()
        }
    }
}

extension HistoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchedMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HistoryCell", for: indexPath) as? HistoryCell else {
            return HistoryCell()
        }
        let searchedMovie = searchedMovies[indexPath.item]
        let url = URL(string: searchedMovie.thumbnailPath)!
        cell.searchedMovie.kf.setImage(with: url)
        return cell
    }
}

extension HistoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 선택된 cell의 영상을 실행시킵니다.
        
        let sb = UIStoryboard(name: "Player", bundle: nil)
        let vc = sb.instantiateViewController(identifier: "PlayerViewController") as! PlayerViewController
        
        guard let url = URL(string: searchedMovies[indexPath.row].previewURL) else { return }
        let item = AVPlayerItem(url: url)
        
        vc.modalPresentationStyle = .fullScreen
        vc.player.replaceCurrentItem(with: item)
        present(vc, animated: false, completion: nil)
    }
}

extension HistoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margin: CGFloat = 8
        let itemSpacing: CGFloat = 10
        
        let width = (collectionView.bounds.width - margin * 2 - itemSpacing * 2) / 3
        let height = width * 10/7
        return CGSize(width: width, height: height)
    }
}

class HistoryCell: UICollectionViewCell {
    @IBOutlet weak var searchedMovie: UIImageView!
}

struct SearchedMovie: Codable {
    let previewURL: String
    let thumbnailPath: String
    let timestamp: TimeInterval
}
