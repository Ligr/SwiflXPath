import Foundation
import libxml2

public final class SwiftXPath {

    private let doc: xmlDocPtr

    public init?(xml: String) {
        guard let doc = xml.cString(using: .utf8)!.withUnsafeBufferPointer({
            xmlReadMemory($0.baseAddress, numericCast($0.count), nil, "utf-8", Int32(XML_PARSE_RECOVER.rawValue))
        }) else {
            return nil
        }
        self.doc = doc
    }

    public init?(html: String) {
        guard let doc = html.cString(using: .utf8)!.withUnsafeBufferPointer({
            htmlReadMemory($0.baseAddress, numericCast($0.count), nil, "utf-8", Int32(HTML_PARSE_NOBLANKS.rawValue | HTML_PARSE_NOERROR.rawValue | HTML_PARSE_NOWARNING.rawValue | HTML_PARSE_NONET.rawValue | HTML_PARSE_NOIMPLIED.rawValue))
        }) else {
            return nil
        }
        self.doc = doc
    }

    deinit {
        xmlFreeDoc(doc)
    }

    // MARK: - API

    public func content(for xpath: String) -> [String] {
        guard let xpathObject = perform(xpath: xpath, in: doc), let xpathResult = xpathObject.pointee.nodesetval else {
            return []
        }
        var results = [String]()
        for i in 0 ..< xpathResult.pointee.nodeNr {
            let xmlNode = xpathResult.pointee.nodeTab[Int(i)]
            let buff = xmlBufferCreate()
            let result = xmlNodeDump(buff, doc, xmlNode, 0, 0)
            if result > -1, let buff = buff {
                let str = String(cString: xmlBufferContent(buff))
                results.append(str)
            }
            xmlBufferFree(buff)
        }
        xmlXPathFreeObject(xpathObject)
        return results
    }

    // MARK: - Helpers

    private func perform(xpath: String, in doc: xmlDocPtr) -> xmlXPathObjectPtr? {
        guard let xpathCtx = xmlXPathNewContext(doc) else {
            return nil
        }

        let result = xpath.cString(using: .utf8)?.withUnsafeBytes {
            xmlXPathEvalExpression($0.bindMemory(to: UInt8.self).baseAddress!, xpathCtx)
        }

        xmlXPathFreeContext(xpathCtx)

        return result
    }
}
