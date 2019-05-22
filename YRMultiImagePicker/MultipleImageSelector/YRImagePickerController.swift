//
//  YRImagePickerController.swift
//
//  Created by Yogesh Rathore on 22/05/19.
//  Copyright © 2019 Yogesh Rathore. All rights reserved.
//

import UIKit
import Photos

/// Image Picker Controller Delegate. Notifies when images are selected or image picker is cancelled.
@objc public protocol YRImagePickerControllerDelegate: class {
    
    /// Image Picker did finish picking images. Provides an array of `UIImage` selected. Also provides external
    /// images if they are used. Consider using setting `maximumSelectionsAllowed` when using this delegate method
    /// because several `UIImage` objects are stored in memory when you implement this delegate function.
    ///
    /// - Parameters:
    ///   - picker: the `YRImagePickerController`
    ///   - images: the array of `UIImage`
    @objc optional func imagePicker(_ picker: YRImagePickerController, didFinishPickingImages images: [UIImage])
    
    /// Image Picker did finish picking images. Provides an array of `PHAsset` selected.
    ///
    /// - Parameters:
    ///   - picker: the `YRImagePickerController`
    ///   - assets: the array of `PHAsset`
    @objc optional func imagePicker(_ picker: YRImagePickerController, didFinishPickingAssets assets: [PHAsset])
    
    /// Image Picker did cancel.
    ///
    /// - Parameter picker: the `YRImagePickerController`
    @objc optional func imagePickerDidCancel(_ picker: YRImagePickerController)
    
}

/// Image Picker Controller. Displays images from the Photo Library. Must check Photo Library permissions before attempting to display this controller.
open class YRImagePickerController: UINavigationController {
    /// Image Picker Delegate. Notifies when images are selected or image picker is cancelled.
    @objc open weak var imagePickerDelegate: YRImagePickerControllerDelegate? {
        didSet {
            let rootVC = viewControllers.first as? YRImagePickerRootViewController
            rootVC?.delegate = imagePickerDelegate
        }
    }
    
    /// Configuration to change Localized Strings
    @objc open var configuration: YRImagePickerConfiguration? {
        didSet {
            let rootVC = viewControllers.first as? YRImagePickerRootViewController
            rootVC?.configuration = configuration
        }
    }
    
    /// Custom Tint Color for overlay of selected images.
    @objc open var selectionTintColor: UIColor? {
        didSet {
            let rootVC = viewControllers.first as? YRImagePickerRootViewController
            rootVC?.selectionTintColor = selectionTintColor
        }
    }
    
    /// Custom Tint Color for selection image (checkmark).
    @objc open var selectionImageTintColor: UIColor? {
        didSet {
            let rootVC = viewControllers.first as? YRImagePickerRootViewController
            rootVC?.selectionImageTintColor = selectionImageTintColor
        }
    }
    
    /// Custom selection image (checkmark).
    @objc open var selectionImage: UIImage? {
        didSet {
            let rootVC = viewControllers.first as? YRImagePickerRootViewController
            rootVC?.selectionImage = selectionImage
        }
    }
    
    /// Maximum photo selections allowed in picker (zero or fewer means unlimited).
    @objc open var maximumSelectionsAllowed: Int = -1 {
        didSet {
            let rootVC = viewControllers.first as? YRImagePickerRootViewController
            rootVC?.maximumSelectionsAllowed = maximumSelectionsAllowed
        }
    }
    
    /// Allowed Media Types that can be fetched. See `PHAssetMediaType`
    open var allowedMediaTypes: Set<PHAssetMediaType>? {
        didSet {
            let rootVC = viewControllers.first as? YRImagePickerRootViewController
            rootVC?.allowedMediaTypes = allowedMediaTypes
        }
    }
    
    /// Allowed MediaSubtype that can be fetched. Can be applied as `OptionSet`. See `PHAssetMediaSubtype`
    open var allowedMediaSubtypes: PHAssetMediaSubtype? {
        didSet {
            let rootVC = viewControllers.first as? YRImagePickerRootViewController
            rootVC?.allowedMediaSubtypes = allowedMediaSubtypes
        }
    }
    
    /// Status Bar Preference (defaults to `default`)
    @objc open var statusBarPreference = UIStatusBarStyle.default
    
    /// Initializer
    public required init() {
        super.init(rootViewController: YRImagePickerRootViewController())
    }
    
    /// Initializer (Do not use this controller in Interface Builder)
    ///
    /// - Parameters:
    ///   - nibNameOrNil: the nib name
    ///   - nibBundleOrNil: the nib `Bundle`
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    /// Initializer (Do not use this controller in Interface Builder)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Cannot init \(String(describing: YRImagePickerController.self)) from Interface Builder")
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarPreference
    }
}
