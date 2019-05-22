//
//  YRImagePickerRootViewController.swift
//
//  Created by Yogesh Rathore on 22/05/19.
//  Copyright © 2019 Yogesh Rathore. All rights reserved.
//

import UIKit
import Photos

/// Image Picker Root View Controller contains the logic for selecting images. The images are displayed in a `UICollectionView`, and multiple images can be selected.
open class YRImagePickerRootViewController: UIViewController {
    
    /// Delegate for Image Picker. Notifies when images are selected (done is tapped) or when the Image Picker is cancelled.
    open weak var delegate: YRImagePickerControllerDelegate?
    
    /// Configuration to change Localized Strings
    open var configuration: YRImagePickerConfiguration? {
        didSet {
            configuration?.updateStrings = configurationChanged
            if let configuration = self.configuration {
                configurationChanged(configuration)
            }
        }
    }
    
    /// `UICollectionView` for displaying photo library images
    open weak var collectionView: UICollectionView?
    
    /// Custom Tint Color for overlay of selected images.
    open var selectionTintColor: UIColor? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    /// Custom Tint Color for selection image (checkmark).
    open var selectionImageTintColor: UIColor? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    /// Custom selection image (checkmark).
    open var selectionImage: UIImage? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    /// Allowed Media Types that can be fetched. See `PHAssetMediaType`
    open var allowedMediaTypes: Set<PHAssetMediaType>? {
        didSet {
            updateFetchOptionPredicate()
        }
    }
    
    /// Allowed MediaSubtype that can be fetched. Can be applied as `OptionSet`. See `PHAssetMediaSubtype`
    open var allowedMediaSubtypes: PHAssetMediaSubtype? {
        didSet {
            updateFetchOptionPredicate()
        }
    }
    
    /// Maximum photo selections allowed in picker (zero or fewer means unlimited).
    open var maximumSelectionsAllowed: Int = -1
    
    /// Page size for paging through the Photo Assets in the Photo Library. Defaults to 100. Must override to change this value. Only works in iOS 9.0+
    public let pageSize = 100
    
    var photoAssets: PHFetchResult<PHAsset> = PHFetchResult()
    weak var doneButton: UIBarButtonItem?
    weak var cancelButton: UIBarButtonItem?
    
    internal var collectionViewLayout:YRImagePickerCollectionViewLayout? {
        return collectionView?.collectionViewLayout as? YRImagePickerCollectionViewLayout
    }
    
    internal lazy var fetchOptions: PHFetchOptions = {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchOptions
    }()
    
    @available(iOS 9.0, *)
    internal var fetchLimit: Int {
        get {
            return fetchOptions.fetchLimit
        }
        set {
            fetchOptions.fetchLimit = newValue
        }
    }
    
    private var photosCompleted = 0
    private var savedImages: [UIImage] = []
    private var imagesDict: [IndexPath: UIImage] = [:]
    private var showExternalImages = false
    private var selectedIndexPaths: [IndexPath] = []
    
