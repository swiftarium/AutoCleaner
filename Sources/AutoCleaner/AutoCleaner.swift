import Dispatch

/// An utility that automatically cleans elements from a collection based on a condition at a specified frequency.
open class AutoCleaner<Collection: Cleanable> {
    /// A typealias for the function that determines how frequently the cleaner should operate.
    public typealias Frequency = (_ count: Int) -> DispatchTimeInterval

    /// A typealias for the function that determines which elements should be removed from the collection.
    public typealias Condition = (_ element: Collection.Element) -> Bool

    public private(set) var collection: Collection

    private(set) var frequency: Frequency?
    private(set) var condition: Condition
    private var timer: DispatchSourceTimer?

    /// A callback that fires after cleaning the collection. The integer parameter represents the number of elements removed.
    public var onCleaned: ((_ removedCount: Int) -> Void)?

    /// Initializes the AutoCleaner with the given collection and condition for cleaning.
    /// - Parameters:
    ///   - collection: The collection to be managed by the cleaner.
    ///   - condition: The condition for which elements should be removed.
    public init(_ collection: Collection, condition: @escaping Condition) {
        self.collection = collection
        self.condition = condition
    }

    /// Starts the automatic cleaning with a given frequency.
    /// - Parameter frequency: A function that specifies the frequency based on current element count.
    public func start(_ frequency: @escaping Frequency) {
        self.frequency = frequency
        adjustTimer(force: true)
    }

    /// Stops the automatic cleaning.
    public func stop() {
        timer?.cancel()
        timer = nil
    }

    /// Updates the collection manually.
    /// - Parameter updater: A closure that takes in the current collection and outputs the updated version.
    public func update(_ updater: (_ collection: inout Collection) -> Void) {
        updater(&collection)
    }

    /// Cleans the collection based on the specified or default condition.
    /// - Parameter condition: An optional condition which, if provided, overrides the default condition.
    public func clean(_ condition: Condition? = nil) {
        let beforeCount = collection.count
        collection = collection.clean(using: condition ?? self.condition)
        onCleaned?(beforeCount - collection.count)

        if collection.elements.isEmpty { stop() }
    }

    private func adjustTimer(force: Bool = false) {
        if collection.elements.isEmpty { return }

        timer?.cancel()
        let interval = frequency?(collection.count) ?? .seconds(60)
        let timer = DispatchSource.makeTimerSource()
        timer.schedule(deadline: .now() + interval, repeating: interval)
        timer.setEventHandler { [weak self] in
            self?.clean()
            self?.adjustTimer()
        }
        timer.resume()
        self.timer = timer
    }
}
