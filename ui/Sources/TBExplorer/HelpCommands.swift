import SwiftUI
import TBKit

/// The Help menu: where Keber lives, and a bug report with this build's versions filled in.
struct HelpCommands: Commands {
    let session: Session
    @Environment(\.openURL) private var openURL

    var body: some Commands {
        // Replaces the stock "Keber Help" item, which would only say that help isn't available.
        CommandGroup(replacing: .help) {
            Button("Keber Website") { openURL(URL(string: "https://keber.io")!) }
            Button("Keber on GitHub") { openURL(BugReport.repository) }
            Divider()
            // Opens the issue form in the browser; nothing is sent until the user submits it there.
            Button("Report a Bug…") { openURL(session.bugReport.url) }
        }
    }
}

extension Session {
    /// What Help → Report a Bug… fills in. The cluster's addresses stay out: whether a connection
    /// is up says enough, and BugReport strips any address that made it into the error text.
    var bugReport: BugReport {
        let info = Bundle.main.infoDictionary ?? [:]
        let version = info["CFBundleShortVersionString"] as? String ?? "unknown"
        let build = info["CFBundleVersion"] as? String ?? "unknown"
        #if arch(arm64)
        let chip = "Apple Silicon"
        #else
        let chip = "Intel"
        #endif
        return BugReport(
            version: "\(version) (\(build))",
            tigerbeetle: "tb_client \(TBClient.clientVersion); connected: \(isConnected ? "yes" : "no")",
            environment: "macOS \(ProcessInfo.processInfo.operatingSystemVersionString), \(chip)",
            lastError: lastError ?? "")
    }
}
