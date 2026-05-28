import Testing
@testable import AllocatedUnfairLock

@Suite("Basic behavior")
struct BasicBehaviorTests {
    @Test("initialState is preserved")
    func initialStateIsPreserved() {
        let lock = AllocatedUnfairLock(initialState: 42)
        #expect(lock.withLock { $0 } == 42)
    }

    @Test("withLock can mutate inout state")
    func withLockCanMutateState() {
        let lock = AllocatedUnfairLock(initialState: 0)
        lock.withLock { value in
            value = 100
        }
        #expect(lock.withLock { $0 } == 100)
    }

    @Test("withLock returns closure result")
    func withLockReturnsClosureResult() {
        let lock = AllocatedUnfairLock(initialState: 10)
        let result = lock.withLock { value -> Int in
            value += 5
            return value * 2
        }
        #expect(result == 30)
        #expect(lock.withLock { $0 } == 15)
    }

    @Test("withLock rethrows closure errors")
    func withLockRethrowsClosureError() {
        let lock = AllocatedUnfairLock(initialState: 0)
        #expect(throws: SampleError(code: 7)) {
            try lock.withLock { _ in
                throw SampleError(code: 7)
            }
        }
    }

    @Test("State reflects mutations performed before a thrown error")
    func stateRemainsConsistentAfterThrow() {
        let lock = AllocatedUnfairLock(initialState: 1)
        _ = try? lock.withLock { value -> Int in
            value = 99
            throw SampleError(code: 0)
        }
        #expect(lock.withLock { $0 } == 99)
    }
}
