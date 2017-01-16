//
//  PerformanceTestsViewController.swift
//  Swen
//
//  Created by Dmitry Poznukhov on 16/12/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Swen

fileprivate struct TestEvent: Event {
}

class PerformanceTestsViewController: UIViewController {

    @IBOutlet private(set) var nsNotificationCenterOneReceiverTestResultLabel: UILabel!
    @IBOutlet private(set) var nsNotificationCenterManyReceiverTestResultLabel: UILabel!

    @IBOutlet private(set) var swenOneReceiverTestResultLabel: UILabel!
    @IBOutlet private(set) var swenManyReceiverTestResultLabel: UILabel!

    @IBOutlet private(set) var activityIndicatorContainer: UIView!
    @IBOutlet private(set) var acitivityIndicator: UIActivityIndicatorView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        registerToEvents()
        hideActivityIndicator()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        unregisterFromEvents()
    }

    var testMutex = DispatchSemaphore(value: 1)

}

// MARK: Events
extension PerformanceTestsViewController {

    func registerToEvents() {
        Swen<UIEvents.ColorChanged>.register(self) { [weak self] event in
            self?.view.backgroundColor = event.color
        }
    }

    func unregisterFromEvents() {
        Swen<UIEvents.ColorChanged>.unregister(self)
    }

}

// MARK: Activity indicator
extension PerformanceTestsViewController {

    func showActivityIndicator() {
        activityIndicatorContainer.isHidden = false
        acitivityIndicator.startAnimating()
    }

    func hideActivityIndicator() {
        activityIndicatorContainer.isHidden = true
        acitivityIndicator.stopAnimating()
    }

}

// MARK: NSNotification center tests
extension PerformanceTestsViewController {

    @IBAction func performNotificationCenterTests_OneReceiver() {
        showActivityIndicator()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let sendCount: Int64 = 1000000
            var receiveCount: Int64 = 0
            let notificationID = "TestNotificationID1"

            let startTime = CFAbsoluteTimeGetCurrent()

            let observer = NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: notificationID), object: nil, queue: nil) { note in
                receiveCount += 1
                if receiveCount == sendCount {
                    self.testMutex.signal()
                }
            }
            let notification = Notification(name: Notification.Name(rawValue: notificationID), object: nil)
            for _ in 0...sendCount {
                NotificationCenter.default.post(notification)
            }
            _ = self.testMutex.wait(timeout: DispatchTime.distantFuture)
            NotificationCenter.default.removeObserver(observer)


            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            self.nsNotificationCenterOneReceiverTestResultLabel.text = String(format: "time: %2.3f s", timeElapsed)
            self.hideActivityIndicator()
        }
    }

    @IBAction func performNotificationCenterTests_ManyReceivers() {
        showActivityIndicator()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let sendCount: Int64 = 3000
            var receiveCount: Int64 = 0
            let notificationID = "TestNotificationID2"

            let startTime = CFAbsoluteTimeGetCurrent()

            var observers = [AnyObject]()
            for _ in 0...sendCount {
                let observer = NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: notificationID), object: nil, queue: nil) { note in
                    receiveCount += 1
                    if receiveCount == sendCount * sendCount {
                        self.testMutex.signal()
                    }
                }
                observers.append(observer)
            }
            let notification = Notification(name: Notification.Name(rawValue: notificationID), object: nil)
            for _ in 0...sendCount {
                NotificationCenter.default.post(notification)
            }
            _ = self.testMutex.wait(timeout: DispatchTime.distantFuture)
            for observer in observers {
                NotificationCenter.default.removeObserver(observer)
            }


            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            self.nsNotificationCenterManyReceiverTestResultLabel.text = String(format: "time: %2.3f s", timeElapsed)
            self.hideActivityIndicator()
        }
    }

}

// MARK: Swen tests
extension PerformanceTestsViewController {

    @IBAction func performSwenTests_OneReceiver() {
        showActivityIndicator()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let sendCount: Int64 = 1000000
            var receiveCount: Int64 = 0

            let startTime = CFAbsoluteTimeGetCurrent()

            Swen<TestEvent>.register(self) { event in
                receiveCount += 1
                if receiveCount == sendCount {
                    self.testMutex.signal()
                }
            }
            let event = TestEvent()
            for _ in 0...sendCount {
                Swen<TestEvent>.post(event)
            }
            _ = self.testMutex.wait(timeout: DispatchTime.distantFuture)
            Swen<TestEvent>.unregister(self)


            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            self.swenOneReceiverTestResultLabel.text = String(format: "time: %2.3f s", timeElapsed)
            self.hideActivityIndicator()
        }
    }

    @IBAction func performSwenTests_ManyReceivers() {
        showActivityIndicator()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let sendCount: Int64 = 3000
            var receiveCount: Int64 = 0

            let startTime = CFAbsoluteTimeGetCurrent()

            for _ in 0...sendCount {
                Swen<TestEvent>.register(self) { event in
                    receiveCount += 1
                    if receiveCount == sendCount * sendCount {
                        self.testMutex.signal()
                    }
                }
            }
            let event = TestEvent()
            for _ in 0...sendCount {
                Swen<TestEvent>.post(event)
            }
            _ = self.testMutex.wait(timeout: DispatchTime.distantFuture)
            Swen<TestEvent>.unregister(self)
            
            
            
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            self.swenManyReceiverTestResultLabel.text = String(format: "time: %2.3f s", timeElapsed)
            self.hideActivityIndicator()
        }
    }
}
