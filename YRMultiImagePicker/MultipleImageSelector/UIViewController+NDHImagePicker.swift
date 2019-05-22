//
//  UIViewController+YRImagePicker.swift
//
//  Created by Yogesh Rathore on 22/05/19.
//  Copyright © 2019 Yogesh Rathore. All rights reserved.
//

import UIKit
import Photos

public extension UIViewController {
    
    /// Present Image Picker using closures rather than delegation.
    ///
    /// - Parameters:
    ///   - imagePicker: the `YRImagePickerController`
    ///   - animated: is presentation animated
    ///   - select: notifies when selection of `[PHAsset]` has been made
    ///   - cancel: notifies when Image Picker has been cancelled by user
    ///   - completion: notifies when the Image Picker finished presenting
    public func presentYRImagePickerController(_ imagePicker: YRImagePickerController, animated: Bool, select: @escaping (([PHAsset]) -> Void), cancel: @escaping (() -> Void), completion: (() -> Void)? = nil) {
        let manager = YRImagePickerManager.shared
        manager.selectAssets = select
        manager.cancel = cancel
        imagePicker.imagePickerDelegate = manager
        present(imagePicker, animated: animated, completion: completion)
    }
}

class YRImagePickerManager: NSObject {
    var selectAssets: (([PHAsset]) -> Void)?
    var cancel: (() -> Void)?
    
    static var shared = YRImagePickerManager()
    override init() { }
}

extension YRImagePickerManager: YRImagePickerControllerDelegate {
    func imagePicker(_ picker: YRImagePickerController, didFinishPickingAssets assets: [PHAsset]) {
        selectAssets?(assets)
    }
    
    func imagePickerDidCancel(_ picker: YRImagePickerController) {
        cancel?()
    }
}
