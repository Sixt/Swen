//
//  SwenTests.swift
//  Sixt-iOS
//
//  Created by Dmitry Poznukhov on 11/11/16.
//  Copyright © 2016 e-Sixt GmbH & Co. KG. All rights reserved.
//

import XCTest
//
@testable import Swen

fileprivate struct TestEvent: Event {
}

fileprivate struct TestStickyEvent: StickyEvent {
    var value = ""
}

class SwenTests: XCTestCase {

    let timeout = 5.0

    func test_RegisterOnMain_PostFromMain_Queue() {
        let exp = expectation(description: "eventReceivedExpectation")
        Swen<TestEvent>.register(self) { event in
            XCTAssertEqual(OperationQueue.current, OperationQueue.main)
            exp.fulfill()
        }

        Swen.post(TestEvent())

        waitForExpectations(timeout: timeout)
        Swen<TestEvent>.unregister(self)
    }

    func test_RegisterOnMain_PostFromBackground_Queue() {
        let exp = expectation(description: "eventReceivedExpectation")
        let postQueue = OperationQueue()
        Swen<TestEvent>.register(self) { event in
            XCTAssertEqual(OperationQueue.current, OperationQueue.main)
            exp.fulfill()
        }

        postQueue.addOperation {
            Swen.post(TestEvent())
        }

        waitForExpectations(timeout: timeout)
        Swen<TestEvent>.unregister(self)
    }

    func test_RegisterOnBackground_PostFromMain_Queue() {
        let exp = expectation(description: "eventReceivedExpectation")
        Swen<TestEvent>.registerOnBackground(self) { event in
            XCTAssertNotEqual(OperationQueue.current, OperationQueue.main)
            exp.fulfill()
        }

        Swen.post(TestEvent())

        waitForExpectations(timeout: timeout)
        Swen<TestEvent>.unregister(self)
    }

    func test_RegisterOnBackground_PostFromBackground_Queue() {
        let exp = expectation(description: "eventReceivedExpectation")
        let postQueue = OperationQueue()
        Swen<TestEvent>.registerOnBackground(self) { event in
            XCTAssertNotEqual(OperationQueue.current, OperationQueue.main)
            XCTAssertNotEqual(OperationQueue.current, postQueue)
            exp.fulfill()
        }

        postQueue.addOperation {
            Swen.post(TestEvent())
        }

        waitForExpectations(timeout: timeout)
        Swen<TestEvent>.unregister(self)
    }

    func test_RegisterOnCustom_PostFrommain_Queue() {
        let exp = expectation(description: "eventReceivedExpectation")
        let receiveQueue = OperationQueue()
        Swen<TestEvent>.register(self, onQueue: receiveQueue) { event in
            XCTAssertEqual(OperationQueue.current, receiveQueue)
            exp.fulfill()
        }

        Swen.post(TestEvent())

        waitForExpectations(timeout: timeout)
        Swen<TestEvent>.unregister(self)
    }

    func test_RegisterOnCustom_PostFromBackground_Queue() {
        let exp = expectation(description: "eventReceivedExpectation")
        let receiveQueue = OperationQueue()
        let postQueue = OperationQueue()
        Swen<TestEvent>.register(self, onQueue: receiveQueue) { event in
            XCTAssertEqual(OperationQueue.current, receiveQueue)
            exp.fulfill()
        }

        postQueue.addOperation {
            Swen.post(TestEvent())
        }

        waitForExpectations(timeout: timeout)
        Swen<TestEvent>.unregister(self)
    }

    func test_GetStickyOnRegisterAfterPost() {
        Swen.post(TestStickyEvent())

        let exp = expectation(description: "StickyEventReceivedExpectation")
        Swen<TestStickyEvent>.register(self) { event in
            exp.fulfill()
        }

        waitForExpectations(timeout: timeout)
        Swen<TestStickyEvent>.unregister(self)
    }

    func test_GetStickyAfterPost() {
        let sendingEvent = TestStickyEvent(value: "TestEvent")
        Swen.post(sendingEvent)

        let receivedEvent: TestStickyEvent? = Swen.sticky()

        XCTAssertEqual(sendingEvent.value, receivedEvent?.value)
    }

    func test_Receive_After_PostDifferentEvent() {
        let exp = expectation(description: "oldEventReceivedExpectation")
        Swen<TestEvent>.register(self) { event in
            exp.fulfill()
        }

        Swen.post(TestStickyEvent())
        Swen.post(TestEvent())

        waitForExpectations(timeout: timeout)
        Swen<TestEvent>.unregister(self)
    }

}
