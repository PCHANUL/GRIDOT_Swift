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
            let resizedImage = image.resize(newWidth: 50)
            guard let imageData = resizedImage.pngData() else {
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
            targetRef.getData(maxSize: 900000) { data, error in
                if let error = error {
                    observer.onError(error)
                }
                if let data = data,
                   let image = UIImage(data: data)
                {
                    observer.onNext(image)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}