    private lazy var cache: NSCache<NSIndexPath, NSData> = {
        let cache = NSCache<NSIndexPath, NSData>()
        cache.totalCostLimit = 128000000 //128 MB
        cache.countLimit = 100 // 100 images
        return cache
    }()
    
    
    /// Initializer
    public required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Initializer (Do not use this View Controller in Interface Builder)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Cannot init \(String(describing: YRImagePickerRootViewController.self)) from Interface Builder")
    }
    
    private func setup() {
        fetchPhotos()
        
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: YRImagePickerCollectionViewLayout())
        setup(collectionView: collectionView)
        view.addSubview(collectionView)
        self.collectionView = collectionView
        
        var constraints: [NSLayoutConstraint] = []
        constraints += [view.constraintEqualTo(with: collectionView, attribute: .top)]
        constraints += [view.constraintEqualTo(with: collectionView, attribute: .right)]
        
        //Lower priority to override left constraint for animations
        let leftCollectionViewConstraint = view.constraintEqualTo(with: collectionView, attribute: .left)
        leftCollectionViewConstraint.priority = UILayoutPriority(rawValue: 999)
        constraints += [leftCollectionViewConstraint]
        constraints += [view.constraintEqualTo(with: collectionView, attribute: .bottom)]
        NSLayoutConstraint.activate(constraints)
        view.layoutIfNeeded()
    }
    
    private func setup(collectionView: UICollectionView) {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(YRImagePickerCollectionViewCell.self, forCellWithReuseIdentifier: YRImagePickerCollectionViewCell.reuseId)
    }
    
    /// Function to fetch photos from gallery
    private func fetchPhotos() {
        requestPhotoAccessIfNeeded(PHPhotoLibrary.authorizationStatus())
        
        if #available(iOS 9.0, *) {
            fetchOptions.fetchLimit = pageSize
        }
        photoAssets = PHAsset.fetchAssets(with: fetchOptions)
        collectionView?.reloadData()
    }
    
    /// Function to fetch Option Predicate while fetching photos from gallery
    private func updateFetchOptionPredicate() {
        var predicates: [NSPredicate] = []
        if let allowedMediaTypes = self.allowedMediaTypes {
            let mediaTypesPredicates = allowedMediaTypes.map { NSPredicate(format: "mediaType = %d", $0.rawValue) }
            let allowedMediaTypesPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: mediaTypesPredicates)
            predicates += [allowedMediaTypesPredicate]
        }
        
        if let allowedMediaSubtypes = self.allowedMediaSubtypes {
            let mediaSubtypes = NSPredicate(format: "mediaSubtypes = %d", allowedMediaSubtypes.rawValue)
            predicates += [mediaSubtypes]
        }
        
        if predicates.count > 0 {
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            fetchOptions.predicate = predicate
        } else {
            fetchOptions.predicate = nil
        }
        fetchPhotos()
    }
    
    /// Load View
    open override func loadView() {
        view = UIView()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        navigationItem.title = configuration?.navigationTitle ?? NSLocalizedString("Photos", comment: "")
        
        let cancelButtonTitle = configuration?.cancelButtonTitle ?? NSLocalizedString("Cancel", comment: "")
        let cancelButton = UIBarButtonItem(title: cancelButtonTitle, style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.leftBarButtonItem = cancelButton
        self.cancelButton = cancelButton
        
        let doneButtonTitle = configuration?.doneButtonTitle ?? NSLocalizedString("Done", comment: "")
        let doneButton = UIBarButtonItem(title: doneButtonTitle, style: .done, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItem = doneButton
        self.doneButton = doneButton
    }
    
    //MARK:- IBActions
    @objc func cancelTapped() {
        dismiss(animated: true) { [weak self] in
            guard let imagePicker = self?.navigationController as? YRImagePickerController else { return }
            self?.delegate?.imagePickerDidCancel?(imagePicker)
        }
    }
    
    @objc func doneTapped() {
        guard let imagePicker = navigationController as? YRImagePickerController else { return }
        
        let indexPathsForSelectedItems = selectedIndexPaths
        guard indexPathsForSelectedItems.count  > 0 else {
            cancelTapped()
            return
        }
        
        var photoAssets: [PHAsset] = []
        for indexPath in indexPathsForSelectedItems {
            guard indexPath.item < self.photoAssets.count else { continue }
            photoAssets += [self.photoAssets.object(at: indexPath.item)]
        }
        delegate?.imagePicker?(imagePicker, didFinishPickingAssets: photoAssets)
        
        guard shouldExpandImagesFromAssets() else { return }
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        
        for asset in photoAssets {
            manager.requestImageData(for: asset, options: options, resultHandler: { [weak self] (data, _, _, _) in
                guard let strongSelf = self,
                    let data = data,
                    let image = UIImage(data: data) else { return }
                strongSelf.savedImages += [image]
            })
        }
        delegate?.imagePicker?(imagePicker, didFinishPickingImages: savedImages)
        savedImages = []
    }
    
    private func shouldExpandImagesFromAssets() -> Bool {
        //Only expand images if didFinishPickingAssets is implemented in delegate.
        if let delegate = self.delegate as? NSObject,
            delegate.responds(to: #selector(YRImagePickerControllerDelegate.imagePicker(_:didFinishPickingImages:))) {
            return true
        } else if !(delegate is NSObject) {
            return true
        }
        return false
    }
    
    private func set(image: UIImage?, indexPath: IndexPath, isExternal: Bool) {
        update(isSelected: image != nil, isExternal: isExternal, for: indexPath)
        
        // Only store images if delegate method is implemented
        if let nsDelegate = delegate as? NSObject,
            !nsDelegate.responds(to: #selector(YRImagePickerControllerDelegate.imagePicker(_:didFinishPickingImages:))) {
            return
        }
        
        let key = IndexPath(item: indexPath.item, section: isExternal ? 1 : 0)
        imagesDict[key] = image
    }
    
    private func update(isSelected: Bool, isExternal: Bool, for indexPath: IndexPath) {
        
        if isSelected && !isExternal {
            selectedIndexPaths += [indexPath]
        } else {
            selectedIndexPaths = selectedIndexPaths.filter { $0 != indexPath }
        }
    }
    
    private func get(imageForIndexPath indexPath: IndexPath, isExternal: Bool) -> UIImage? {
        let key = IndexPath(item: indexPath.item, section: isExternal ? 1 : 0)
        return imagesDict[key]
    }
    
    @available(iOS 9.0, *)
    private func fetchNextPageIfNeeded(indexPath: IndexPath) {
        guard indexPath.item == fetchLimit-1 else { return }
        
        let oldFetchLimit = fetchLimit
        fetchLimit += pageSize
        photoAssets = PHAsset.fetchAssets(with: fetchOptions)
        
        var indexPaths: [IndexPath] = []
        for item in oldFetchLimit..<photoAssets.count {
            indexPaths += [IndexPath(item: item, section: 0)]
        }
        collectionView?.insertItems(at: indexPaths)
    }
    
    private func requestPhotoAccessIfNeeded(_ status: PHAuthorizationStatus) {
        guard status == .notDetermined else { return }
        PHPhotoLibrary.requestAuthorization { [weak self] (_) in
            DispatchQueue.main.async { [weak self] in
                self?.photoAssets = PHAsset.fetchAssets(with: self?.fetchOptions)
                self?.collectionView?.reloadData()
            }
        }
    }
    
    private func configurationChanged(_ configuration: YRImagePickerConfiguration) {
        if let navigationTitle = configuration.navigationTitle {
            navigationItem.title = navigationTitle
        }
    }
}

// MARK: - Collection View Delegate
extension YRImagePickerRootViewController: UICollectionViewDelegate {
    
    /// Collection View did select item at `IndexPath`
    ///
    /// - Parameters:
    ///   - collectionView: the `UICollectionView`
    ///   - indexPath: the `IndexPath`
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? YRImagePickerCollectionViewCell,
            let image = cell.imageView.image else { return }
        set(image: image, indexPath: indexPath, isExternal: false)
    }
    
    /// Collection View did de-select item at `IndexPath`
    ///
    /// - Parameters:
    ///   - collectionView: the `UICollectionView`
    ///   - indexPath: the `IndexPath`
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        set(image: nil, indexPath: indexPath, isExternal: false)
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let cell = collectionView.cellForItem(at: indexPath) as? YRImagePickerCollectionViewCell,
            cell.imageView.image != nil else { return false }
        guard maximumSelectionsAllowed > 0 else { return true }
        
        let collectionViewItems = self.collectionView?.indexPathsForSelectedItems?.count ?? 0
        if maximumSelectionsAllowed <= collectionViewItems {
            //We exceeded maximum allowed, so alert user. Don't allow selection
            let message = configuration?.maximumSelectionsAllowedMessage ?? NSLocalizedString("You cannot select more than \(maximumSelectionsAllowed) images. Please deselect another image before trying to select again.", comment: "You cannot select more than (x) images. Please deselect another image before trying to select again. (YRImagePicker)")
            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            let okayString = configuration?.okayString ?? NSLocalizedString("OK", comment: "OK")
            let action = UIAlertAction(title: okayString, style: .cancel, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    
}

// MARK: - Collection View Data Source
extension YRImagePickerRootViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// Returns Collection View Cell for item at `IndexPath`
    ///
    /// - Parameters:
    ///   - collectionView: the `UICollectionView`
    ///   - indexPath: the `IndexPath`
    /// - Returns: Returns the `UICollectionViewCell`
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return photoAssetCollectionView(collectionView, cellForItemAt: indexPath)
    }
    
    private func photoAssetCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if #available(iOS 9.0, *) {
            fetchNextPageIfNeeded(indexPath: indexPath)
        }
        
        guard let layoutAttributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath),
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YRImagePickerCollectionViewCell.reuseId, for: indexPath) as? YRImagePickerCollectionViewCell else { return UICollectionViewCell() }
        let photoAsset = photoAssets.object(at: indexPath.item)
        cell.indexPath = indexPath
        cell.photoAsset = photoAsset
        cell.size = layoutAttributes.frame.size
        
        if let selectionTintColor = self.selectionTintColor {
            cell.selectionTintColor = selectionTintColor
        }
        if let selectionImageTintColor = self.selectionImageTintColor {
            cell.selectionImageTintColor = selectionImageTintColor
        }
        if let selectionImage = self.selectionImage {
            cell.selectionImage = selectionImage
        }
        
        return cell
    }
    
    /// Returns the number of items in a given section
    ///
    /// - Parameters:
    ///   - collectionView: the `UICollectionView`
    ///   - section: the given section of the `UICollectionView`
    /// - Returns: Returns an `Int` for the number of rows.
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoAssets.count
    }
    
}

