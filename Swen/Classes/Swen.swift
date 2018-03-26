//
//  Swen.swift
//  Sixt-iOS
//
//  Created by Dmitry Poznukhov on 03/11/16.
//  Copyright © 2016 e-Sixt GmbH & Co. KG. All rights reserved.
//

import Foundation

public protocol BaseEvent {}
public protocol Event: BaseEvent {}
public protocol StickyEvent: BaseEvent {}

fileprivate class Mutex {
    var value = 1
    let semaphore = DispatchSemaphore(value: 1)

    func wait() {
        value -= 1
        semaphore.wait()
    }

    func signal() {
        value += 1
        semaphore.signal()
    }

    var isMuted: Bool { return value > 0 }
}

public class SwenStorage {

    fileprivate var buses = [AnyObject]()
    fileprivate let instanceMutex = Mutex()

    static public let defaultStorage = SwenStorage()

    public init() {}
}

public class Swen<EventType: BaseEvent> {

    internal var listeners = [EventListener<EventType>]()
    public typealias EventListenerClosure = (_ event: EventType) -> Void
    fileprivate var sticky: EventType?
    fileprivate let editListenersMutex = Mutex()
    fileprivate let stickyMutex = Mutex()

}

// MARK: public non sticky events interface
public extension Swen where EventType: Event {

    static func register(_ observer: AnyObject, in storage: SwenStorage = .defaultStorage, onQueue queue: OperationQueue = .main, handler: @escaping EventListenerClosure) {
        instance(in: storage).register(observer, onQueue: queue, handler: handler)
    }

    static func registerOnBackground(_ observer: AnyObject, in storage: SwenStorage = .defaultStorage, handler: @escaping EventListenerClosure) {
        register(observer, in: storage, onQueue: creteBackgroundQueue(for: observer), handler: handler)
    }

    static func post(_ event: EventType, in storage: SwenStorage = .defaultStorage) {
        instance(in: storage).post(event)
    }

}

// MARK: public sticky events interface
public extension Swen where EventType: StickyEvent {

    static func register(_ observer: AnyObject, in storage: SwenStorage = .defaultStorage, onQueue queue: OperationQueue = .main, handler: @escaping EventListenerClosure) {
        instance(in: storage).register(observer, onQueue: queue, handler: handler)
    }

    static func registerOnBackground(_ observer: AnyObject, in storage: SwenStorage = .defaultStorage, handler: @escaping EventListenerClosure) {
        register(observer, in: storage, onQueue: creteBackgroundQueue(for: observer), handler: handler)
    }

    static func post(_ event: EventType, in storage: SwenStorage = .defaultStorage) {
        instance(in: storage).post(event)
    }

    static func sticky(in storage: SwenStorage = .defaultStorage) -> EventType? {
        return instance(in: storage).sticky
    }

}

// MARK: public interface
public extension Swen {

    static func unregister(_ observer: AnyObject, in storage: SwenStorage = .defaultStorage) {
        instance(in: storage).unregister(observer)
    }

}

// MARK: instantiation
internal extension Swen {

    static func instance(in storage: SwenStorage) -> Swen<EventType> {
        storage.instanceMutex.wait()
        defer { storage.instanceMutex.signal() }

        for case let bus as Swen<EventType> in storage.buses {
            return bus
        }

        let bus = Swen<EventType>()
        storage.buses.append(bus)
        return bus
    }
}

// MARK: private non sticky methods
fileprivate extension Swen where EventType: Event {

    func register(_ observer: AnyObject, onQueue queue: OperationQueue, handler: @escaping EventListenerClosure) {
        editListenersMutex.wait()
        defer { editListenersMutex.signal() }

        let listener = EventListener<EventType>(observer, queue, handler)
        listeners.append(listener)
    }

    func post(_ event: EventType) {
        postToAll(event)
    }

}

// MARK: private sticky methods
fileprivate extension Swen where EventType: StickyEvent {

    func register(_ observer: AnyObject, onQueue queue: OperationQueue, handler: @escaping EventListenerClosure) {
        editListenersMutex.wait()
        defer { editListenersMutex.signal() }

        let listener = EventListener<EventType>(observer, queue, handler)
        listeners.append(listener)
        if let sticky = sticky {
            listener.queue.addOperation { [weak listener] in
                listener?.post(sticky, async: false)
            }
        }
    }

    func post(_ event: EventType) {
        stickyMutex.wait()
        defer { stickyMutex.signal() }
        sticky = event
        postToAll(event)
    }

}

// MARK: private helpers
fileprivate extension Swen {

    static func creteBackgroundQueue(for observer: AnyObject) -> OperationQueue {
        let queue = OperationQueue()
        queue.name = "com.sixt.Swen " + String(describing: EventType.self) + String(describing: observer)
        return queue
    }

    func postToAll(_ event: EventType) {
        editListenersMutex.wait()
        defer { editListenersMutex.signal() }
        listeners.forEach { $0.post(event, async: editListenersMutex.value <= 0) }
    }

    func unregister(_ observer: AnyObject) {
        editListenersMutex.wait()
        defer { editListenersMutex.signal() }
        let pointer = UnsafeRawPointer(Unmanaged.passUnretained(observer).toOpaque())
        listeners = listeners.filter { $0.observerPointer != pointer }
    }

}

// MARK: subscriber holder
internal class EventListener<EventType: BaseEvent> {

    typealias EventListenerClosure = Swen<EventType>.EventListenerClosure
    weak var observer: AnyObject?
    let observerPointer: UnsafeRawPointer
    let queue: OperationQueue
    let handler: EventListenerClosure
    let eventClassName: String

    init(_ observer: AnyObject, _ queue: OperationQueue, _ handler: @escaping EventListenerClosure) {
        self.observer = observer
        self.observerPointer = UnsafeRawPointer(Unmanaged.passUnretained(observer).toOpaque())
        self.handler = handler
        self.queue = queue
        self.eventClassName = String(describing: observer)
    }

    func post(_ event: EventType, async: Bool) {
        guard let _ = observer else {
            assertionFailure("One of the observers did not unregister, but already dealocated, observer info: " + eventClassName)
            return
        }

        if !async && OperationQueue.current == queue {
            handler(event)
        } else {
            queue.addOperation { [weak self] in
                self?.handler(event)
            }
        }
    }

}
