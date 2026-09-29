//! `keber --report`: the repository's bug form, with what a report needs already filled in.
//!
//! The version, the TigerBeetle client and the platform are the three things every bug report is
//! asked for first, and the three things nobody remembers exactly. This fills them into the issue
//! form's fields through its URL, opens it in a browser and prints it too, for a machine without
//! one. Nothing is sent anywhere: the form opens, and whoever filed it submits it or doesn't.

use std::path::Path;

pub const REPOSITORY: &str = "https://github.com/golobitch/keber";

/// The fields of `.github/ISSUE_TEMPLATE/bug.yml` this fills in, by their `id`.
pub struct Report {
    pub version: String,
    pub tigerbeetle: String,
    pub environment: String,
}

impl Report {
    pub fn current() -> Self {
        let os = match std::env::consts::OS {
            "macos" => macos_version(Path::new(
                "/System/Library/CoreServices/SystemVersion.plist",
            ))
            .map_or_else(|| "macOS".to_string(), |v| format!("macOS {v}")),
            "linux" => linux_name(Path::new("/etc/os-release")).unwrap_or_else(|| "Linux".into()),
            other => other.to_string(),
        };
        let terminal = std::env::var("TERM").unwrap_or_else(|_| "unknown".into());
        Report {
            version: env!("CARGO_PKG_VERSION").to_string(),
            tigerbeetle: format!("tb_client {}; server: ", tbclient::CLIENT_VERSION),
            environment: format!("{os}, {}, TERM={terminal}", std::env::consts::ARCH),
        }
    }

    pub fn url(&self) -> String {
        let fields = [
            ("template", "bug.yml"),
            ("component", "Terminal UI (keber)"),
            ("version", self.version.as_str()),
            ("tigerbeetle", self.tigerbeetle.as_str()),
            ("environment", self.environment.as_str()),
        ];
        let query: Vec<String> = fields
            .iter()
            .map(|(key, value)| format!("{key}={}", encode(value)))
            .collect();
        format!("{REPOSITORY}/issues/new?{}", query.join("&"))
    }
}

/// Percent-encodes everything outside RFC 3986's unreserved set, byte by byte, so `&`, `=`, `+`
/// and spaces inside a value can never be read as the query's own punctuation.
fn encode(value: &str) -> String {
    let mut out = String::with_capacity(value.len());
    for byte in value.bytes() {
        match byte {
            b'A'..=b'Z' | b'a'..=b'z' | b'0'..=b'9' | b'-' | b'.' | b'_' | b'~' => {
                out.push(byte as char)
            }
            _ => out.push_str(&format!("%{byte:02X}")),
        }
    }
    out
}

/// `PRETTY_NAME` from os-release, e.g. "Debian GNU/Linux 12 (bookworm)".
fn linux_name(path: &Path) -> Option<String> {
    parse_os_release(&std::fs::read_to_string(path).ok()?)
}

fn parse_os_release(text: &str) -> Option<String> {
    text.lines()
        .find_map(|line| line.strip_prefix("PRETTY_NAME="))
        .map(|value| value.trim().trim_matches('"').to_string())
        .filter(|value| !value.is_empty())
}

/// `ProductVersion` from SystemVersion.plist, read as text: it is a plain XML plist, and a plist
/// parser would be a dependency for one string.
fn macos_version(path: &Path) -> Option<String> {
    parse_product_version(&std::fs::read_to_string(path).ok()?)
}

fn parse_product_version(plist: &str) -> Option<String> {
    let after_key = plist.split("<key>ProductVersion</key>").nth(1)?;
    let value = after_key
        .split("<string>")
        .nth(1)?
        .split("</string>")
        .next()?;
    Some(value.trim().to_string()).filter(|v| !v.is_empty())
}

/// Hands the link to the platform's opener. Failing is fine: the link is printed either way.
pub fn open(url: &str) -> bool {
    let opener = if cfg!(target_os = "macos") {
        "open"
    } else {
        "xdg-open"
    };
    std::process::Command::new(opener)
        .arg(url)
        .stdout(std::process::Stdio::null())
        .stderr(std::process::Stdio::null())
        .status()
        .is_ok_and(|status| status.success())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn report() -> Report {
        Report {
            version: "0.2.0".into(),
            tigerbeetle: "tb_client 0.17.9; server: ".into(),
            environment: "Debian GNU/Linux 12 (bookworm), x86_64, TERM=xterm-256color".into(),
        }
    }

    #[test]
    fn the_link_opens_the_bug_form_with_its_fields_filled_in() {
        let url = report().url();
        assert!(
            url.starts_with("https://github.com/golobitch/keber/issues/new?template=bug.yml&"),
            "{url}"
        );
        assert!(
            url.contains("&component=Terminal%20UI%20%28keber%29&"),
            "{url}"
        );
        assert!(url.contains("&version=0.2.0&"), "{url}");
        assert!(
            url.contains("&tigerbeetle=tb_client%200.17.9%3B%20server%3A%20&"),
            "{url}"
        );
    }

    #[test]
    fn punctuation_inside_a_value_cannot_split_the_query() {
        assert_eq!(encode("a&b=c+d e/f?"), "a%26b%3Dc%2Bd%20e%2Ff%3F");
        assert_eq!(encode("čšž"), "%C4%8D%C5%A1%C5%BE");
        assert_eq!(encode("Az09-._~"), "Az09-._~");
    }

    #[test]
    fn reads_the_distribution_from_os_release() {
        let text = "NAME=\"Debian GNU/Linux\"\nPRETTY_NAME=\"Debian GNU/Linux 12 (bookworm)\"\nID=debian\n";
        assert_eq!(
            parse_os_release(text).as_deref(),
            Some("Debian GNU/Linux 12 (bookworm)")
        );
        assert_eq!(parse_os_release("ID=alpine\n"), None);
    }

    #[test]
    fn reads_the_macos_version_from_the_system_plist() {
        let plist = "<dict>\n\t<key>ProductName</key>\n\t<string>macOS</string>\n\t<key>ProductVersion</key>\n\t<string>15.4.1</string>\n</dict>";
        assert_eq!(parse_product_version(plist).as_deref(), Some("15.4.1"));
        assert_eq!(parse_product_version("<dict></dict>"), None);
    }

    #[test]
    fn the_current_report_names_this_build() {
        let current = Report::current();
        assert_eq!(current.version, env!("CARGO_PKG_VERSION"));
        assert!(current.tigerbeetle.contains(tbclient::CLIENT_VERSION));
        assert!(current.environment.contains(std::env::consts::ARCH));
    }
}
