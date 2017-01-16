//
//  UIEvents.swift
//  Swen
//
//  Created by Dmitry Poznukhov on 16/12/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Swen

struct UIEvents {

    struct ColorChanged: StickyEvent {
        let color: UIColor
        init(_ color: UIColor) {
            self.color = color
        }
    }

}
