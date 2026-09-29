import Foundation
import Testing
@testable import TBKit

@Suite("Bug report")
struct BugReportTests {
    private func query(_ url: URL) -> [String: String] {
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        return Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value ?? "") })
    }

    @Test func opensTheBugFormWithItsFieldsFilledIn() {
        let report = BugReport(
            version: "0.1.0 (42)", tigerbeetle: "tb_client 0.17.9; connected: yes",
            environment: "macOS Version 15.4 (Build 24E248), Apple Silicon")
        let url = report.url
        #expect(url.absoluteString.hasPrefix("https://github.com/golobitch/keber/issues/new?template=bug.yml&"))
        let fields = query(url)
        #expect(fields["component"] == "macOS app")
        #expect(fields["version"] == "0.1.0 (42)")
        #expect(fields["tigerbeetle"] == "tb_client 0.17.9; connected: yes")
        #expect(fields["last-error"] == nil, "no error, no field")
    }

    /// A `+` left unescaped would reach the form as a space, and `&` would end the field.
    @Test func punctuationInsideAValueCannotSplitTheQuery() {
        let report = BugReport(version: "1", tigerbeetle: "x", environment: "a+b & c=d")
        #expect(!report.url.absoluteString.contains("+"))
        #expect(query(report.url)["environment"] == "a+b & c=d")
        #expect(BugReport.encode("a&b=c+d e/f?") == "a%26b%3Dc%2Bd%20e%2Ff%3F")
        #expect(BugReport.encode("čšž") == "%C4%8D%C5%A1%C5%BE")
    }

    @Test func takesClusterAddressesOutOfTheLastError() {
        let report = BugReport(
            version: "1", tigerbeetle: "x", environment: "y",
            lastError: "could not reach 10.0.3.7:3000 or 192.168.1.20, nor [2001:db8::1]:3001")
        #expect(report.lastError == "could not reach <address> or <address>, nor <address>")
        #expect(query(report.url)["last-error"] == report.lastError)
    }

    @Test func leavesVersionNumbersAlone() {
        #expect(BugReport.redactingAddresses("tb_client 0.17.9 refused") == "tb_client 0.17.9 refused")
    }
}
