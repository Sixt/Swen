//
//  ViewController.swift
//  Swen
//
//  Created by Dmitry Poznukhov on 11/18/2016.
//  Copyright (c) 2019 Sixt SE. All rights reserved.
//

import UIKit
import Swen

class MainViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        registerToEvents()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        unregisterFromEvents()
    }

}

// MARK: Events
extension MainViewController {

    func registerToEvents() {
        Swen<UIEvents.ColorChanged>.register(self) { [weak self] event in
            self?.view.backgroundColor = event.color
        }
    }

    func unregisterFromEvents() {
        Swen<UIEvents.ColorChanged>.unregister(self)
    }
}
