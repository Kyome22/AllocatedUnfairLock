import Testing
@testable import AllocatedUnfairLock

@Suite("Concurrency")
struct ConcurrencyTests {
    @Test("Concurrent increments produce expected total")
    func concurrentIncrementsProduceExpectedTotal() async {
        let lock = AllocatedUnfairLock(initialState: 0)
        let iterationsPerTask = 10_000
        let taskCount = 16

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<taskCount {
                group.addTask {
                    for _ in 0..<iterationsPerTask {
                        lock.withLock { $0 += 1 }
                    }
                }
            }
        }

        #expect(lock.withLock { $0 } == iterationsPerTask * taskCount)
    }

    @Test("Concurrent appends keep array count consistent")
    func concurrentAppendsKeepArrayCountConsistent() async {
        let lock = AllocatedUnfairLock(initialState: [Int]())
        let writerCount = 8
        let appendsPerWriter = 500

        await withTaskGroup(of: Void.self) { group in
            for writerIndex in 0..<writerCount {
                group.addTask {
                    for valueOffset in 0..<appendsPerWriter {
                        lock.withLock { array in
                            array.append(writerIndex * appendsPerWriter + valueOffset)
                        }
                    }
                }
                group.addTask {
                    for _ in 0..<appendsPerWriter {
                        _ = lock.withLock { $0.count }
                    }
                }
            }
        }

        let finalCount = lock.withLock { $0.count }
        #expect(finalCount == writerCount * appendsPerWriter)
    }

    @Test("Two tasks using async let increment safely")
    func twoTasksAsyncLetIncrementSafely() async {
        let lock = AllocatedUnfairLock(initialState: 0)
        async let first: Void = {
            for _ in 0..<5_000 { lock.withLock { $0 += 1 } }
        }()
        async let second: Void = {
            for _ in 0..<5_000 { lock.withLock { $0 += 1 } }
        }()
        _ = await (first, second)
        #expect(lock.withLock { $0 } == 10_000)
    }
}
