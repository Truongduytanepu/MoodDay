//
//  CIImageExtensions.swift
//  BabyPhoto
//
//  Created by VietLV on 8/5/20.
//  Copyright © 2020 Solar. All rights reserved.
//

import Foundation
import UIKit

extension CIImage {
    func toUIImage() -> UIImage {
           let context: CIContext = CIContext.init(options: nil)
           let cgImage: CGImage = context.createCGImage(self, from: self.extent)!
           let image: UIImage = UIImage.init(cgImage: cgImage)
           return image
    }
}
