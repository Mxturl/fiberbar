# FiberBar

FiberBar is a lightweight SwiftBar controller for SSTP VPN connections on macOS.

It does not implement SSTP itself. It wraps the mature `sstp-client`/`sstpc`
tool, stores passwords in macOS Keychain, manages split routes, and renders a
small menu bar status item.

## Features

- SwiftBar menu bar control for connect, disconnect, reconnect, and route repair.
- Status on the icon itself:
  - green `checkmark.shield.fill`: connected and route probe is healthy
  - yellow `exclamationmark.shield.fill`: process exists but route/PPP health is abnormal
  - red `xmark.shield.fill`: disconnected
  - gray `gearshape.fill`: not configured
- English by default, with Chinese menu text available from the menu.
- User-configurable SSTP server, username, routes, probe host, CA file, and menu label.
- Password storage via macOS Keychain.
- Optional passwordless control through a root-owned helper plus a narrow sudoers rule.
- System proxy health diagnostics for macOS multi-interface/VPN edge cases.

## Requirements

- macOS
- SwiftBar
- Homebrew `sstp-client`

```sh
brew install sstp-client
```

## Install

```sh
./install.sh
fiberbar configure
```

Then refresh SwiftBar.

To also start SwiftBar automatically at login:

```sh
./install.sh --autostart
```

This creates:

```text
~/Library/LaunchAgents/com.fiberbar.swiftbar-autostart.plist
```

## Configure

FiberBar writes configuration to:

```text
~/.config/fiberbar/config
```

Run:

```sh
fiberbar configure
fiberbar set-password
```

Passwords are stored in Keychain under the configured service name. They are not
written to the config file.

## Passwordless Connect/Disconnect

From the SwiftBar menu, choose:

```text
Enable Passwordless Control
```

You will enter the administrator password once. FiberBar installs:

```text
/usr/local/sbin/fiberbar-root
/etc/sudoers.d/fiberbar
```

The sudoers rule only permits the current macOS user to run that root-owned
helper. Do not make the helper user-writable.

## System Proxy Notes

FiberBar starts `sstpc` with `nodefaultroute` and installs explicit split routes
for the configured internal networks. This keeps normal internet traffic on the
primary Wi-Fi/Ethernet service.

On macOS, apps such as Chrome read the effective proxy from
`State:/Network/Global/Proxies` through SystemConfiguration/CFNetwork. That
runtime state is synthesized from the current primary service. If a PPP/VPN
interface becomes primary or triggers a proxy-state recomputation, a proxy that
still exists in a Wi-Fi service's persistent Setup configuration may only appear
as a scoped entry and may disappear from the global proxy seen by browsers.

Recommended approaches:

- For all-traffic proxying, use your proxy client's TUN mode when available.
- For SSTP access to internal networks, keep SSTP as split tunnel and configure
  explicit routes instead of a default route.
- Treat FiberBar's `Manual Repair System Proxy` action as a recovery tool. It
  writes `State:/Network/Global/Proxies`, which can be overwritten again by
  macOS on the next network-state update.

FiberBar never assumes Clash Verge or a fixed proxy port. It discovers the proxy
target from macOS network services, or you can configure one explicitly.
Automatic repair is disabled by default:

```sh
FIBERBAR_AUTO_REPAIR_SYSTEM_PROXY="false"
```

When enabled, automatic repair first checks the effective system proxy state and
only writes `State:/Network/Global/Proxies` if the proxy is missing or
mismatched. It does not rewrite the system proxy while the status is healthy.

For expert troubleshooting, run:

```sh
fiberbar diagnose
```

The diagnostic output includes primary service, effective proxy state, route
selection, PPP status, and redacted process arguments.

## Why Not a Full GUI App?

Existing projects such as iSSTP already provide a full macOS GUI. FiberBar is
intentionally smaller: a transparent SwiftBar controller for people who want a
scriptable SSTP switch with explicit route health.

## License

Suggested license for this wrapper: MIT.

Note that `sstp-client` itself is GPL-2.0-or-later. FiberBar shells out to an
installed `sstpc`; it does not vendor or link its source.
