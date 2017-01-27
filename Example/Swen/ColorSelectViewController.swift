//
//  ColorSelectViewController.swift
//  Swen
//
//  Created by Dmitry Poznukhov on 16/12/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Swen

class ColorSelectViewController: UIViewController {

    @IBOutlet private(set) var redSlider: UISlider!
    @IBOutlet private(set) var greenSlider: UISlider!
    @IBOutlet private(set) var blueSlider: UISlider!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        registerToEvents()
        setupSlidersPosition()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        unregisterFromEvents()
    }

    private func setupSlidersPosition() {
        guard let color = Swen<UIEvents.ColorChanged>.sticky()?.color else { return }

        redSlider.value = Float(color.components.red)
        greenSlider.value = Float(color.components.green)
        blueSlider.value = Float(color.components.blue)
    }

    @IBAction func sliderChanged(_ sender: Any) {
        let color = UIColor(red: CGFloat(redSlider.value), green: CGFloat(greenSlider.value), blue: CGFloat(blueSlider.value), alpha: 1.0)
        Swen.post(UIEvents.ColorChanged(color))
    }
}

// MARK: Events
extension ColorSelectViewController {

    func registerToEvents() {
        Swen<UIEvents.ColorChanged>.register(self) { [weak self] event in
            self?.view.backgroundColor = event.color
        }
    }

    func unregisterFromEvents() {
        Swen<UIEvents.ColorChanged>.unregister(self)
    }
    
}
