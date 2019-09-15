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
    //    private var overlayMaskLayer: CALayer?
    
    //    private var cropMenu: RehscoAppStyling.CommonIconViewMenu?
    //    private var undoMenu: FlexMenuItem?
    
    fileprivate var initialCropRect: CGRect = .zero
    
    private var isCropped: Bool = false

    private var cropRect: CGRect = CGRect(origin: .zero, size: CGSize(width: 1.0, height: 1.0))
    private var originalImageSize: CGSize = .zero
    
    private var sourceImage: UIImage? {
        didSet {
            self.createCropperView()
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
        
        //        super.setupView()
        /*
         self.contentView = FlexView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
         self.view.addSubview(self.contentView!)
         self.applyViewDefaultStyling(flexView: self.contentView!)
         
         self.contentView?.styleColor = ColorScheme.secondaryTextColor
         self.contentView?.header.caption.labelFont = ApplicationStyling.standardLightFont(18)
         
         self.contentView?.header.subCaption.labelTextAlignment = .center
         self.contentView?.header.subCaption.labelFont = ApplicationStyling.standardLightFont(12)
         self.contentView?.header.subCaption.labelTextColor = ColorScheme.textIconsColor
         */
        /*
         self.createBackOrCloseLeftMenu()
         
         self.createIconMenu(width: 120)
         self.undoMenu = self.rightViewMenu?.createIconMenuItem(imageName: "undo", selectionHandler: {
         self.initialCropRect = .zero
         self.storeImageAsset(cropRect: .zero)
         DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250), execute: {
         self.createCropperView()
         self.toggleUndo()
         })
         })
         self.rightViewMenu?.createIconMenuItem(imageName: "crop", selectionHandler: {
         if let asset = self.getImageAsset() {
         self.initialCropRect = self.isCropped ? asset.getAbsoluteCroppingRect() : .zero
         }
         
         self.showHideCropOverlay()
         self.toggleUndo()
         })
         self.contentView?.addMenu(self.rightViewMenu!)
         
         self.cropMenu = CommonIconViewMenu(size: CGSize(width: 240, height: 50), hPos: .center, vPos: .footer)
         self.cropMenu?.createCloseIconMenuItem()
         self.cropMenu?.createAcceptIconMenuItem()
         /* TODO: Rotation
         self.cropMenu?.createIconMenuItem(imageName: "rotateLeft", selectionHandler: { _ in
         self.imageCropperView?.rotate(-Double.pi * 0.5)
         })
         self.cropMenu?.createIconMenuItem(imageName: "rotateRight", selectionHandler: { _ in
         self.imageCropperView?.rotate(Double.pi * 0.5)
         })
         */
         self.cropMenu?.menuSelectionHandler = { menuSelected in
         switch menuSelected {
         case .accept:
         self.createCropperView()
         self.resetFooter()
         self.toggleUndo()
         case .close:
         self.imageCropperView?.reset(animated: true)
         self.showHideCropOverlay()
         self.storeImageAsset(cropRect: self.initialCropRect)
         default:
         break
         }
         }
         self.cropMenu?.viewMenu?.isHidden = true
         self.contentView?.addMenu(self.cropMenu!)
         self.contentView?.footerSize = 50
         self.contentView?.footer.styleColor = UIColor.black.withAlphaComponent(0.5) // same as cropping overlay!
         self.cropMenu?.viewMenu?.styleColor = ColorScheme.primaryColor
         self.cropMenu?.viewMenu?.style = FlexShapeStyle(style: .roundedFixed(cornerRadius: 10))
         */
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
        var tabbarSize: CGFloat = 0
        if let tbc = self.tabBarController {
            tabbarSize = tbc.tabBar.isHidden ? 0 : tbc.tabBar.bounds.size.height - 3
        }
        var resBounds = self.view.bounds.offsetBy(dx: 0, dy: UIApplication.shared.statusBarFrame.height * 0.5).insetBy(dx: 0, dy: UIApplication.shared.statusBarFrame.height * 0.5)
        resBounds = CGRect(origin: resBounds.origin, size: CGSize(width: resBounds.size.width, height: resBounds.size.height-tabbarSize))
        if let cv = self.contentView {
            cv.frame = resBounds
            self.imageCropperView?.frame = cv.getViewRect()
        }
        super.refreshView()
    }
    
    // MARK: - View Creation
    /*
     open override func createBackOrCloseLeftMenu() {
     self.leftViewMenu = CommonIconViewMenu(size: CGSize(width: 50, height: 36), hPos: .left, vPos: .header)
     if self.isModal() {
     self.leftViewMenu?.createAcceptIconMenuItem()
     self.leftViewMenu?.menuSelectionHandler = {
     type in
     if type == .accept {
     self.dismiss(animated: true)
     }
     }
     }
     else {
     let swb = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeToGoBack(sender:)))
     self.view.addGestureRecognizer(swb)
     self.leftViewMenu?.createBackIconMenuItem()
     self.leftViewMenu?.menuSelectionHandler = {
     type in
     if type == .back {
     self.navigationController?.popViewController(animated: true)
     }
     }
     }
     self.contentView?.addMenu(self.leftViewMenu!)
     }
     */
    private func createCropperView() {
        if imageCropperView != nil {
            return
        }
        imageCropperView?.removeFromSuperview()
        if let image = self.sourceImage {
            let cropRect = self.cropRect == .zero ? CGRect(origin: .zero, size: CGSize(width: 1, height: 1)) : self.cropRect
            imageCropperView = ImageCropView(frame: UIScreen.main.bounds, image: image, cropRect: cropRect)
            imageCropperView?.imageCroppedHandler = {
                cropRect in
                NSLog("Image cropped to \(cropRect)")
                self.dismiss(animated: true)
            }
            imageCropperView?.imageCropCancelledHandler = {
                self.dismiss(animated: true)
            }
            view.addSubview(imageCropperView!)
        }
    }
    
    /*
     func applyMask() {
     self.overlayMaskLayer?.removeFromSuperlayer()
     if let icv = self.imageCropperView {
     let size = icv.croppedImage?.size ?? icv.image?.size ?? UIScreen.main.bounds.size
     self.overlayMaskLayer = self.mask(forSize: size)
     icv.overlayView?.layer.addSublayer(self.overlayMaskLayer!)
     }
     }
     
     private func mask(forSize size: CGSize, invert: Bool = true) -> CALayer {
     let dRect = CGRect(origin: .zero, size: size)
     let imgRect = CGRectHelper.AspectFitRectInRect(dRect, rtarget: UIScreen.main.bounds)
     let maskLayer = CAShapeLayer()
     let maskRect = CGRectHelper.AspectFitRectInRect(CGRect(x: 0, y: 0, width: 1, height: 1), rtarget: imgRect)
     let shape = StyledShapeLayer.shapePathForStyle(.thumb, bounds: maskRect)
     let path = CGMutablePath()
     if (invert) {
     path.addRect(UIScreen.main.bounds)
     }
     path.addPath(shape.cgPath)
     
     maskLayer.path = path
     if (invert) {
     maskLayer.fillRule = kCAFillRuleEvenOdd
     }
     
     // Set the mask of the view.
     let overlayShape = StyledShapeLayer.createShape(.box, bounds: UIScreen.main.bounds, color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.55))
     overlayShape.mask = maskLayer
     return overlayShape
     }
     */
    /*
     private func showHideCropOverlay() {
     if let cropView = self.imageCropperView {
     if cropView.isHidden {
     cropView.showHide(hide: false) {
     DispatchQueue.main.async {
     self.contentView?.footerText = " "
     self.leftViewMenu?.viewMenu?.isHidden = true
     self.rightViewMenu?.viewMenu?.isHidden = true
     self.refreshView()
     }
     }
     } else {
     cropView.showHide(hide: true) {
     self.resetFooter()
     }
     }
     }
     }
     */

    /*
     private func resetFooter() {
     DispatchQueue.main.async {
     //            self.cropMenu?.viewMenu?.isHidden = true
     self.contentView?.footerText = nil
     self.leftViewMenu?.viewMenu?.isHidden = false
     self.rightViewMenu?.viewMenu?.isHidden = false
     self.refreshView()
     }
     }
     */
}
