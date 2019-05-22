//
//  ImageSourceSelector.swift
//
//  Created by Yogesh Rathore on 22/05/19.
//  Copyright © 2019 Yogesh Rathore. All rights reserved.
//

import Foundation
import UIKit
import Photos

public class ImageSourceSelector {
    public var onImageSourceSelected: ((_ imagePickerController: YRImagePickerDisplayViewController) -> ())?
    
    public init() {
        
    }
    // Mark: Functiom to show alert to choose image from either gallery or camera
    
    /// Functiom to show alert to choose image from either gallery or camera
    ///
    /// - Parameter viewController: UIViewController
    public func showImageSelectionAlert(viewController: UIViewController) {
        // Create the alert controller
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        let selectFromGallery = UIAlertAction(title: "Select from Gallery", style: .default, handler:{ (UIAlertAction)in
            self.presentPermissionsIfNeeded(viewController: viewController, isCameraSelected: false)
        })
        let captureFromCamera = UIAlertAction(title: "Select from Camera", style: .default, handler:{ (UIAlertAction)in
            self.presentPermissionsIfNeeded(viewController: viewController, isCameraSelected: true)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(selectFromGallery)
        optionMenu.addAction(captureFromCamera)
        optionMenu.addAction(cancelAction)
        viewController.present(optionMenu, animated: true, completion: nil)
    }
    
    public func presentPermissionsIfNeeded(viewController: UIViewController, isCameraSelected: Bool) {
        if isCameraSelected {
            openCameraPermission(viewController: viewController)
        } else {
            openGalleryPermission(viewController: viewController)
        }
    }
    
    // Mark:: Open Gallery Permission
    public func openGalleryPermission(viewController: UIViewController){
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:  // The user has previously granted access to the camera.
            self.presentImageSelector(viewController: viewController, isCameraSelected: false)
            
        case .notDetermined: // The user has not yet been asked for camera access.
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    self.presentImageSelector(viewController: viewController, isCameraSelected: false)
                }
            })
        case .denied: // The user has previously denied access.
            print("Denied")
            self.presentGallerySettings()
            
            return
        case .restricted: // The user can't grant access due to restrictions.
            print("restricted")
            return
        }
    }
    
    //Mark:: Check Camera permission
    public func openCameraPermission(viewController: UIViewController){
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:  // The user has previously granted access to the camera.
            self.presentImageSelector(viewController: viewController, isCameraSelected: true)
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.presentImageSelector(viewController: viewController, isCameraSelected: true)

                }
            }
            
        case .denied: // The user has previously denied access.
            print("Denied")
            self.presentCameraSettings()
            
            return
        case .restricted: // The user can't grant access due to restrictions.
            print("restricted")
            return
        }
    }
    
    // Mark:: Open Gallery Setting
    public func presentGallerySettings() {
        let alertController = UIAlertController(title: "Permissions needed",
                                                message: "Gallery access is denied for this app. You can turn on Photos for this app in Settings.",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Later", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                        // Handle
                    })
                } else {
                    // Fallback on earlier versions
                }
            }
        })
        UIApplication.topViewController()!.present(alertController, animated: true)
    }
    
    // Mark:: Open Camera Setting
    public func presentCameraSettings() {
        let alertController = UIAlertController(title: "Permissions needed",
                                                message: "Camera access is denied for this app. You can turn on Camera for this app in Settings.",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                        // Handle
                    })
                } else {
                    // Fallback on earlier versions
                }
            }
        })
        
        UIApplication.topViewController()!.present(alertController, animated: true)
    }
    
    func presentImageSelector(viewController: UIViewController, isCameraSelected: Bool) {
        let controller = YRImagePickerDisplayViewController()
        controller.isCameraSelected = isCameraSelected
        if self.onImageSourceSelected != nil {
            self.onImageSourceSelected!(controller)
        }
        viewController.present(controller, animated: true, completion: nil)
    }
}
