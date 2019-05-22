//
//  YRImagePickerCollectionViewCell.swift
//
//  Created by Yogesh Rathore on 22/05/19.
//  Copyright © 2019 Yogesh Rathore. All rights reserved. reserved.
//

import UIKit
import Photos

class YRImagePickerCollectionViewCell: UICollectionViewCell {
    static let scale: CGFloat = 3
    static let reuseId = String(describing: YRImagePickerCollectionViewCell.self)
    weak var overlayView: UIView?
    weak var overlayImageView: UIImageView?
    private var imageRequestID: PHImageRequestID?
    var indexPath: IndexPath?
    
    var photoAsset: PHAsset? {
        didSet {
            loadPhotoAssetIfNeeded()
        }
    }
    
    var size: CGSize? {
        didSet {
            loadPhotoAssetIfNeeded()
        }
    }
    
    var selectionTintColor: UIColor = UIColor.black.withAlphaComponent(0.8) {
        didSet {
            overlayView?.backgroundColor = selectionTintColor
        }
    }
    
    open var selectionImageTintColor: UIColor = .white {
        didSet {
            overlayImageView?.tintColor = selectionImageTintColor
        }
    }
    
    open var selectionImage: UIImage? {
        didSet {
            overlayImageView?.image = selectionImage?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    override var isSelected: Bool {
        set {
            setSelected(newValue, animated: true)
        }
        get {
            return super.isSelected
        }
    }
    
    func setSelected(_ isSelected: Bool, animated: Bool) {
        super.isSelected = isSelected
        updateSelected(animated)
    }
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lightGray
        contentView.addSubview(activityIndicator)
        contentView.addSubview(imageView)
        let constraintsToFill = contentView.constraintsToFill(otherView: imageView)
        let constraintsToCenter = contentView.constraintsToCenter(otherView: activityIndicator)
        NSLayoutConstraint.activate(constraintsToFill + constraintsToCenter)
        layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Function to load image into collectionView
    private func loadPhotoAssetIfNeeded() {
        guard let indexPath = self.indexPath,
            let asset = photoAsset, let size = self.size else { return }
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        let manager = PHImageManager.default()
        let newSize = CGSize(width: size.width * type(of: self).scale,
                             height: size.height * type(of: self).scale)
        activityIndicator.startAnimating()
        imageRequestID = manager.requestImage(for: asset, targetSize: newSize, contentMode: .aspectFill, options: options, resultHandler: { [weak self] (result, _) in
            guard self?.indexPath?.item == indexPath.item else { return }
            self?.activityIndicator.stopAnimating()
            self?.imageRequestID = nil
            self?.imageView.image = result
        })
    }
    
    private func updateSelected(_ animated: Bool) {
        if isSelected {
            addOverlay(animated)
        } else {
            removeOverlay(animated)
        }
    }
    
    ///Function to add overlay over selected
    ///
    /// - Parameter animated: Bool
    private func addOverlay(_ animated: Bool) {
        guard self.overlayView == nil && self.overlayImageView == nil else { return }
        let overlayView = UIView(frame: frame)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = selectionTintColor
        contentView.addSubview(overlayView)
        self.overlayView = overlayView
        let overlayImageView = UIImageView(frame: frame)
        overlayImageView.translatesAutoresizingMaskIntoConstraints = false
        overlayImageView.image = selectionImage ?? UIImage(named: "check-mark")?.withRenderingMode(.alwaysTemplate)
        overlayImageView.contentMode = .scaleAspectFit
        overlayImageView.tintColor = selectionImageTintColor
        overlayImageView.alpha = 0
        contentView.addSubview(overlayImageView)
        self.overlayImageView = overlayImageView
        let overlayViewConstraints = overlayView.constraintsToFill(otherView: contentView)
        let overlayImageViewConstraints = overlayImageView.constraintsToCenter(otherView: contentView)
        NSLayoutConstraint.activate(overlayImageViewConstraints + overlayViewConstraints)
        layoutIfNeeded()
        let duration = animated ? 0.2 : 0.0
        UIView.animate(withDuration: duration, animations: {
            overlayView.alpha = 0.7
            overlayImageView.alpha = 1
        })
    }
    
    
    /// Function to remove selected overlay
    ///
    /// - Parameter animated: Bool
    private func removeOverlay(_ animated: Bool) {
        guard let overlayView = self.overlayView,
            let overlayImageView = self.overlayImageView else {
                self.overlayView?.removeFromSuperview()
                self.overlayImageView?.removeFromSuperview()
                return
        }
        let duration = animated ? 0.2 : 0.0
        UIView.animate(withDuration: duration, animations: {
            overlayView.alpha = 0
            overlayImageView.alpha = 0
        }, completion: { (_) in
            overlayView.removeFromSuperview()
            overlayImageView.removeFromSuperview()
        })
    }
}
