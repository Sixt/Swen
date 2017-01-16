//
//  NSNotificationPerformanceTestExample.swift
//  Swen
//
//  Created by Dmitry Poznukhov on 14/12/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest

class NSNotificationPerformanceTestExample: XCTestCase {

    func test_RegisterOneObserverOnMain_PostOnMain_Queue() {
        let sendCount: Int64 = 1000000
        var receiveCount: Int64 = 0

        let notificationID = "TestNotificationID1"
        let exp = expectation(description: "RegisterOnMain_PostOnMain")
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: notificationID), object: nil, queue: nil) { note in
            receiveCount += 1
            if receiveCount == sendCount {
                exp.fulfill()
            }
        }

        let notification = Notification(name: Notification.Name(rawValue: notificationID), object: nil)
        for _ in 0...sendCount {
            NotificationCenter.default.post(notification)
        }

        waitForExpectations(timeout: 100)
    }

    func test_RegistermanyObserverOnMain_PostOnMain_Queue() {
        let sendCount: Int64 = 3000
        var receiveCount: Int64 = 0

        let notificationID = "TestNotificationID2"
        let exp = expectation(description: "RegisterOnMain_PostOnMain")
        for _ in 0...sendCount {
            NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: notificationID), object: nil, queue: nil) { note in
                receiveCount += 1
                if receiveCount == sendCount * sendCount {
                    exp.fulfill()
                }
            }
        }

        let notification = Notification(name: Notification.Name(rawValue: notificationID), object: nil)
        for _ in 0...sendCount {
            NotificationCenter.default.post(notification)
        }

        waitForExpectations(timeout: 100)
    }

    override func tearDown() {
        NotificationCenter.default.removeObserver(self)
    }

}
