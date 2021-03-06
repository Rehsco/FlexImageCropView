// Adopted from RSKImageCropViewController.swift
// Original Copyright Notice

//
// RSKImageCropViewController.swift
//
// Copyright (c) 2014-present Ruslan Skorb, http://ruslanskorb.com/
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import UIKit
import StyledLabel
import FlexViews
import FlexMenu

// K is a constant such that the accumulated error of our floating-point computations is definitely bounded by K units in the last place.
#if arch(x86_64) || CPU_TYPE_ARM64
    let kK = CGFloat(9)
#else
    let kK = CGFloat(0)
#endif

#if arch(x86_64) || CPU_TYPE_ARM64
    let INFINITY = Double.greatestFiniteMagnitude
    let EPSILON = CGFloat(Double.ulpOfOne)
    let FLOAT_LEAST_MIN = CGFloat(Double.leastNormalMagnitude)
#else
    let INFINITY = CGFloat.greatestFiniteMagnitude
    let EPSILON = CGFloat(Float.ulpOfOne)
    let FLOAT_LEAST_MIN = CGFloat(Float.leastNormalMagnitude)
#endif

public class ImageCropView: CommonFlexView, UIGestureRecognizerDelegate {
    fileprivate let kResetAnimationDuration = CGFloat(0.4)
    fileprivate let kLayoutImageScrollViewAnimationDuration = CGFloat(0.25)
    private var undoMI: FlexMenuItem?

    fileprivate lazy var imageScrollView: RSKImageScrollView = {
        let view = RSKImageScrollView(frame: .zero)
        view.clipsToBounds = false
        view.isAspectFill = self.isAvoidEmptySpaceAroundImage
        return view
    }()

    fileprivate lazy var overlayView: RSKTouchView = {
        let view = RSKTouchView()
        view.receiver = self.imageScrollView
        view.layer.addSublayer(self.maskLayer)
        return view
    }()

