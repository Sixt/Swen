//
//  Swen.swift
//  Sixt-iOS
//
//  Created by Dmitry Poznukhov on 03/11/16.
//  Copyright © 2016 e-Sixt GmbH & Co. KG. All rights reserved.
//

import Foundation

public protocol Event {

}

public protocol StickyEvent: Event {

}

public class Swen<EventType: Event> {

    fileprivate var listeners = [EventListener<EventType>]()
    public typealias EventListenerClosure = (_ event: EventType) -> Void
    fileprivate var sticky: EventType?
    fileprivate let editListenersSemaphore = DispatchSemaphore(value: 1)
    fileprivate let stickySemaphore = DispatchSemaphore(value: 1)

}

// MARK: public interface
public extension Swen {

    static func register(_ observer: AnyObject, onQueue queue: OperationQueue = .main, handler: @escaping EventListenerClosure) {
        instance().register(observer, onQueue: queue, handler: handler)
    }

    static func registerOnBackground(_ observer: AnyObject, handler: @escaping EventListenerClosure) {
        let queue = OperationQueue()
        queue.name = "com.sixt.Swen " + String(describing: EventType.self) + String(describing: observer)
        register(observer, onQueue: queue, handler: handler)
    }

    static func post(_ event: EventType) {
        instance().post(event)
    }

    static func unregister(_ observer: AnyObject) {
        instance().unregister(observer)
    }

}

// MARK: public sticky events interface
public extension Swen where EventType: StickyEvent {

    static var sticky: EventType? {
        return instance().sticky
    }
    
}

// MARKL: instantiation
fileprivate extension Swen {

    static func instance() -> Swen<EventType> {
        _ = SwenStorage.instanceSemaphore.wait(timeout: DispatchTime.distantFuture)
        defer { SwenStorage.instanceSemaphore.signal() }

        for case let bus as Swen<EventType> in SwenStorage.buses {
            return bus
        }

        let bus = Swen<EventType>()
        SwenStorage.buses.append(bus)
        return bus
    }
}

// MARK: private helpers
fileprivate extension Swen {

    func register(_ observer: AnyObject, onQueue queue: OperationQueue, handler: @escaping EventListenerClosure) {
        _ = editListenersSemaphore.wait(timeout: DispatchTime.distantFuture)
        defer { editListenersSemaphore.signal() }

        let listener = EventListener<EventType>(observer, queue, handler)
        listeners.append(listener)
        if let sticky = sticky {
            listener.queue.addOperation {
                listener.post(sticky)
            }
        }
    }

    func post(_ event: EventType) {
        _ = stickySemaphore.wait(timeout: DispatchTime.distantFuture)
        if event is StickyEvent {
            sticky = event
        }
        stickySemaphore.signal()

        for listener in listeners {
            listener.post(event)
        }
    }

    func unregister(_ observer: AnyObject) {
        _ = editListenersSemaphore.wait(timeout: DispatchTime.distantFuture)
        defer { editListenersSemaphore.signal() }

        listeners = listeners.filter { $0.observer !== observer }
    }

}

// MARK: subscriber holder
fileprivate class EventListener<EventType: Event> {

    typealias EventListenerClosure = Swen<EventType>.EventListenerClosure
    weak var observer: AnyObject?
    let queue: OperationQueue
    let handler: EventListenerClosure
    let eventClassName: String

    init(_ observer: AnyObject, _ queue: OperationQueue, _ handler: @escaping EventListenerClosure) {
        self.observer = observer
        self.handler = handler
        self.queue = queue
        self.eventClassName = String(describing: observer)
    }

    func post(_ event: EventType) {
        guard let _ = observer else {
            fatalError("One of the observers did not unregister, but already dealocated, observer info: " + eventClassName)
        }

        if OperationQueue.current == queue {
            handler(event)
        } else {
            queue.addOperation {
                self.handler(event)
            }
        }
    }

}

fileprivate struct SwenStorage {

    static var buses = [AnyObject]()
    static let instanceSemaphore = DispatchSemaphore(value: 1)

}
