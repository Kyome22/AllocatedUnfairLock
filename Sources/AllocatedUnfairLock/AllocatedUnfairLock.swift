import Synchronization

/// An `AllocatedUnfairLock` is a custom `OSAllocatedUnfairLock made
/// using `class` and `Mutex` of Synchronization framework.
///
/// Prefer storing state protected by the lock in `State`. Containing locked state
/// inside the lock helps track what is protected state and provides a scope
/// where it is safe to access that state.
///
/// If you are using a lock from asynchronous contexts only,
/// prefer using an actor instead.
public final class AllocatedUnfairLock<State>: Sendable where State : Sendable {
    let value: Mutex<State>

    /// Initialize an AllocatedUnfairLock with a lock-protected sendable `initialState`.
    /// - Parameter initialState: An initial value to store that will be protected under the lock.
    public init(initialState: State) {
        value = .init(initialState)
    }


    ///  Perform a sendable closure while holding this lock.
    /// - Parameter body: A sendable closure to invoke while holding this lock.
    /// - Returns: The sendable return value of `body`.
    /// - Throws: Anything thrown by `body`.
    public func withLock<R: Sendable>(_ body: @Sendable (inout State) throws -> R) rethrows -> R {
        try value.withLock { try body(&$0) }
    }
}
