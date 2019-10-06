# Swen - An Event Bus written in Swift

[![Build Status](https://travis-ci.org/e-Sixt/Swen.svg?branch=master)](https://travis-ci.org/e-Sixt/Swen)
[![codecov](https://codecov.io/gh/e-Sixt/Swen/branch/master/graph/badge.svg)](https://codecov.io/gh/e-Sixt/Swen)
[![Badge w/ Version](https://cocoapod-badges.herokuapp.com/v/Swen/badge.png)](https://cocoadocs.org/docsets/NSStringMask)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/e-Sixt/Swen/master/LICENSE)

- [x] Typesafe events
- [x] Pass custom objects
- [x] Threadsafe
- [x] Sticky events
- [x] Fast and small

## Installation

Swen is available through [CocoaPods](#cocoapods), [Carthage](#carthage) and [Swift Package Manager](#swift-package-manager).

### CocoaPods

To install it using [CocoaPods](https://cocoapods.org), simply add the following line to your Podfile:

```ruby
pod "Swen"
```

### Carthage

To install it via [Carthage](https://github.com/Carthage/Carthage), add the following line to your Cartfile and follow the instructions to [adding frameworks to an application](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application):

```
github "e-Sixt/Swen"
```

### Swift Package Manager

To install it using the [Swift Package Manager](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app), either directly add it to your project using Xcode 11, or specify it as dependency in the Package.swift file:

```swift
// ...
dependencies: [
    .package(url: "https://github.com/e-Sixt/Swen.git", from: "2.0.0"),
],
//...
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 9.0+ / macOS 10.10+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 8.1+
- Swift 3.0+

## Usage
```swift
import Swen

struct TestEvent: Event {
    let name: String
}

class TestViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //register for incoming events
        Swen<TestEvent>.register(self) { event in
            print(event.name)
        }
        //post event
        Swen.post(TestEvent(name: "Sixt"))
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //unregister from events
        Swen<TestEvent>.unregister(self)
    }
}
```

### Register on different threads
```swift
// Registers on the main thread
Swen<Event>.register(_ observer: AnyObject, handler: (_ event: Event) -> Void)

// Registers on background queue
Swen<Event>.registerOnBackground(_ observer: AnyObject, handler: (_ event: Event) -> Void)

// Registers the closure on a specific queue
Swen<Event>.register(_ observer: AnyObject, onQueue queue: OperationQueue, handler: (_ event: Event) -> Void)
```

### Sticky events
Sometimes events carry information that is not only important for that one moment but needs to be kept around longer. For these cases sticky events come in handy. They behave the same as normal events with two further additions. First you can query them by:

```swift
struct TestStickyEvent: StickyEvent {
    let name: String
}

print(Swen<TestStickyEvent>.sticky()?.name)
```
***Important:*** The return sticky is optional, because the event may not be posted yet!

The second additions is that if you register for a sticky event and one was already posted before. It will immediately trigger the registered closure
```swift
class TestViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //post event
        Swen.post(TestStickyEvent(name: "Stick it"))

        //register for incoming events
        Swen<TestStickyEvent>.register(self) { event in
            print(event.name)
        }
    }
}
```

### System Events
To use System Events, write wrapper for interest NSNotifications:
```swift
public struct SystemEvents {

    struct ApplicationWillEnterForeground: Event {
    }

    static func register(storage: SwenStorage = .defaultStorage) {

        let center = NotificationCenter.default

        center.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: nil) { _ in

            Swen.post(ApplicationWillEnterForeground(), in: storage)
        }
    }
}
```

### Dependency Injection
To encapsulate test cases from production code and from each other, we suggest to use Dependency Injection and Storage mechanism:
```swift
class TestViewController: UIViewController {

    var swenStorage = SwenStorage()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //register for incoming events in custom storage
        Swen<TestEvent>.register(self, in: swenStorage) { event in
            print(event.name)
        }

        //register for incoming events in default storage
        Swen<TestEvent>.register(self) { event in
            print(event.name)
        }

        //post event in custom storage
        Swen.post(TestEvent(name: "Sixt, custom storage"), in: swenStorage)

        //post event in default storage
        Swen.post(TestEvent(name: "Sixt, default storage"))
    }
}
```

## Performance
One of the other main benefits of using Swen is the significant performance increase over NSNotificationCenter

| Performance Test                      | NSNotificationCenter | SwiftBus |
| ------------------------------------- | :------------------: | -------: |
| Perform 10ˆ6 Events to 1 receiver     |        6.54s         |    2.61s |
| Perform 10ˆ3 Events to 10ˆ3 receivers |        14.42s        |   11.15s |

### Author
* e-Sixt, sixtlabs@sixt.com

### Contributors:
* Dmitry Poznukhov, dmitry.poznukhov@sixt.com
* Franz Busch,      franz-joseph.busch@sixt.com
* Dedicated to Sven Röder

### License

Swen is available under the MIT license. See the LICENSE file for more info.

![alt text](https://github.com/e-Sixt/Swen/raw/master/logo.png "Logo Title Text 1")
