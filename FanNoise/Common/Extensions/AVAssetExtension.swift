//
//  AVAssetExtension.swift
//  BabyPhoto
//
//  Created by Le Toan on 9/10/20.
//  Copyright © 2020 Solar. All rights reserved.
//

import AVFoundation
import UIKit

extension AVAsset {
    var thumbnailImage: UIImage {
        var image = UIImage()
        do {
            let imgGenerator = AVAssetImageGenerator(asset: self)
            let cgImage = try! imgGenerator.copyCGImage(at: .zero, actualTime: nil)
            image = UIImage.init(cgImage: cgImage, scale: 1, orientation: image.imageOrientation)
            image = image.resize(to: CGSize(width: 800, height: 800))
        }
        return image
    }
    
    func assetID() -> String? {
       let metadata = self.metadata(forFormat: .quickTimeMetadata)
       for item in metadata {
           let keyContentIdentifier =  "com.apple.quicktime.content.identifier"
           let keySpaceQuickTimeMetadata = "mdta"
           if item.key as? String == keyContentIdentifier &&
               item.keySpace!.rawValue == keySpaceQuickTimeMetadata {
               return item.value as? String
           }
       }
        
       return nil
   }
   
   func exportToDocuments(filename:String, completion: @escaping (_ outputURL: URL) -> ()) -> Bool {
       var isExporting = false
       if let exportSession = AVAssetExportSession(asset: self, presetName: AVAssetExportPresetHighestQuality) {
           var documentsURL: URL?
            documentsURL = try? FileManager.default.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
           
           if let outputURL = documentsURL?.appendingPathComponent(filename) {
               if FileManager.default.fileExists(atPath: outputURL.path) {
                    try? FileManager.default.removeItem(atPath: outputURL.path)
               }
               
               exportSession.outputURL = outputURL
               exportSession.shouldOptimizeForNetworkUse = true
               exportSession.outputFileType = AVFileType.mov
               
               isExporting = true
               
               exportSession.exportAsynchronously(completionHandler: {
                   
                   if exportSession.status == .completed && exportSession.error == nil {
                       completion(outputURL)
                   }
               })
           }
       }
       
       return isExporting
   }
   
   func audioAsset() throws -> AVAsset {
       let composition = AVMutableComposition()
       let audioTracks = tracks(withMediaType: AVMediaType.audio)
       for track in audioTracks {
           let compositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
           do {
               try compositionTrack?.insertTimeRange(track.timeRange, of: track, at: track.timeRange.start)
           }
        
           compositionTrack?.preferredTransform = track.preferredTransform
       }
    
       return composition
   }
}
