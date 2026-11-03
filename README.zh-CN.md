# Pulse Pet

**[English](README.md) · [繁體中文](README.zh-Hant.md)**<br>
[简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Русский](README.ru.md)

原生 macOS AI 用量监视器：中央小太阳宠物，可切换圆形或液态玻璃外观。

> 本项目是 [qunqin24 开发的 Pulse](https://github.com/qunqin24/Pulse) 的独立定制版，不代表原作者背书。当前名称仍为 **Pulse Pet**；新名称与 logo 尚待确认。

## 定制功能

- **宠物浮点：** 保留圆形；宠物在收起和展开时都居中。
- **液态宠物：** 轮廓不规则、略微铺开；拖动产生滞后尾部，松手后回弹。只是表面张力与黏滞感的视觉近似，不是流体模拟。“减少动态效果”会禁用拉伸和回弹。
- **传统侧栏：** 保留原有的屏幕边缘面板。
- 指针靠近时展开账号圆环，停在圆环上显示原有详情卡片，离开面板和卡片后收起。
- 默认是持续活动的小太阳，也可选择猫、狐狸、兔子，或导入透明 PNG 并调整大小。
- 保留服务商用量、账号、历史、菜单栏、通知和集成。[完整功能](Docs/features.md) · [支持服务](Docs/supported-services.md)。
- 保留 75%、80%、90%、95% 提醒选项，支持自行输入 **1～100%**。

## 安装与设置

请使用维护者提供或[本仓库 Releases](https://github.com/wenyen-hsu/Pulse/releases) 列出的 **Pulse Pet** 试用包。若无定制安装包，请从源码构建；上游 Pulse 安装包不包含本版功能。

1. 打开 DMG，把 **Pulse Pet.app** 拖到“应用程序”，不要替换原版 **Pulse.app**。
2. 设置、应用数据、登录项和 URL scheme 独立，不迁移原版设置；上游自动更新已关闭。
3. 启动后选择要监控的服务。应用常驻菜单栏，也可右键点击面板打开设置。
4. 试用包仅临时签名，**未经 Apple 公证**。只对可信安装包使用“系统设置 → 隐私与安全性 → 仍要打开”。

需要 macOS 14+，完整 Liquid Glass 外观需要 macOS 26+。Universal 包包含 Apple Silicon 和 Intel；定制面板尚未在 Intel 硬件及旧版系统实测。

两款应用仍可能共用服务商账号、CLI 登录和系统钥匙串；独立数据不等于独立额度。Claude Code 的共用 status line 集成请只在其中一款启用。

- **设置 → 外观 → 面板样式：** 宠物浮点／液态宠物／传统侧栏。
- **设置 → 通用 → 界面语言：** 英语、繁体中文、简体中文、日语、韩语、俄语或跟随系统。页首链接只切换 README。
- **设置 → 通知：** 选择门槛或输入自定义百分比、应用并允许系统通知。提醒取决于实际读到的用量，不是连续实时监控。

## 从源码构建

需要完整 Xcode、macOS 26 或更新 SDK、Swift tools 6.0+ 和 Python 3；不可删除预览或仅使用 Command Line Tools。

```bash
git clone https://github.com/wenyen-hsu/Pulse.git PulsePet
cd PulsePet
swift build
TZ=UTC swift test
./Scripts/check-localization.sh
./Scripts/bundle.sh --zip
./Scripts/dmg.sh
```

产物为 `build.noindex/Pulse Pet.app`、`PulsePet-<version>.zip` 和 `PulsePet-<version>.dmg`。本地打包不创建公开 Release。[工具链](Docs/build-from-source.md) · [打包说明](Docs/releasing.md)。

## 隐私、参与与授权

没有 Pulse 后端或 Pulse 账号；只连接已启用的服务商读取用量，凭证和本地记录留在 Mac。请先了解[服务商访问方式](Docs/providers/README.md)。不要公开 Token、Cookie、钥匙串或未遮蔽的日志。

定制版问题请到[本仓库 Issues](https://github.com/wenyen-hsu/Pulse/issues) 提交系统版本、架构、面板样式和重现步骤，不要要求上游作者支持。[贡献指南](CONTRIBUTING.md) · [安全回报](SECURITY.md) · [文档目录](Docs/README.md)。

感谢 **qunqin24 和 Pulse 贡献者**。保留 [Apache 2.0](LICENSE)、[NOTICE](NOTICE) 和[第三方声明](THIRD_PARTY_NOTICES.md)，安装界面与“关于”也保留致谢。Apache 2.0 允许按条款修改与再分发，但须保留必要授权和声明、标明修改并遵守第三方条款；不授予商标权或原作者背书。新名称和 logo 须另行确认。

**[English](README.md) · [繁體中文](README.zh-Hant.md)**<br>
[简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Русский](README.ru.md)
