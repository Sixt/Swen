//
//  LinkedList.swift
//  Swen
//
//  Created by Dmitry Poznukhov on 27.03.18.
//  Copyright (c) 2019 Sixt SE. All rights reserved.
//

import Foundation

class Node<Type> {
    let value: Type
    weak var prev: Node<Type>?
    var next: Node<Type>?
    init(_ value: Type) {
        self.value = value
    }
}

class LinkedList<Type>: Sequence {
    var first: Node<Type>?
    var last: Node<Type>?

    func makeIterator() -> LinkedListIterator<Type> {
        return LinkedListIterator(linkedList: self, current: nil)
    }

    func append(_ value: Type) {
        if let last = last {
            last.next = Node(value)
            last.next?.prev = last
            self.last = last.next
        } else {
            self.first = Node(value)
            self.last = self.first
        }
    }

    func filter(comparator: (Type) -> (Bool)) {
        guard let first = first else { return }
        guard let last = last else { return }

        var item: Node<Type>? = first
        while item != nil {
            if let item = item, !comparator(item.value) {
                let prev = item.prev
                item.prev?.next = item.next
                item.next?.prev = prev
                if item === first {
                    self.first = item.next
                }
                if item === last {
                    self.last = item.prev
                }
            }
            item = item?.next
        }
    }
}

struct LinkedListIterator<Type>: IteratorProtocol {
    let linkedList: LinkedList<Type>
    var current: Node<Type>?

    mutating func next() -> Type? {
        if let current = current {
            self.current = current.next
            return self.current?.value
        }
        self.current = linkedList.first
        return self.current?.value
    }
}
