//
//  Extensions.swift
//  Twitterr
//
//  Created by CK on 4/16/17.
//  Copyright © 2017 CK. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView  {
    
    func applyBlurAffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }
    
}


extension DateFormatter {
    /**
     Formats a date as the time since that date (e.g., “Last week, yesterday, etc.”).
     
     - Parameter from: The date to process.
     - Parameter numericDates: Determines if we should return a numeric variant, e.g. "1 month ago" vs. "Last month".
     
     - Returns: A string with formatted `date`.
     */
    func tiwtterTimeSince(from: NSDate, numericDates: Bool = false) -> String {
        let calendar = Calendar.current
        let now = NSDate()
        let earliest = now.earlierDate(from as Date)
        let latest = earliest == now as Date ? from : now
        let components = calendar.dateComponents([.year, .weekOfYear, .month, .day, .hour, .minute, .second], from: earliest, to: latest as Date)
        
        var result = ""
        
        if components.year! >= 2 {
            result = "\(components.year!) years ago"
        } else if components.year! >= 1 {
            if numericDates {
                result = "1 year ago"
            } else {
                result = "Last year"
            }
        } else if components.month! >= 2 {
            result = "\(components.month!) months ago"
        } else if components.month! >= 1 {
            if numericDates {
                result = "1 month ago"
            } else {
                result = "Last month"
            }
        } else if components.weekOfYear! >= 2 {
            result = "\(components.weekOfYear!) weeks ago"
        } else if components.weekOfYear! >= 1 {
            if numericDates {
                result = "1 week ago"
            } else {
                result = "Last week"
            }
        } else if components.day! >= 2 {
            result = "\(components.day!)d"
        } else if components.day! >= 1 {
            if numericDates {
                result = ".1d"
            } else {
                result = "Yesterday"
            }
        } else if components.hour! >= 2 {
            result = "\(components.hour!)h"
        } else if components.hour! >= 1 {
            if numericDates {
                result = "1h"
            } else {
                result = "An hour ago"
            }
        } else if components.minute! >= 2 {
            result = "\(components.minute!)m"
        } else if components.minute! >= 1 {
            if numericDates {
                result = "1m"
            } else {
                result = "A minute ago"
            }
        } else if components.second! >= 3 {
            result = "\(components.second!)s"
        } else {
            result = "Just now"
        }
        
        return result
    }
    
    
    
}


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}


func += <KeyType, ValueType> ( left: inout Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

extension String {
    func NSRangeFromRange(range: Range<String.Index>) -> NSRange {
        let utf16view = self.utf16
        let from = String.UTF16View.Index(range.lowerBound, within: utf16view)
        let to = String.UTF16View.Index(range.upperBound, within: utf16view)
        return NSMakeRange(utf16view.startIndex.distance(to: from), from.distance(to: to))
    }
    
    mutating func dropTrailingNonAlphaNumericCharacters() {
        let nonAlphaNumericCharacters = NSCharacterSet.alphanumerics.inverted
        let characterArray = components(separatedBy: nonAlphaNumericCharacters)
        
        if let first = characterArray.first {
            self = first
        }
    }
}

extension UITextView {
    
    public func resolveHashTags(possibleUserDisplayNames:[String]? = nil) {
        
        let schemeMap = [
            "#":"hash",
            "@":"mention"
        ]
        let words = self.text.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        let attributedString = attributedText.mutableCopy() as! NSMutableAttributedString
        attributedString.setAttributes([:], range: NSRange(0..<text.characters.count))
        var bookmark = text.startIndex
        for word in words {
            
            var scheme:String? = nil
            
            if word.hasPrefix("#") {
                scheme = schemeMap["#"]
            } else if word.hasPrefix("@") {
                scheme = schemeMap["@"]
            }
            
            if(scheme != nil ) {
            // Drop the # or @
                var wordWithTagRemoved = String(word.characters.dropFirst())
                
                // Drop any trailing punctuation
                
                wordWithTagRemoved.dropTrailingNonAlphaNumericCharacters()
                
                // Make sure we still have a valid word (i.e. not just '#' or '@' by itself, not #100)
                guard let schemeMatch = scheme, wordWithTagRemoved.characters.count > 0 && !wordWithTagRemoved.isEmpty
                    else { continue }
                
                let remainingRange = Range(bookmark..<text.endIndex)
                
                if let matchRange = text.range(of: word, options: .literal, range: remainingRange, locale: nil) {
                    let escapedString = wordWithTagRemoved.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                    attributedString.addAttribute(NSLinkAttributeName, value: "\(schemeMatch):\(escapedString ?? " ")", range: text.NSRangeFromRange(range: matchRange))
                }
                
                bookmark = text.index(bookmark, offsetBy: word.characters.count)
            }
        }
        
        self.attributedText = attributedString
}

}


