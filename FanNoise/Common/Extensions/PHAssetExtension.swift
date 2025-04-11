//
//  PHAssetExtension.swift
//  BabyPhoto
//
//  Created by Thanh Vu on 7/20/20.
//  Copyright © 2020 Solar. All rights reserved.
//

import Foundation
import Photos
import UIKit
import MobileCoreServices

extension PHAsset {
    func thumbnail(size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        let option = PHImageRequestOptions()
        option.version = .current
        option.isNetworkAccessAllowed = true
        option.deliveryMode = .opportunistic
        option.isSynchronous = true

        var result: UIImage?
        PHImageManager.default().requestImage(for: self, targetSize: size, contentMode: .aspectFill, options: option) {(image, _) in
            result = image
        }
        
        return result
    }
    
    func getUIImage(completeHandler: @escaping(_ image: UIImage?) -> Void) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .current
        options.isSynchronous = false
        manager.requestImageData(for: self, options: options) { data, _, _, _ in
            
            if let data = data, let img = UIImage(data: data) {
                completeHandler(img)
            } else {
                completeHandler(nil)
            }
        }
    }
    
    func originalFileName() -> String? {
        if let resource = PHAssetResource.assetResources(for: self).first {
            return resource.originalFilename
        }
        
        return nil
    }
    
    static func fromLocalIdentifier(_ id: String) -> PHAsset? {
        let options = PHFetchOptions()
        options.fetchLimit = 1
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: options)
        return result.firstObject
    }

    func isGifType() -> Bool {
        if let identifier = self.value(forKey: "uniformTypeIdentifier") as? String {
             if identifier == kUTTypeGIF as String {
               return true
             }
        }
        return false
    }
    
    func getImageURL(completionHandler: @escaping (URL?) -> Void){
        if self.mediaType != .image {
            completionHandler(nil)
            return
        }
            
        var imageURL: URL?
        self.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (contentEditingInput, _) in
            if let input = contentEditingInput, let url = input.fullSizeImageURL {
                imageURL = url
            }
            completionHandler(imageURL)
        }
        
    }
    
    func getImage(targetWidth: CGFloat, completion: ((_ image: UIImage)->Void)?) {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.deliveryMode = .highQualityFormat
        option.resizeMode = .exact
        option.isNetworkAccessAllowed = true
        
        manager.requestImage(for: self, targetSize: CGSize.init(width: targetWidth, height: targetWidth), contentMode: .aspectFit, options: option) { (image, info) in
            completion?(image ?? UIImage())
        }
    }
}
