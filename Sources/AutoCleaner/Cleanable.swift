/// Represents a collection that can be cleaned based on a condition.
public protocol Cleanable {
    associatedtype Element
    var elements: [Element] { get }

    /// Cleans the collection based on a specified condition.
    /// - Parameter condition: The condition upon which elements should be removed.
    func clean(using condition: (Element) -> Bool) -> Self
}

public extension Cleanable {
    var count: Int { elements.count }
}

extension Array: Cleanable {
    public var elements: [Element] { return self }

    public func clean(using condition: (Element) -> Bool) -> Self {
        filter { !condition($0) }
    }
}

extension Set: Cleanable {
    public var elements: [Element] { return Array(self) }

    public func clean(using condition: (Element) -> Bool) -> Self {
        Set(filter { !condition($0) })
    }
}

extension Dictionary: Cleanable {
    public var elements: [Element] { return Array(self) }

    public func clean(using condition: (Element) -> Bool) -> Self {
        filter { !condition($0) }
    }
}
