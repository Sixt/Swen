//
//  LinkedList.swift
//  Swen
//
//  Created by Dmitry Poznukhov on 27.03.18.
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
    var count = 0

    func makeIterator() -> LinkedListIterator<Type> {
        return LinkedListIterator(linkedList: self, current: nil)
    }

    func append(_ value: Type) {
        guard let last = last else {
            self.first = Node(value)
            self.last = self.first
            count += 1
            return
        }
        last.next = Node(value)
        last.next?.prev = last
        self.last = last.next
        count += 1
    }

    func filter(comparator: (Type) -> (Bool)) {
        guard let first = first else { return }
        guard let last = last else { return }

        var item: Node<Type>? = first
        while item != nil {
            if let item = item, !comparator(item.value) {
                let prev = item.prev
                item.prev = item.next
                item.next = prev
                count -= 1
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
        guard let current = current else {
            self.current = linkedList.first
            return self.current?.value
        }
        self.current = current.next
        return self.current?.value
    }
}