    fileprivate lazy var maskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillRule = CAShapeLayerFillRule.evenOdd
        layer.fillColor = FlexImageCropViewConfiguration.overlayMaskColor.cgColor
        return layer
    }()

    fileprivate lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        recognizer.delaysTouchesEnded = false
        recognizer.numberOfTapsRequired = 2
        recognizer.delegate = self
        return recognizer
    }()

    fileprivate lazy var rotationGestureRecognizer: UIRotationGestureRecognizer = {
        let recognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation))
        recognizer.delaysTouchesEnded = false
        recognizer.delegate = self
        recognizer.isEnabled = self.isRotationEnabled
        return recognizer
    }()

    fileprivate var maskRect = CGRect.zero
    fileprivate var maskPath = UIBezierPath() {
        didSet {
            let clipPath = UIBezierPath(rect: rectForClipPath)
            clipPath.append(maskPath)
            clipPath.usesEvenOddFillRule = true
            
            let pathAnimation = CABasicAnimation(keyPath: "path")
            pathAnimation.duration = CATransaction.animationDuration()
            pathAnimation.timingFunction = CATransaction.animationTimingFunction()
            self.maskLayer.add(pathAnimation, forKey: "path")
            
            self.maskLayer.path = clipPath.cgPath
        }
    }

    public var isAvoidEmptySpaceAroundImage = true {
        didSet {
            imageScrollView.isAspectFill = isAvoidEmptySpaceAroundImage
        }
    }
    
    public var isApplyMaskToCroppedImage = false
    public var isRotationEnabled = false {
        didSet {
            rotationGestureRecognizer.isEnabled = isRotationEnabled
        }
    }
    
    public var originalImage: UIImage? {
        didSet {
            if self.window != nil {
                displayImage()
            }
        }
    }
    
    public var imageCroppedHandler: ((CGRect)->Void)?
    public var imageCropCancelledHandler: (()->Void)?
    fileprivate let initialCropRect: CGRect

    public init(frame: CGRect, image: UIImage, cropRect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)) {
        self.initialCropRect = cropRect
        super.init(frame: frame)
        self.originalImage = image
        self.setupView()
    }

    public required init?(coder aDecoder: NSCoder) {
        self.initialCropRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        super.init(coder: aDecoder)
        self.setupView()
    }

    private func setupView() {
        self.backgroundColor = FlexImageCropViewConfiguration.styleColor
        self.clipsToBounds = true
        
        self.headerText = "Crop Image"
        self.headerSize = FlexImageCropViewConfiguration.headerHeight
        self.header.styleColor = FlexImageCropViewConfiguration.headerColor

        self.addSubview(imageScrollView)
        self.addSubview(overlayView)
        
        self.addGestureRecognizer(doubleTapGestureRecognizer)
        self.addGestureRecognizer(rotationGestureRecognizer)
        
        self.rightViewMenu = CommonIconViewMenu(size: CGSize(width: 120, height: 36), hPos: .right, vPos: .header, menuIconSize: 24)
        self.undoMI = self.rightViewMenu?.createIconMenuItem(imageName: "undo", iconSize: 24, selectionHandler: {
            self.reset(animated: true)
        })
        self.rightViewMenu?.createIconMenuItem(imageName: "Accept", iconSize: 24, selectionHandler: {
            self.imageCroppedHandler?(self.getImageRelativeCroppingRect())
            self.closeView()
        })
        self.addMenu(self.rightViewMenu!)
        
        self.createBackOrCloseLeftMenu {
            self.imageCropCancelledHandler?()
            self.closeView()
        }
    }

    private func closeView() {
        self.removeFromSuperview()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateMaskRect()
        layoutImageScrollView()
        layoutOverlayView()
        updateMaskPath()

        if imageScrollView.zoomView == nil {
            displayImage()
            self.setCropRectBasedOnRelativeRect(self.initialCropRect)
        }
    }

    // MARK: - Custom Accessors

    fileprivate func setCropRectBasedOnRelativeRect(_ rect: CGRect) {
        self.imageScrollView.zoomScale = min(1.0 / rect.width, 1.0 / rect.height) * self.imageScrollView.minimumZoomScale
        let isvb = self.imageScrollView.bounds
        let contentOffset = CGPoint(x: (isvb.width / rect.width) * rect.minX, y: (isvb.height / rect.height) * rect.minY)
        self.imageScrollView.contentOffset = contentOffset
    }

    fileprivate var cropRect: CGRect {
        var rect = CGRect.zero
        let zoomScale = 1.0 / imageScrollView.zoomScale
        
        rect.origin.x = round(imageScrollView.contentOffset.x * zoomScale)
        rect.origin.y = round(imageScrollView.contentOffset.y * zoomScale)
        rect.size.width = imageScrollView.bounds.width * zoomScale
        rect.size.height = imageScrollView.bounds.height * zoomScale
        
        let width = rect.width
        let height = rect.height
        let ceilWidth = ceil(width)
        let ceilHeight = ceil(height)
        
        if abs(ceilWidth - width) < pow(10, kK) * EPSILON * abs(ceilWidth + width) || abs(ceilWidth - width) < FLOAT_LEAST_MIN ||
            abs(ceilHeight - height) < pow(10, kK) * EPSILON * abs(ceilHeight + height) || abs(ceilHeight - height) < FLOAT_LEAST_MIN
        {
            rect.size.width = ceilWidth
            rect.size.height = ceilHeight
        } else {
            rect.size.width = floor(width)
            rect.size.height = floor(height)
        }
        
        return rect
    }

    private func getImageRelativeCroppingRect() -> CGRect {
        guard let image = self.originalImage else { return CGRect(x: 0, y: 0, width: 0, height: 0) }

        let cropRect = checkAndCorrectCropRect(forImage: image, withCurrentCropRect: self.cropRect)

        let imageSize = image.size
        let relCropRect = CGRect(x: cropRect.minX / imageSize.width, y: cropRect.minY / imageSize.height, width: cropRect.width / imageSize.width, height: cropRect.height / imageSize.height)
        return relCropRect
    }
    
    fileprivate var rectForClipPath: CGRect {
        return overlayView.frame
    }

    fileprivate var rectForMaskPath: CGRect {
        return maskRect
    }

    internal var rotationAngle: CGFloat {
        get {
            let transform = imageScrollView.transform
            return atan2(transform.b, transform.a)
        }
        
        set(rotationAngle) {
            if self.rotationAngle != rotationAngle {
                let rotation = (rotationAngle - self.rotationAngle)
                let transform = imageScrollView.transform.rotated(by: rotation)
                imageScrollView.transform = transform
            }
        }
    }

    fileprivate var zoomScale: CGFloat {
        return imageScrollView.zoomScale
    }

    fileprivate func setZoomScale(_ zoomScale: CGFloat) {
        self.imageScrollView.zoomScale = zoomScale
    }

    // MARK: - Action handling

    @objc fileprivate func handleDoubleTap(gestureRecognizer: UITapGestureRecognizer) {
        reset(animated: true)
    }

    @objc fileprivate func handleRotation(gestureRecognizer: UIRotationGestureRecognizer) {
        rotationAngle += gestureRecognizer.rotation
        gestureRecognizer.rotation = 0
        
        if gestureRecognizer.state == .ended {
            UIView.animate(
                withDuration: TimeInterval(kLayoutImageScrollViewAnimationDuration),
                delay: 0.0,
                options: .beginFromCurrentState,
                animations: {
                    self.layoutImageScrollView()
                },
                completion:nil)
        }
    }

    public func reset(animated: Bool) {
        if animated {
            UIView.beginAnimations("rsk_reset", context: nil)
            UIView.setAnimationCurve(.easeInOut)
            UIView.setAnimationDuration(TimeInterval(kResetAnimationDuration))
            UIView.setAnimationBeginsFromCurrentState(true)
        }
        
        resetRotation()
        resetFrame()
        resetZoomScale()
        resetContentOffset()
        
        if animated {
            UIView.commitAnimations()
        }
    }

    // MARK: - Private
    
    fileprivate func resetContentOffset() {
        guard let zoomView = imageScrollView.zoomView else { return }
        
        let boundsSize = imageScrollView.bounds.size
        let frameToCenter = zoomView.frame
        
        var contentOffset = CGPoint(x: 0.0, y: 0.0)
        if frameToCenter.width > boundsSize.width {
            contentOffset.x = (frameToCenter.width - boundsSize.width) * 0.5
        } else {
            contentOffset.x = 0
        }
        if (frameToCenter.height > boundsSize.height) {
            contentOffset.y = (frameToCenter.height - boundsSize.height) * 0.5
        } else {
            contentOffset.y = 0
        }
        
        self.imageScrollView.contentOffset = contentOffset
    }

    fileprivate func resetFrame() {
        layoutImageScrollView()
    }

    fileprivate func resetRotation() {
        rotationAngle = 0.0
    }

    fileprivate func resetZoomScale() {
        guard let originalImage = originalImage else { return }
    
        let vr = self.getViewRect()
        var zoomScale = CGFloat(0.0)
        if vr.width > vr.height {
            zoomScale = vr.height / originalImage.size.height
        } else {
            zoomScale = vr.width / originalImage.size.width
        }
        self.imageScrollView.zoomScale = zoomScale
    }

    fileprivate func displayImage() {
        guard let originalImage = originalImage else { return }
        
        imageScrollView.displayImage(originalImage)
        reset(animated: false)
    }

    fileprivate func layoutImageScrollView() {
        let transform = imageScrollView.transform
        imageScrollView.transform = .identity
        imageScrollView.frame = maskRect
        imageScrollView.transform = transform
    }

    fileprivate func layoutOverlayView() {
        let vr = self.getViewRect()
        let frame = CGRect(x: 0, y: 0, width: vr.width * 2, height: vr.height * 2)
        overlayView.frame = frame
    }

    fileprivate func updateMaskRect() {
        self.maskRect = MaskRectHelper.getMaskRect(inRect: self.getViewRect())
    }

    fileprivate func updateMaskPath() {
        self.maskPath = StyledShapeLayer.shapePathForStyle(FlexImageCropViewConfiguration.imageMaskStyle.style, bounds: rectForMaskPath)
    }

    fileprivate func checkAndCorrectCropRect(forImage image: UIImage, withCurrentCropRect originalCropRect: CGRect) -> CGRect {
        var cropRect = originalCropRect
        let imageSize = image.size
        let x = cropRect.minX
        let y = cropRect.minY
        let width = cropRect.width
        let height = cropRect.height
        
        let imageOrientation = image.imageOrientation
        if imageOrientation == .right || imageOrientation == .rightMirrored {
            cropRect.origin.x = y
            cropRect.origin.y = round(imageSize.width - cropRect.width - x)
            cropRect.size.width = height
            cropRect.size.height = width
        } else if imageOrientation == .left || imageOrientation == .leftMirrored {
            cropRect.origin.x = round(imageSize.height - cropRect.height - y)
            cropRect.origin.y = x
            cropRect.size.width = height
            cropRect.size.height = width
        } else if imageOrientation == .down || imageOrientation == .downMirrored {
            cropRect.origin.x = round(imageSize.width - cropRect.width - x)
            cropRect.origin.y = round(imageSize.height - cropRect.height - y)
        }
        
        let imageScale = image.scale
        cropRect = cropRect.applying(CGAffineTransform(scaleX: imageScale, y: imageScale))
        return cropRect
    }
    
    // MARK: - UIGestureRecognizerDelegate

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
