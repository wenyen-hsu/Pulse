# Pulse Pet

**[English](README.md) · 繁體中文**<br>
[简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Русский](README.ru.md)

原生 macOS AI 用量監視器：中央小太陽寵物，可切換圓形或液態玻璃外觀。

> 本專案是 [qunqin24 開發的 Pulse](https://github.com/qunqin24/Pulse) 的獨立客製版。**目前應用程式名稱仍為 Pulse Pet**，新名稱與 logo 尚在確認。本儲存庫不是上游正式版本，也不代表原作者背書。

## 這個版本改了什麼？

| 面板樣式 | 行為 |
| --- | --- |
| 寵物浮點 | 保留原有圓形，寵物始終位於圓心。 |
| 液態寵物 | 不規則、略攤開的輪廓；拖曳時形成滯後尾端，放手後回聚。 |
| 傳統側欄 | 保留原有的螢幕邊緣面板。 |

- 滑鼠靠近展開帳號圓環，停在圓環上顯示原有詳細卡片，離開面板與卡片後收合。
- 預設為持續動作的小太陽；也可選貓、狐狸、兔子，或匯入透明 PNG 並調整大小。
- 保留原有服務商用量、帳號管理、歷史、選單列、通知與整合功能。[完整功能說明](Docs/features.md) · [支援服務](Docs/supported-services.md)。
- 保留 75%、80%、90%、95% 警告門檻，另可自行輸入 **1～100%**。
- 液滴動作是表面張力與黏滯感的視覺近似，**不是完整流體模擬**。「減少動態效果」會停用拖曳拉伸與回彈。

## 安裝，不取代原版 Pulse

請使用維護者提供，或[本客製版 Releases](https://github.com/wenyen-hsu/Pulse/releases) 列出的 **Pulse Pet** 試用包。若尚無客製版安裝包，請依下方原始碼步驟建置。上游 Pulse 的下載包不含本版客製功能。

1. 開啟客製版 DMG，將 **Pulse Pet.app** 拖進「應用程式」。
2. 保留原本的 **Pulse.app**。兩者設定、應用程式資料、登入項目與 URL scheme 分開，不遷移原版設定。
3. 開啟 Pulse Pet，選擇要監控的服務。程式常駐選單列；也可右鍵點按浮動面板開啟設定。
4. 試用包使用臨時簽章，**未經 Apple 公證**。若受阻擋，僅在信任安裝包時，使用「系統設定 → 隱私權與安全性 → 仍要打開」。

**系統需求：** macOS 14 以上，完整 Liquid Glass 外觀需要 macOS 26 以上。Universal 安裝包包含 Apple Silicon 與 Intel；本客製面板尚未在 Intel 硬體及舊版 macOS 實測。已停用上游自動更新。

> 兩個程式可能使用相同的服務商帳號、CLI 登入或系統鑰匙圈。獨立儲存不代表額外獲得一份服務額度。Claude Code 的共用 status line 整合請**只在其中一個程式啟用**。

## 切換外觀與語言

- **設定 → 外觀 → 面板樣式：** 寵物浮點／液態寵物／傳統側欄。
- **設定 → 一般 → 介面語言：** 英文、繁體中文、簡體中文、日文、韓文、俄文，或跟隨系統。
- **設定 → 通知：** 選擇預設門檻或輸入自訂百分比、套用，並允許 macOS 通知。警告依實際讀取到的用量觸發，不是連續即時監控。

頁首連結用來切換 GitHub 說明文件的語言；應用程式語言需在設定中另外選擇。

## 從原始碼建置與檢查

需要完整 Xcode、**macOS 26 或更新 SDK**、Swift tools 6.0 以上，以及供腳本使用的 Python 3。不可刪除 SwiftUI 預覽來通過編譯，也不可僅使用 Command Line Tools。

```bash
git clone https://github.com/wenyen-hsu/Pulse.git PulsePet
cd PulsePet
swift build
TZ=UTC swift test
./Scripts/check-localization.sh
./Scripts/bundle.sh --zip
./Scripts/dmg.sh
```

產出：`build.noindex/Pulse Pet.app`、`PulsePet-<version>.zip`、`PulsePet-<version>.dmg`。本機打包不會建立公開 Release。[工具鏈說明](Docs/build-from-source.md) · [打包及發版界線](Docs/releasing.md)。

## 隱私與參與方式

沒有 Pulse 後端或 Pulse 帳號；啟用服務後，程式才會連線讀取該服務的用量，憑證與本機用量紀錄留在你的 Mac。啟用前可查閱[服務商存取方式](Docs/providers/README.md)。請勿公開 Token、Cookie、鑰匙圈資料或未遮蔽的紀錄。

客製版問題請回報至[本儲存庫 Issues](https://github.com/wenyen-hsu/Pulse/issues)，不要要求上游作者支援。請附 macOS 版本、處理器架構、面板樣式及重現步驟，並移除敏感資訊。[貢獻指南](CONTRIBUTING.md) · [安全回報](SECURITY.md) · [文件索引](Docs/README.md)。

## 授權與致謝

感謝 **qunqin24 與 Pulse 貢獻者**建立原始專案。本獨立版本保留 [Apache 2.0 授權](LICENSE)、[NOTICE](NOTICE) 與[第三方聲明](THIRD_PARTY_NOTICES.md)，安裝畫面及「關於」也會顯示致謝。

Apache 2.0 允許在遵守條款下修改與再散布，包括保留必要聲明及授權、標示修改，並遵守第三方素材條款；不授予商標權，也不表示原作者背書。新名稱與 logo 仍需另外確認使用風險。

**[English](README.md)** · [繁體中文](README.zh-Hant.md)
