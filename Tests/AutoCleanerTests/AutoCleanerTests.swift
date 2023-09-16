@testable import AutoCleaner
import XCTest

final class AutoCleanerTests: XCTestCase {
    var cleaner: AutoCleaner<[Int]>!
    var condition: (Int) -> Bool = { $0 % 2 == 0 }
    var cleanedCount: Int? = nil

    override func setUp() {
        super.setUp()
        cleaner = AutoCleaner([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], condition: condition)
        cleanedCount = nil
    }

    func testInitialization() {
        XCTAssertEqual(cleaner.collection.count, 10)
    }

    func testCleanMethod() {
        cleaner.clean()
        XCTAssertEqual(cleaner.collection.count, 5)
        XCTAssertTrue(cleaner.collection.elements.allSatisfy { !$0.isMultiple(of: 2) })
    }

    func testUpdateMethod() {
        cleaner.update { collection in collection.append(11) }
        XCTAssertEqual(cleaner.collection.count, 11)
        XCTAssertTrue(cleaner.collection.elements.contains(11))
    }

    func testTimerCleanup() {
        cleaner.start { _ in .milliseconds(100) }

        let expect = expectation(description: "Waiting for cleaner")
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            XCTAssertEqual(self.cleaner.collection.count, 5)
            XCTAssertTrue(self.cleaner.collection.elements.allSatisfy { !$0.isMultiple(of: 2) })
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
    
    func testTimerCleanupWithUpdate() {
        cleaner.start { _ in .milliseconds(500) }
        cleaner.update { collection in
            collection.append(contentsOf: [11, 12, 13, 14, 15, 16])
        }
        let expect = expectation(description: "Waiting for cleaner")
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
            XCTAssertEqual(self.cleaner.collection.count, 8)
            XCTAssertTrue(self.cleaner.collection.elements.allSatisfy { !$0.isMultiple(of: 2) })
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }

    func testTimerCleanupWithCallback() {
        cleaner.onCleaned = { [weak self] count in
            self?.cleanedCount = count
        }

        cleaner.start { _ in .milliseconds(500) }

        let expect = expectation(description: "Waiting for cleaner")

        XCTAssertEqual(cleaner.collection.count, 10)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
            XCTAssertEqual(self.cleaner.collection.count, 5)
            XCTAssertTrue(self.cleaner.collection.elements.allSatisfy { !$0.isMultiple(of: 2) })
            XCTAssertEqual(self.cleanedCount, 5)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testTimerIntervalExecution() {
        let testInterval = DispatchTimeInterval.milliseconds(100)
        var executionCount = 0

        cleaner.onCleaned = { _ in executionCount += 1 }
        cleaner.start { _ in testInterval }

        let expect = expectation(description: "Wait for timer execution")
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
            XCTAssertEqual(executionCount, 5)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testStopMethod() {
        cleaner.start { _ in .milliseconds(100) }
        cleaner.stop()

        let expect = expectation(description: "Waiting for cleaner to not clean")
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            XCTAssertEqual(self.cleaner.collection.count, 10)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    override func tearDown() {
        cleaner = nil
        super.tearDown()
    }
}
