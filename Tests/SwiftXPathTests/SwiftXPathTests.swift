@testable import SwiftXPath
import XCTest

final class SwiftXPathTests: XCTestCase {
    func testRussianSymbolsInXML() throws {
        let xmlString = """
        <figure><img src="https://rh.by/wp-content/uploads/2022/01/дзяўчынка-696x462.jpg"/></figure>
        """
        let xml = SwiftXPath(xml: xmlString)!
        let content = xml.content(for: "//img")
        XCTAssert(content[0] == "<img src=\"https://rh.by/wp-content/uploads/2022/01/дзяўчынка-696x462.jpg\"/>")
    }

    func testRussianSymbolsInHTML() throws {
        let xmlString = """
        <figure><img src="https://rh.by/wp-content/uploads/2022/01/дзяўчынка-696x462.jpg"/></figure>
        """
        let xml = SwiftXPath(html: xmlString)!
        let content = xml.content(for: "//img")
        XCTAssert(content[0] == "<img src=\"https://rh.by/wp-content/uploads/2022/01/дзяўчынка-696x462.jpg\"/>")
    }
}
