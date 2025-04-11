//
//  FileManagerExtensions.swift
//  BabyPhoto
//
//  Created by Thanh Vu on 6/24/20.
//  Copyright © 2020 Solar. All rights reserved.
//

import Foundation

extension FileManager {
    
    static func audioPath() -> String {
        return FileManager.documentPath().appending("/audios")
    }
    
    static func imagesPath() -> String {
        if !FileManager.default.fileExists(atPath: documentPath()+"/images") {
            try? FileManager.default.createDirectory(atPath: documentPath()+"/images", withIntermediateDirectories: true, attributes: nil)
        }
        return documentPath() + "/images"
    }
    
    static func documentPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
    }

    static func documentURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }

    static func downloadURL() -> URL {
        let path = self.downloadPath()
        return URL(fileURLWithPath: path)
    }
    
    static func downloadPath() -> String {
        return "\(NSTemporaryDirectory())download_session"
    }
    
    static func musicPath() -> String {
        return self.documentPath().appending("/music")
    }
    
    static func musicURL() -> URL {
        return URL(fileURLWithPath: self.musicPath())
    }

    static func createDownloadDirIfNeeded() {
        var isDirectoryOutput: ObjCBool = false
        let pointer = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
        pointer.initialize(from: &isDirectoryOutput, count: 1)

        if FileManager.default.fileExists(atPath: self.downloadPath(), isDirectory: pointer) == false ||
            isDirectoryOutput.boolValue == false {
            try? FileManager.default.createDirectory(at: self.downloadURL(), withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    static func createMusicDirIfNeeded() {
        var isDirectoryOutput: ObjCBool = false
        let pointer = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
        pointer.initialize(from: &isDirectoryOutput, count: 1)
        
        if FileManager.default.fileExists(atPath: self.musicPath(), isDirectory: pointer) == false || isDirectoryOutput.boolValue == false {
            try? FileManager.default.createDirectory(at: self.musicURL(), withIntermediateDirectories: true, attributes: nil)
        }
    }
}
