/// Represents a collection that can be cleaned based on a condition.
public protocol Cleanable {
    associatedtype CleanableElement

    var count: Int { get }
    var isEmpty: Bool { get }

    /// Cleans the collection based on a specified condition.
    /// - Parameter condition: The condition upon which elements should be removed.
    func clean(using condition: (CleanableElement) -> Bool) -> Self
}

extension Array: Cleanable {
    public typealias CleanableElement = Element
    public func clean(using condition: (CleanableElement) -> Bool) -> Self {
        filter { !condition($0) }
    }
}

extension Set: Cleanable {
    public typealias CleanableElement = Element
    public func clean(using condition: (CleanableElement) -> Bool) -> Self {
        Set(filter { !condition($0) })
    }
}

extension Dictionary: Cleanable {
    public typealias CleanableElement = Element

    public func clean(using condition: (CleanableElement) -> Bool) -> Self {
        filter { !condition($0) }
    }
}
