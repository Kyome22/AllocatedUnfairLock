import Testing
@testable import AllocatedUnfairLock

@Suite("Generic Return")
struct GenericReturnTests {
    @Test("withLock can return Void")
    func withLockCanReturnVoid() {
        let lock = AllocatedUnfairLock(initialState: 0)
        let voidResult: Void = lock.withLock { $0 = 1 }
        _ = voidResult
        #expect(lock.withLock { $0 } == 1)
    }

    @Test("withLock can return String")
    func withLockCanReturnString() {
        let lock = AllocatedUnfairLock(initialState: 5)
        let result = lock.withLock { value in
            "value is \(value)"
        }
        #expect(result == "value is 5")
    }

    @Test("withLock can return a tuple of Sendables")
    func withLockCanReturnTupleOfSendables() {
        let lock = AllocatedUnfairLock(initialState: 3)
        let result = lock.withLock { value -> (Int, Bool) in
            (value, value > 0)
        }
        #expect(result.0 == 3)
        #expect(result.1 == true)
    }

    @Test("withLock can return an Optional Sendable")
    func withLockCanReturnOptional() throws {
        let lock = AllocatedUnfairLock(initialState: [10, 20])
        let first = lock.withLock { $0.first }
        let unwrapped = try #require(first)
        #expect(unwrapped == 10)
    }
}
