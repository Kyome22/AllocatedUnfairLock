import Testing
@testable import AllocatedUnfairLock

@Suite("Generic State")
struct GenericStateTests {
    @Test("Struct state can be mutated and read")
    func structStateRoundTrip() {
        let lock = AllocatedUnfairLock(initialState: PairState(left: 1, right: "a"))
        lock.withLock { pair in
            pair.left = 2
            pair.right = "b"
        }
        #expect(lock.withLock { $0 } == PairState(left: 2, right: "b"))
    }

    @Test("Reference-type state retains its identity")
    func classStateRetainsIdentity() {
        let original = Box(identifier: 7)
        let lock = AllocatedUnfairLock(initialState: original)
        let retrieved = lock.withLock { $0 }
        #expect(retrieved === original)
        #expect(retrieved.identifier == 7)
    }

    @Test("Enum state transitions correctly")
    func enumStateTransitions() {
        let lock = AllocatedUnfairLock(initialState: Status.idle)
        lock.withLock { $0 = .running(progress: 0.5) }
        #expect(lock.withLock { $0 } == .running(progress: 0.5))
        lock.withLock { $0 = .finished }
        #expect(lock.withLock { $0 } == .finished)
    }

    @Test("Array state supports append")
    func arrayStateSupportsAppend() {
        let lock = AllocatedUnfairLock(initialState: [Int]())
        lock.withLock { $0.append(1) }
        lock.withLock { $0.append(2) }
        #expect(lock.withLock { $0 } == [1, 2])
    }

    @Test("Optional state transitions between nil and value")
    func optionalStateTransitionsBetweenNilAndValue() {
        let lock = AllocatedUnfairLock<String?>(initialState: nil)
        lock.withLock { $0 = "hello" }
        #expect(lock.withLock { $0 } == "hello")
        lock.withLock { $0 = nil }
        #expect(lock.withLock { $0 } == nil)
    }

    @Test(
        "Integer initialState is preserved across various values",
        arguments: [Int.min, -1, 0, 1, 42, Int.max]
    )
    func integerInitialStateIsPreservedAcrossValues(initial: Int) {
        let lock = AllocatedUnfairLock(initialState: initial)
        #expect(lock.withLock { $0 } == initial)
    }
}
