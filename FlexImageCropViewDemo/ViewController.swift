//
//  ViewController.swift
//  FlexImageCropViewDemo
//
//  Created by Martin Rehder on 28.07.2019.
//  Copyright © 2019 Rehsco. All rights reserved.
//

import UIKit
import MJRFlexStyleComponents

class ViewController: CommonFlexViewController {
    
    private var imageCropperView: ImageCropView?
    
    fileprivate var initialCropRect: CGRect = .zero
    
    private var isCropped: Bool = false
    
    private var cropRect: CGRect = CGRect(origin: .zero, size: CGSize(width: 1.0, height: 1.0))
    private var originalImageSize: CGSize = .zero
    
    private var sourceImage: UIImage? {
        didSet {
            imageCropperView?.originalImage = sourceImage
        }
    }
    
    private var displayImage: UIImage? {
        return self.isCropped ? self.sourceImage?.cropImageInRect(getAbsoluteCroppingRect()) : self.sourceImage
    }
    
    open func getAbsoluteCroppingRect() -> CGRect {
        return CGRect(origin:CGPoint(x:self.cropRect.origin.x * self.originalImageSize.width, y:self.cropRect.origin.y * self.originalImageSize.height), size:CGSize(width:self.originalImageSize.width * self.cropRect.width, height:self.originalImageSize.height * self.cropRect.height))
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - View Init
    
    override func setupView() {
        self.headerText = nil
        createCropperView()
        view.addSubview(contentView!)
        super.setupView()
    }
    
    // MARK: - View Logic
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        
        self.sourceImage = UIImage(named: "DemoImage")
    }
    
    override func whenTransition(to size: CGSize) {
        super.whenTransition(to: size)
        self.contentView?.setNeedsDisplay()
    }
    
    override func refreshView() {
        contentView?.frame = view.bounds.inset(by: self.view.safeAreaInsets)
        super.refreshView()
    }
    
    // MARK: - View Creation
    
    private func createCropperView() {
        if imageCropperView != nil {
            return
        }
        let cropRect = self.cropRect == .zero ? CGRect(origin: .zero, size: CGSize(width: 1, height: 1)) : self.cropRect
        imageCropperView = ImageCropView(frame: UIScreen.main.bounds, image: UIImage(), cropRect: cropRect)
        imageCropperView?.imageCroppedHandler = {
            cropRect in
            NSLog("Image cropped to \(cropRect)")
            self.dismiss(animated: true)
        }
        imageCropperView?.imageCropCancelledHandler = {
            self.dismiss(animated: true)
        }
        contentView = imageCropperView
    }
}
