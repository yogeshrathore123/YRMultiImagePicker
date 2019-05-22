//
//  YRImagePickerDisplayViewController.swift
//
//  Created by Yogesh Rathore on 22/05/19.
//  Copyright © 2019 Yogesh Rathore. All rights reserved.
//

import UIKit

public class YRImagePickerDisplayViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var imagePickerController : UIImagePickerController!
    public let yrImagePickerController = YRImagePickerController()

    var photos: [UIImage] = []
    var photosCollectionView: UICollectionView? = nil
    var getPhotosButton: UIButton? = nil
    var backgroundImageView: UIImageView? = nil
    var isPickerPresented: Bool = false
    public var onGetPhotosTapped: ((_ images: [UIImage]) -> ())?
    var isCameraSelected: Bool = false
    
    //Customisable components
    var previewCropImage = UIImage(named: "crop")
    var previewDeleteImage = UIImage(named: "delete")
    var previewCloseImage = UIImage(named: "close")
    var previewCropTintColor = UIColor.black
    var previewDeleteTintColor = UIColor.black
    var previewCloseTintColor = UIColor.black
    var getPhotosButtonTitle = "GET ALL IMAGES"
    var getPhotosButtonTextColor = UIColor.white
    var getPhotosButtonBackgroundColor = UIColor.red
    public var backgroundColor = UIColor.white
    public var backgroundImage: UIImage? = nil
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        if !isPickerPresented {
            setupViews()
            if isCameraSelected {
                captureFromCamera()
            } else {
                selectFromGallery()
            }
        }
    }
    
    /// Function to capture images using camera
    func captureFromCamera()
    {
        isPickerPresented = true
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true, completion: nil)
    }
    
    /// Function to select images from gallery
    func selectFromGallery()
    {
        isPickerPresented = true
        presentYRImagePickerController(yrImagePickerController, animated: true, select: { (assets) in
            self.photos = assets.map({$0.image})
            self.photosCollectionView?.reloadData()
            self.yrImagePickerController.dismiss(animated: true, completion: nil)
        }, cancel: {
        })
    }
    
    func setupViews() {
        self.view.backgroundColor = UIColor.white
        backgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        backgroundImageView?.image = backgroundImage
        self.view.addSubview(backgroundImageView!)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 50)/4, height: (UIScreen.main.bounds.width - 50)/4)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        photosCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 200), collectionViewLayout: layout)
        photosCollectionView?.dataSource = self
        photosCollectionView?.delegate = self
        photosCollectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")
        photosCollectionView?.backgroundColor = UIColor.clear
        self.view.backgroundColor = backgroundColor
        self.view.addSubview(photosCollectionView!)
        
        getPhotosButton = UIButton(frame: CGRect(x: (UIScreen.main.bounds.width/2) - 100, y: UIScreen.main.bounds.height - 100, width: 200, height: 60))
        getPhotosButton?.setTitle(getPhotosButtonTitle, for: .normal)
        getPhotosButton?.setTitleColor(getPhotosButtonTextColor, for: .normal)
        getPhotosButton?.backgroundColor = getPhotosButtonBackgroundColor
        getPhotosButton?.layer.cornerRadius = 30
        getPhotosButton?.addTarget(self, action: #selector(getPhotosTapped), for: .touchUpInside)
        self.view.addSubview(getPhotosButton!)
    }
    
    //MARK:- CollectionView Delegate and DataSource methods
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath)
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: myCell.frame.width, height: myCell.frame.width)
        imageView.image = self.photos[indexPath.row]
        
        let deleteButton = UIButton()
        deleteButton.frame = CGRect(x: myCell.frame.width - 20, y: -5, width: 25, height: 25)
        deleteButton.setImage(UIImage(named: "delete_image"), for: .normal)
        deleteButton.tag = indexPath.row
        deleteButton.addTarget(self, action: #selector(deleteIconTapped(sender:)), for: .touchUpInside)
        
        myCell.addSubview(imageView)
        myCell.addSubview(deleteButton)
        myCell.backgroundColor = UIColor.clear
        return myCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imagePreviewer: YRPhotoPreviewer = YRPhotoPreviewer(frame: self.view.frame)
        self.view.addSubview(imagePreviewer)
        imagePreviewer.setData(photos, current: indexPath.row)
        imagePreviewer.customiseCropIcon(image: previewCropImage, tintColor: previewCropTintColor)
        imagePreviewer.customiseDeleteIcon(image: previewDeleteImage, tintColor: previewDeleteTintColor)
        imagePreviewer.customiseCloseIcon(image: previewCloseImage, tintColor: previewCloseTintColor)
        imagePreviewer.titleTextColor = UIColor.black
        imagePreviewer.closeButtonTapped = {
            (items) in
            self.photos = items
            self.photosCollectionView?.reloadData()
        }
    }
    
    //MARK:- IBActions
    /// Function to get the selected photos
    @objc func getPhotosTapped() {
        if self.onGetPhotosTapped != nil {
            self.onGetPhotosTapped!(self.photos)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func deleteIconTapped(sender: UIButton) {
        self.photos.remove(at: sender.tag)
        self.photosCollectionView?.reloadData()
    }
    
    //MARK:- Functions to customise the toolbar icons and getPhotos Button
    public func customisePreviewCropIcon(image: UIImage?, tintColor: UIColor) {
        if image != nil {
            self.previewCropImage = image
        }
        self.previewCropTintColor = tintColor
    }
    
    public func customisePreviewDeleteIcon(image: UIImage?, tintColor: UIColor) {
        if image != nil {
            self.previewDeleteImage = image
        }
        self.previewDeleteTintColor = tintColor
    }
    
    public func customisePreviewCloseIcon(image: UIImage?, tintColor: UIColor) {
        if image != nil {
            self.previewCloseImage = image
        }
        self.previewCloseTintColor = tintColor
    }
    
    public func customiseGetPhotosButton(title: String, titleColor: UIColor, backgroundColor: UIColor){
        getPhotosButtonTitle = title
        getPhotosButtonTextColor = titleColor
        getPhotosButtonBackgroundColor = backgroundColor
    }
    
    
    /// Delegate method that gets called once image is selected using camera
    ///
    /// - Parameters:
    ///   - picker: UIImagePickerController
    ///   - info: info regarding the media picked
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.photos = []
        self.photos.append(image)
        self.photosCollectionView?.reloadData()
        dismiss(animated:true, completion: nil)
    }
}
