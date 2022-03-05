//
//  FireStorage.swift
//  
//
//  Created by 박찬울 on 2022/03/05.
//

import FirebaseStorage
import Foundation
import RxSwift

class FireStorage {
    static let shared: FireStorage = FireStorage()
    let storage = Storage.storage()
    let imagesRef: StorageReference
    
    init() {
        self.imagesRef = storage.reference().child("images")
    }
    
    func uploadNewImage(_ image: UIImage, _ imageTitle: String) -> Observable<URL> {
        return Observable<URL>.create { observer in
            guard let imageData = image.pngData() else {
                return Disposables.create()
            }
            let newImageRef = self.imagesRef.child(imageTitle)
            let _ = newImageRef.putData(imageData, metadata: nil) { (metaData, error) in
                if (error != nil) { return }
                newImageRef.downloadURL { (url, error) in
                    if (url != nil) {
                        observer.on(.next(url!))
                        observer.on(.completed)
                    }
                }
            }
            return Disposables.create()
        }
    }

    func downloadImage(_ path: String) -> Observable<UIImage> {
        return Observable<UIImage>.create { observer in
            let targetRef = self.imagesRef.child(path)
            
            targetRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if data != nil,
                   let image = UIImage(data: data!)
                {
                    observer.on(.next(image))
                    observer.on(.completed)
                }
            }
            return Disposables.create()
        }
    }
}
