//
//  UIEvents.swift
//  Swen
//
//  Created by Dmitry Poznukhov on 16/12/16.
//  Copyright © 2019 Sixt SE. All rights reserved.
//

import Swen
import UIKit

struct UIEvents {

    struct ColorChanged: StickyEvent {
        let color: UIColor
        init(_ color: UIColor) {
            self.color = color
        }
    }

}
