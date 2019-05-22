//
//  PHAssetExtension.swift
//  ImagePicker
//
//  Created by Yogesh Rathore on 22/05/19.
//  Copyright © 2019 Yogesh Rathore. All rights reserved.
//

import Foundation
import Photos

extension PHAsset {
    
    /// Convert PHAsset into an UIImage
    var image : UIImage {
        var thumbnail = UIImage()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        let imageManager = PHCachingImageManager()
        imageManager.requestImage(for: self, targetSize: CGSize(width: self.pixelWidth, height: self.pixelHeight), contentMode: .aspectFit, options: options, resultHandler: { image, _ in
            thumbnail = image!
        })
        return thumbnail
    }
}
