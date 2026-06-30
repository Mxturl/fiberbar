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

## Why Not a Full GUI App?

Existing projects such as iSSTP already provide a full macOS GUI. FiberBar is
intentionally smaller: a transparent SwiftBar controller for people who want a
scriptable SSTP switch with explicit route health.

## License

Suggested license for this wrapper: MIT.

Note that `sstp-client` itself is GPL-2.0-or-later. FiberBar shells out to an
installed `sstpc`; it does not vendor or link its source.
