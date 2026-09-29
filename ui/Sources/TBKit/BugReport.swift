import Foundation

/// The repository's bug form, with what a report needs already filled in: the fields of
/// `.github/ISSUE_TEMPLATE/bug.yml`, by their `id`, passed through the issue URL.
///
/// Nothing is sent anywhere. The form opens in a browser, and whoever filed it reads it, edits it,
/// and submits it or doesn't.
public struct BugReport: Equatable, Sendable {
    public static let repository = URL(string: "https://github.com/golobitch/keber")!

    public var version: String
    public var tigerbeetle: String
    public var environment: String
    /// The last error the app showed, with cluster addresses taken out. Empty when there was none.
    public var lastError: String

    public init(version: String, tigerbeetle: String, environment: String, lastError: String = "") {
        self.version = version
        self.tigerbeetle = tigerbeetle
        self.environment = environment
        self.lastError = BugReport.redactingAddresses(lastError)
    }

    public var url: URL {
        var fields = [
            ("template", "bug.yml"),
            ("component", "macOS app"),
            ("version", version),
            ("tigerbeetle", tigerbeetle),
            ("environment", environment),
        ]
        if !lastError.isEmpty { fields.append(("last-error", lastError)) }
        let query = fields.map { "\($0.0)=\(Self.encode($0.1))" }.joined(separator: "&")
        return URL(string: Self.repository.absoluteString + "/issues/new?" + query)!
    }

    /// Everything outside RFC 3986's unreserved set is escaped, so `&`, `=`, `+` and spaces inside
    /// a value can never be read as the query's own punctuation. URLComponents leaves `+` alone,
    /// which the form would read as a space; hence building the query by hand.
    private static let unreserved = CharacterSet(
        charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")

    static func encode(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: unreserved) ?? ""
    }

    /// An issue is public, and a cluster's addresses are not something to publish by accident:
    /// IPv4 and bracketed IPv6 addresses, with or without a port, become `<address>`.
    public static func redactingAddresses(_ text: String) -> String {
        let patterns = [
            #"\[[0-9A-Fa-f:.]+\](:\d+)?"#,
            #"\b(\d{1,3}\.){3}\d{1,3}(:\d+)?\b"#,
        ]
        return patterns.reduce(text) { text, pattern in
            text.replacingOccurrences(of: pattern, with: "<address>", options: .regularExpression)
        }
    }
}
