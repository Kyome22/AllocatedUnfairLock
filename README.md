# AllocatedUnfairLock

A drop-in alternative to `OSAllocatedUnfairLock`, built on Swift's `Synchronization.Mutex`.

![Swift 6.2](https://img.shields.io/badge/Swift-6.2-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20visionOS%20%7C%20watchOS-blue.svg)
![SPM compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

## Overview

`AllocatedUnfairLock` is a custom reimplementation of `OSAllocatedUnfairLock` from the `os` framework. It is composed of two pieces:

- A `final class` that provides the allocation (so the lock has a stable identity and can be shared by reference).
- The `Synchronization.Mutex` type from Swift's standard `Synchronization` framework, which provides the underlying unfair-lock behavior.

The public API mirrors `OSAllocatedUnfairLock` so that switching between the two is straightforward, with one difference: the protected `State` must conform to `Sendable`. This requirement is inherited from `Synchronization.Mutex`.

If your code only accesses the lock from asynchronous contexts, prefer an `actor` instead.

## Requirements

- Swift 6.2+
- iOS 18+ / macOS 15+ / tvOS 18+ / visionOS 2+ / watchOS 11+

## Installation

### Swift Package Manager

Add the package to the `dependencies` array in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Kyome22/AllocatedUnfairLock.git", from: "1.0.0")
]
```

Then add the product to the target that needs it:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "AllocatedUnfairLock", package: "AllocatedUnfairLock")
    ]
)
```

### Xcode

In Xcode, choose **File ▸ Add Package Dependencies…**, paste the repository URL `https://github.com/Kyome22/AllocatedUnfairLock.git`, and add the `AllocatedUnfairLock` product to your target.

## Usage

### Basic counter

```swift
import AllocatedUnfairLock

let counter = AllocatedUnfairLock(initialState: 0)
counter.withLock { value in
    value += 1
}
let snapshot = counter.withLock { $0 }
```

### Returning a value from the closure

```swift
let doubled = counter.withLock { value -> Int in
    value *= 2
    return value
}
```

### Protecting a struct

```swift
struct Stats: Sendable {
    var hits: Int = 0
    var misses: Int = 0
}

let stats = AllocatedUnfairLock(initialState: Stats())
stats.withLock { $0.hits += 1 }
```

## Differences from `OSAllocatedUnfairLock`

| Aspect | `OSAllocatedUnfairLock` | `AllocatedUnfairLock` |
| --- | --- | --- |
| Underlying framework | `os` | `Synchronization` |
| `State` constraint | No `Sendable` requirement | `State: Sendable` is required |
| Available API | `withLock`, `lock`, `unlock`, `lockIfAvailable`, `precondition`, etc. | `init(initialState:)` and `withLock(_:)` |

If you need to protect a value whose type cannot conform to `Sendable`, use the standard `OSAllocatedUnfairLock` from the `os` framework instead.

## License

`AllocatedUnfairLock` is released under the MIT License. See [LICENSE](./LICENSE) for details.

Copyright (c) 2026 Takuto NAKAMURA (Kyome)
