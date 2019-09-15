/**
 Based on Helper.swift from MIT Licensed ImagePicker from hyperoslo
 */

import UIKit

class Helper {
    
    static func ensureOnAsyncMainThread(_ execute: @escaping (()->Void)) {
        if Thread.isMainThread {
            execute()
        }
        else {
            DispatchQueue.main.async {
                execute()
            }
        }
    }
    
    static func rotationTransform() -> CGAffineTransform {
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            return CGAffineTransform(rotationAngle: CGFloat.pi * 0.5)
        case .landscapeRight:
            return CGAffineTransform(rotationAngle: -(CGFloat.pi * 0.5))
        case .portraitUpsideDown:
            return CGAffineTransform(rotationAngle: CGFloat.pi)
        default:
            return CGAffineTransform.identity
        }
    }

    static func screenSizeForOrientation() -> CGSize {
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            return CGSize(width: UIScreen.main.bounds.height,
                          height: UIScreen.main.bounds.width)
        default:
            return UIScreen.main.bounds.size
        }
    }
    
    static func applyFontAndColorToString(_ font: UIFont, color: UIColor, text: String) -> NSAttributedString {
        let attributedString = NSAttributedString(string: text, attributes:
            [   NSAttributedString.Key.font : font,
                NSAttributedString.Key.foregroundColor: color
            ])
        return attributedString
    }
    
    static func stringFromTimeInterval(interval: TimeInterval) -> String {
        let ti = NSInteger(interval.isNaN ? 0 : interval)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        if minutes == 0 && hours == 0 {
            return NSString(format: "%0.2ds",seconds) as String
        }
        else if hours == 0 {
            return NSString(format: "%0.2d:%0.2d",minutes,seconds) as String
        }
        else {
            return NSString(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds) as String
        }
    }
    
    static func imageToAttachmentImage(_ image: UIImage, fontSize: CGFloat = 0) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = image
        if fontSize > 0 {
            let dy = fontSize - image.size.height
            attachment.bounds = CGRect(x: 0, y: dy, width: image.size.width, height: image.size.height)
        }
        return NSAttributedString(attachment: attachment)
    }

}
