# Security

Keber connects to TigerBeetle clusters that hold money, so a bug that could make it write to a
cluster, leak where a cluster lives, or run something it shouldn't is a security issue, not an
ordinary bug.

## Reporting

Please report privately through GitHub:
[Report a vulnerability](https://github.com/golobitch/keber/security/advisories/new). Don't open a
public issue for it.

Say what you found, which version and front end it affects, and how to reproduce it. You'll get an
answer within a few days, and credit in the advisory unless you'd rather not.

## What is in scope

- Anything that makes the app or the terminal UI issue `create_accounts` or `create_transfers`
- A `keber://` or `tb-explorer://` link that connects somewhere, or reveals an address
- The app writing outside its sandbox container or a file the user picked
- The release pipeline: tampered artifacts, checksums that don't verify, the apt repository's signing
- keber.io serving something other than what this repository built

TigerBeetle itself is out of scope; report those to [TigerBeetle](https://github.com/tigerbeetle/tigerbeetle/security).
