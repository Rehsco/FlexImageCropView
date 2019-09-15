/**
 Based on Configuration.swift from MIT Licensed ImagePicker from hyperoslo
 */

import UIKit
import MJRFlexStyleComponents

public class FlexImageCropViewConfiguration: StyleEnvironment {
    
    // MARK: Colors
    
    public static var styleColor = UIColor(red: 0.15, green: 0.19, blue: 0.24, alpha: 1)
    public static var selectedItemColor = UIColor(red: 0.25, green: 0.29, blue: 0.34, alpha: 1)
    public static var headerColor = UIColor(red: 0.09, green: 0.11, blue: 0.13, alpha: 1)
    public static var headerTextColor = UIColor.white

    public static var overlayMaskColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.55)

    // MARK: Styled
    
    public static var imageMaskStyle: FlexShapeStyle = FlexShapeStyle(style: .thumb)
    
    // MARK: Fonts
    
    public static var headerFont = UIFont.systemFont(ofSize: 19, weight: UIFont.Weight.medium)
    public static var headerSubCaptionFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)

    // MARK: Dimensions
    
    public static var headerHeight: CGFloat = 44
    public static var footerHeight: CGFloat = 64

    public static var imageCroppingMaxScale: CGFloat = 5.0
    // Currently available: scaleToFit and scaleToFill
    public static var imageMaskFitting: FlexImageShapeFit = .scaleToFit
    public static var faceDetectionCropScale: CGFloat = 1.0

    // MARK: Custom behaviour
    
    public static var statusBarHidden = true

    public static var maskImage = true
    public static var maskImageAutoCropToDetectedFace = true

    public override init() {
        super.init()
    }
}
