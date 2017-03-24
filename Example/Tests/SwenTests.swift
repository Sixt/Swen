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

    func test_SynchronousDispatching_when_Post_Register_on_same_Queue() {
        var dispatched = false
        Swen<TestEvent>.register(self) { event in
            dispatched = true
        }

        Swen.post(TestEvent())
        Swen<TestEvent>.unregister(self)
        XCTAssertTrue(dispatched)
    }

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

    func test_RegisterPost_InStorage() {
        let storage = SwenStorage()
        let exp = expectation(description: "eventReceivedExpectation")
        Swen<TestEvent>.register(self, in: storage) { event in
            XCTAssertEqual(OperationQueue.current, OperationQueue.main)
            exp.fulfill()
        }

        Swen.post(TestEvent(), in: storage)

        waitForExpectations(timeout: timeout)
        Swen<TestEvent>.unregister(self, in: storage)
    }

    func test_RegisterPost_InStorage_Overlaping() {
        let storage1 = SwenStorage()
        let storage2 = SwenStorage()
        let exp = expectation(description: "eventReceivedExpectation")
        Swen<TestEvent>.register(self, in: storage1) { event in
            XCTAssertEqual(OperationQueue.current, OperationQueue.main)
            exp.fulfill()
        }

        Swen<TestEvent>.register(self, in: storage2) { event in
            XCTFail()
        }

        Swen<TestEvent>.register(self) { event in
            XCTFail()
        }

        Swen.post(TestEvent(), in: storage1)

        waitForExpectations(timeout: timeout)
        Swen<TestEvent>.unregister(self, in: storage1)
        Swen<TestEvent>.unregister(self)
    }

    func test_Register_DeallocateObserver_Post() {
        var dispatched1 = false
        var dispatched2 = false
        var observer: NSObject? = NSObject()
        Swen<TestEvent>.register(self) { _ in
            dispatched1 = true
        }
        Swen<TestEvent>.register(observer!) { _ in
            dispatched2 = true
        }

        observer = nil

        Swen.post(TestEvent())
        Swen<TestEvent>.unregister(self)
        XCTAssertTrue(dispatched1)
        XCTAssertFalse(dispatched2)
    }

    func test_RegisterSticky_DeallocateObserver_Post() {
        var dispatched1 = false
        var dispatched2 = false
        var observer: NSObject? = NSObject()
        Swen<TestStickyEvent>.register(self) { _ in
            dispatched1 = true
        }
        Swen<TestStickyEvent>.register(observer!) { _ in
            dispatched2 = true
        }

        observer = nil

        Swen.post(TestStickyEvent())
        Swen<TestEvent>.unregister(self)
        XCTAssertTrue(dispatched1)
        XCTAssertFalse(dispatched2)
    }

}
