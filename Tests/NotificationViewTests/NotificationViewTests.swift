import XCTest
@testable import NotificationView

final class NotificationViewTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(NotificationView(at: .top), NotificationView(at: .top))
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
