//
//  UIColor+Components.swift
//  Swen
//
//  Created by Dmitry Poznukhov on 16/12/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

extension UIColor {
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let color = coreImageColor
        return (color.red, color.green, color.blue, color.alpha)
    }
}
