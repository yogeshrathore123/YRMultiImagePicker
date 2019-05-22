//
//  YRPhotoPreviewer.swift
//
//  Created by Yogesh Rathore on 22/05/19.
//  Copyright © 2019 Yogesh Rathore. All rights reserved.
//

import UIKit

public class YRPhotoPreviewer: UIView, UIScrollViewDelegate, PKCCropDelegate {

    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet{
            scrollView.delegate = self
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = 10.0
        }
    }
    
    var currentIndex: Int = 0
    var totalCount: Int = 0
    var items: [UIImage] = []
    var pushAnimationEffect = CATransition()
    var closeButtonTapped: ((_ images: [UIImage]) -> ())?
    
    var titleTextColor: UIColor = UIColor.black {
        didSet {
            self.indexLabel.textColor = titleTextColor
        }
    }

    // Our custom view from the XIB file
    var view: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    public func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
        initialViewSetups()
    }
    
    /// Set images to the YRPhotoPreviewer and set current index
    ///
    /// - Parameters:
    ///   - items: the `images`
    ///   - current: the `current index of uiimage`
    func setData(_ items: [UIImage], current: Int) {
        self.items = items
        self.currentIndex = current
        totalCount = items.count
        if currentIndex < totalCount {
        } else if totalCount > 0 {
            self.currentIndex = 0
        }
        self.imageView.isHidden = false
        let image = items[currentIndex]
        self.imageView.image = image
        updateIndexLabel()
    }
    
    fileprivate func initialViewSetups() {
        addSwipeGestureRecognizers()
        pushAnimationEffect.duration = 0.3
        pushAnimationEffect.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    }
    
    fileprivate func addSwipeGestureRecognizers() {
        let leftSwipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(self.handleSwipe(_:)))
        leftSwipe.direction = .left
        leftSwipe.numberOfTouchesRequired = 1
        let rightSwipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(self.handleSwipe(_:)))
        rightSwipe.direction = .right
        rightSwipe.numberOfTouchesRequired = 1
        self.addGestureRecognizer(leftSwipe)
        self.addGestureRecognizer(rightSwipe)
    }
    
    fileprivate func updateIndexLabel() {
        indexLabel.text = String(currentIndex + 1) + " of " + String(totalCount)
    }
    
    @objc func handleSwipe(_ swipeGesture: UISwipeGestureRecognizer) {
        if swipeGesture.direction == .right {
            animatePrevious()
        } else if swipeGesture.direction == .left {
            animateNext()
        }
    }
    
    /// Function to animate to next image
    fileprivate func animateNext() {
        if currentIndex < (totalCount-1) {
            currentIndex += 1
            pushAnimationEffect.type = CATransitionType.moveIn
            pushAnimationEffect.subtype = CATransitionSubtype.fromRight
            imageView.isHidden = false
            let image = items[currentIndex]
            self.imageView.image = image
            imageView.layer.add(pushAnimationEffect, forKey: "SlideOutandInImagek")
            scrollView.zoomScale = 1
            updateIndexLabel()
        }
    }
    
    /// Function to animate to previous image
    fileprivate func animatePrevious() {
        if currentIndex > 0 {
            currentIndex -= 1
            pushAnimationEffect.type = CATransitionType.moveIn
            pushAnimationEffect.subtype = CATransitionSubtype.fromLeft
            imageView.isHidden = false
            let image = items[currentIndex]
            self.imageView.image = image
            imageView.layer.add(pushAnimationEffect, forKey: "SlideOutandInImagek")
            scrollView.zoomScale = 1
            updateIndexLabel()
        }
    }
    
    func clearData() {
        currentIndex = 0
        totalCount = 0
        items = []
    }
    
    func hideImageViewer(){
        self.removeFromSuperview()
        self.view = nil
    }
    
    static func show(_ containerView: UIView, items: [UIImage], current: Int) {
        let imagePreview: YRPhotoPreviewer = YRPhotoPreviewer(frame: containerView.frame)
        containerView.addSubview(imagePreview)
        imagePreview.setData(items, current: current)
    }
    
    //Customise icons
    func customiseCropIcon(image: UIImage?, tintColor: UIColor) {
        if image != nil {
            self.cropButton.setImage(image!.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        self.cropButton.tintColor = tintColor
    }
    
    func customiseDeleteIcon(image: UIImage?, tintColor: UIColor) {
        if image != nil {
            self.deleteButton.setImage(image!.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        self.deleteButton.tintColor = tintColor
    }
    
    func customiseCloseIcon(image: UIImage?, tintColor: UIColor) {
        if image != nil {
            self.closeButton.setImage(image!.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        self.closeButton.tintColor = tintColor
    }
    
    //MARK:- IBActions
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        self.hideImageViewer()
        if self.closeButtonTapped != nil {
            self.closeButtonTapped!(self.items)
        }
        clearData()
    }
   
    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        self.items.remove(at: currentIndex)
        if self.items.count == 0 {
            self.closeButtonClicked(closeButton)
        } else if currentIndex == self.items.count {
            setData(self.items, current: self.items.count - 1)
        } else if self.items.count > 0 {
            setData(self.items, current: currentIndex)
        }
    }
    
    @IBAction func cropIconClicked(_ sender: UIButton) {
        let cropVC = PKCCrop().cropViewController(self.items[currentIndex])
        cropVC.delegate = self
        UIApplication.topViewController()?.present(cropVC, animated: true, completion: nil)
    }
    
    //MARK:- UIScrollViewDelegate functions
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    //MARK:- PKCCropDelegate methods
    //return Crop Image & Original Image
    public func pkcCropImage(_ image: UIImage?, originalImage: UIImage?) {
        self.imageView.image = image
        items[currentIndex] = image!
        scrollView.zoomScale = 1
    }
    
    //If crop is canceled
    public func pkcCropCancel(_ viewController: PKCCropViewController) {
        UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
    }
    
    //Successful crop
    public func pkcCropComplete(_ viewController: PKCCropViewController) {
        UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
    }
    
}

extension UIImageView{
    func imageFrame()->CGRect{
        let imageViewSize = self.frame.size
        guard let imageSize = self.image?.size else{return CGRect.zero}
        let imageRatio = imageSize.width / imageSize.height
        let imageViewRatio = imageViewSize.width / imageViewSize.height
        if imageRatio < imageViewRatio {
            let scaleFactor = imageViewSize.height / imageSize.height
            let width = imageSize.width * scaleFactor
            let topLeftX = (imageViewSize.width - width) * 0.5
            return CGRect(x: topLeftX, y: 0, width: width, height: imageViewSize.height)
        }else{
            let scalFactor = imageViewSize.width / imageSize.width
            let height = imageSize.height * scalFactor
            let topLeftY = (imageViewSize.height - height) * 0.5
            return CGRect(x: 0, y: topLeftY, width: imageViewSize.width, height: height)
        }
    }
}

extension UIApplication {
    static func topViewController() -> UIViewController? {
        guard var top = shared.keyWindow?.rootViewController else {
            return nil
        }
        while let next = top.presentedViewController {
            top = next
        }
        return top
    }
}
