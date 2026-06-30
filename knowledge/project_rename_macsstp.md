# 项目命名决策：FiberBar 更名为 MacSSTP

日期：2026-06-30

## 背景

项目早期名称 `FiberBar` 来自本机 Fiber SSTP 使用场景和 SwiftBar 菜单栏形态，但它更像内部代号：

- 无法直接表达核心服务内容。
- 开源用户看到名称时不容易理解这是 macOS SSTP 控制器。
- 后续如果加入代理健康检测、路由修复、诊断导出等能力，`Bar` 会过度强调菜单栏 UI，而不是 SSTP 连接管理能力。

## 决策

项目显示名称改为 `MacSSTP`。

- 产品名：`MacSSTP`
- 命令名：`macsstp`
- 配置目录：`~/.config/macsstp/config`
- root helper：`/usr/local/sbin/macsstp-root`
- sudoers 文件：`/etc/sudoers.d/macsstp`
- SwiftBar 插件：`macsstp.5s.sh`
- LaunchAgent：`com.macsstp.swiftbar-autostart`

## 兼容策略

为避免老用户升级后立即断裂，保留一层 `fiberbar` 兼容入口：

- `bin/fiberbar` 包装到 `bin/macsstp`。
- 安装器会同时安装 `~/bin/fiberbar` 兼容命令。
- `macsstp` 会在没有新配置时读取旧 `~/.config/fiberbar/config`。
- 旧 `FIBERBAR_*` 配置变量会映射到新的 `MACSSTP_*` 运行变量。
- 旧 Keychain service `FiberBar SSTP VPN` 会作为密码读取 fallback。
- 已安装的旧 `fiberbar.5s.sh` SwiftBar 插件会被改名为 `.disabled`，避免菜单栏出现两个入口。

## 后续迭代

后续发布说明需要明确：

1. 新用户使用 `macsstp`。
2. 老用户可以继续短期使用 `fiberbar` 命令，但 README 不再把它作为主入口。
3. 一次安装新版本后，建议运行 `macsstp configure`，把配置写入新路径。
4. 如果已启用免密码 helper，安装器会尝试升级到 `macsstp-root`。
