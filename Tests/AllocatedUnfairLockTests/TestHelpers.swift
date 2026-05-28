struct SampleError: Error, Equatable {
    let code: Int
}

struct PairState: Sendable, Equatable {
    var left: Int
    var right: String
}

final class Box: Sendable {
    let identifier: Int
    init(identifier: Int) { self.identifier = identifier }
}

enum Status: Sendable, Equatable {
    case idle
    case running(progress: Double)
    case finished
}
