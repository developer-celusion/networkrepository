import XCTest
@testable import NetworkRepository

final class NetworkRepositoryTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(NetworkRepository().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
