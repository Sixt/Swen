//
//  SwenPerformanceTests.swift
//  Swen
//
//  Created by Dmitry Poznukhov on 14/12/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
//
@testable import Swen

fileprivate struct TestEvent: Event {
}

class SwenPerformanceTests: XCTestCase {

    func test_RegisterOneObserverOnMain_PostOnMain_Queue() {
        let sendCount: Int64 = 1000000
        var receiveCount: Int64 = 0

        let exp = expectation(description: "RegisterOnMain_PostOnMain")
        Swen<TestEvent>.register(self) { event in
            receiveCount += 1
            if receiveCount == sendCount {
                exp.fulfill()
            }
        }

        let event = TestEvent()
        for _ in 0...sendCount {
            Swen<TestEvent>.post(event)
        }

        waitForExpectations(timeout: 100)
        Swen<TestEvent>.unregister(self)
    }

    func test_RegisterManyObserverOnMain_PostOnMain_Queue() {
        let sendCount: Int64 = 3000
        var receiveCount: Int64 = 0

        let exp = expectation(description: "RegisterOnMain_PostOnMain")
        for _ in 0...sendCount {
            Swen<TestEvent>.register(self) { event in
                receiveCount += 1
                if receiveCount == sendCount * sendCount {
                    exp.fulfill()
                }
            }
        }

        let event = TestEvent()
        for _ in 0...sendCount {
            Swen<TestEvent>.post(event)
        }

        waitForExpectations(timeout: 100)
        Swen<TestEvent>.unregister(self)
    }

}
