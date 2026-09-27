import Foundation
import Testing
@testable import TBKit

@Suite("Deep links")
struct DeepLinkTests {
    private func parse(_ string: String) -> DeepLink? {
        URL(string: string).flatMap { DeepLink($0) }
    }

    private func parse(_ string: String, cluster: inout UInt128?) -> DeepLink? {
        guard let url = URL(string: string) else { return nil }
        return DeepLink(url, cluster: &cluster)
    }

    @Test func roundTripsEveryCase() {
        let links: [DeepLink] = [
            .overview, .search, .accounts, .transfers,
            .ledger(840), .account(1015), .transfer(100_539),
        ]
        for link in links {
            #expect(DeepLink(link.url()) == link, "\(link.url().absoluteString)")
        }
    }

    @Test func writesTheExpectedURL() {
        #expect(DeepLink.transfer(100_539).url().absoluteString == "keber://transfer/100539")
        #expect(DeepLink.accounts.url().absoluteString == "keber://accounts")
        #expect(
            DeepLink.account(1015).url(cluster: 7).absoluteString
                == "keber://account/1015?cluster=7")
    }

    @Test func carriesTheClusterWhenPresent() {
        var cluster: UInt128?
        #expect(parse("keber://transfer/100539?cluster=42", cluster: &cluster) == .transfer(100_539))
        #expect(cluster == 42)
    }

    @Test func leavesTheClusterUnsetWhenAbsent() {
        var cluster: UInt128?
        #expect(parse("keber://transfer/100539", cluster: &cluster) == .transfer(100_539))
        #expect(cluster == nil)
    }

    @Test func keepsFullPrecisionIDs() {
        let id = UInt128.max
        var cluster: UInt128?
        let url = DeepLink.account(id).url(cluster: .max)
        #expect(DeepLink(url, cluster: &cluster) == .account(id))
        #expect(cluster == .max)
    }

    @Test func acceptsHexIDs() {
        #expect(parse("keber://account/0xff") == .account(255))
    }

    /// The parser also reads `keber:transfer/100539`, but that spelling is not asserted:
    /// whether `URL(string:)` accepts it, and where it puts the first segment, varies by
    /// Foundation version. Everything the app produces and macOS delivers uses `//`.
    @Test func ignoresSchemeCase() {
        #expect(parse("KEBER://Transfer/100539") == .transfer(100_539))
    }

    /// Links written while the app was TigerBeetle Explorer are in tickets and runbooks; they
    /// keep opening, and what the app writes back is the new scheme.
    @Test func opensLinksFromBeforeTheRename() {
        var cluster: UInt128?
        #expect(parse("tb-explorer://transfer/100539?cluster=42", cluster: &cluster) == .transfer(100_539))
        #expect(cluster == 42)
        #expect(parse("TB-EXPLORER://ledger/840") == .ledger(840))
        #expect(DeepLink(URL(string: "tb-explorer://accounts")!)?.url().absoluteString == "keber://accounts")
    }

    @Test func rejectsAnythingElse() {
        #expect(parse("https://example.com/transfer/100539") == nil)
        #expect(parse("keber://nonsense/1") == nil)
        #expect(parse("keber://transfer") == nil, "an id is required")
        #expect(parse("keber://account/not-a-number") == nil)
        #expect(parse("keber://ledger/99999999999") == nil, "a ledger is a u32")
    }

    @Test func rejectsAnUnparsableCluster() {
        var cluster: UInt128?
        #expect(parse("keber://transfer/1?cluster=abc", cluster: &cluster) == nil)
    }
}
