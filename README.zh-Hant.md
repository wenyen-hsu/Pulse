<p align="center"><img src="AppIcon/nokori-icon.svg" width="144" height="144" alt="Nokori 白色玻璃 Pop 太陽與固定紅弧標誌" /></p>

# Nokori

**[English](README.md) · 繁體中文**<br>
[简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Русский](README.ru.md)

原生 macOS AI 用量監視器：中央小太陽寵物，可切換圓形或液態玻璃外觀。

> **公證版下載：** Developer ID 簽章並經 Apple 公證的 DMG，任何 Mac 下載後可直接開啟，不需要「仍要打開」。已在 macOS 27.2 上建置並驗證。[下載與狀態](Downloads/README.md)。

下方試用版已採用白色玻璃 Pop 圖示，**紅弧固定為品牌造型，不代表即時用量**。[圖示與產生方式](Docs/branding.md)。

> 本專案是 [qunqin24 開發的 Pulse](https://github.com/qunqin24/Pulse) 的獨立客製版。本獨立版本正式採用 **Nokori（原名 Pulse Pet）**。本儲存庫不是上游正式版本，也不代表原作者背書。

**[下載公證版 DMG — Apple Silicon＋Intel](Downloads/Nokori-1.12.6-notarized-32ecd7f.dmg?raw=true)** · [雜湊與驗證範圍](Downloads/README.md)

> **這是試用版，不是正式穩定版。** 使用臨時簽章，未經 Apple 公證。保留原版 Pulse，只取代舊 Nokori；首次定位授權與成功裝置定位仍待在你的 Mac 驗證。

## 這個版本改了什麼？

未設定過面板樣式時，預設使用**液態寵物**；已儲存的樣式選擇不變。`67923c1` 試用版已包含液態預設、全部帳號散排、點擊天氣更新，以及拖曳放開後不再意外刷新全部帳號的修正。

**已知限制：** 啟用 77 個帳號時，經典側欄會超出螢幕，可能無法看見。大量帳號請使用液態寵物或圓形寵物浮點。[試用版驗證範圍與限制](Downloads/README.md)。

液態寵物會將所有已啟用帳號的圖示與額度環散排在水滴內，不再分頁。數量多時會縮小圖示，懸停可看完整名稱與用量卡片，寵物仍置中。圓形寵物浮點保留原分頁。

| 面板樣式 | 行為 |
| --- | --- |
| 寵物浮點 | 保留原有圓形，寵物始終位於圓心。 |
| 液態寵物 | 不規則、略攤開的輪廓；拖曳時形成滯後尾端，放手後回聚。 |
| 傳統側欄 | 保留原有的螢幕邊緣面板。 |

- 滑鼠靠近展開帳號圓環，停在圓環上顯示原有詳細卡片，離開面板與卡片後收合。
- 預設為持續動作的小太陽；也可選貓、狐狸、兔子，或匯入透明 PNG 並調整大小。
- 可選[天氣寵物](Docs/weather-pet.zh-Hant.md)：雲朵、雨、雷雨、雪、霧與月亮。可離線固定選擇造型，或啟用當地天氣、明確授權定位；拒絕或無法定位時可手選城市。Open-Meteo 免費服務僅限非商業用途。
- 保留原有服務商用量、帳號管理、歷史、選單列、通知與整合功能。[完整功能說明](Docs/features.md) · [支援服務](Docs/supported-services.md)。
- 保留 75%、80%、90%、95% 警告門檻，另可自行輸入 **1～100%**。
- 液滴動作是表面張力與黏滯感的視覺近似，**不是完整流體模擬**。「減少動態效果」會停用拖曳拉伸與回彈。

## 安裝，不取代原版 Pulse

請使用上方的 **[Nokori 公證版 DMG](Downloads/Nokori-1.12.6-notarized-32ecd7f.dmg?raw=true)**，以同一份通過原生桌面測試的程式來源搭配 Developer ID 簽章與 Apple 公證建置。[下載說明與 SHA-256](Downloads/README.md)。檔案直接放在 repo，並非已建立標籤的 GitHub Release。上游 Pulse 的下載包不含本版客製功能。

1. 開啟客製版 DMG，將 **Nokori.app** 拖進「應用程式」。
2. 保留原本的 **Pulse.app**。兩者設定、應用程式資料、登入項目與 URL scheme 分開，不遷移原版設定。
3. 開啟 Nokori，選擇要監控的服務。程式常駐選單列；也可右鍵點按浮動面板開啟設定。
4. 從「應用程式」開啟 **Nokori**。公證版為 Developer ID 簽章並經 Apple 公證，可直接開啟，不需要「仍要打開」。若明確表示已偵測到惡意程式或「將會損害電腦」，請停止；不要關閉 Gatekeeper 或移除隔離標記。舊的臨時簽章封存版仍需「仍要打開」步驟。[首次開啟說明](Downloads/README.md)。

**系統需求：** macOS 14 以上，完整 Liquid Glass 外觀需要 macOS 26 以上。Universal 安裝包包含 Apple Silicon 與 Intel；本客製面板尚未在 Intel 硬體及舊版 macOS 實測。已停用上游自動更新。

> 兩個程式可能使用相同的服務商帳號、CLI 登入或系統鑰匙圈。獨立儲存不代表額外獲得一份服務額度。Claude Code 的共用 status line 整合請**只在其中一個程式啟用**。

## 切換外觀與語言

- **設定 → 外觀 → 面板樣式：** 寵物浮點／液態寵物／傳統側欄。
- **設定 → 一般 → 介面語言：** 英文、繁體中文、簡體中文、日文、韓文、俄文，或跟隨系統。
- **設定 → 通知：** 選擇預設門檻或輸入自訂百分比、套用，並允許 macOS 通知。警告依實際讀取到的用量觸發，不是連續即時監控。

頁首連結用來切換 GitHub 說明文件的語言；應用程式語言需在設定中另外選擇。

> **從 Pulse Pet 升級：** 先結束舊版、安裝 Nokori，再移除舊 Pulse Pet 的程式本體，不要刪除資料。原有獨立設定與資料識別保留；不要同時執行新舊名稱的同一程式。原版 Pulse 仍可與 Nokori 雙開。[品牌與相容性](Docs/branding.md)。

## 天氣來源與費用

自動天氣使用 **Open-Meteo，不是讀取 Apple「天氣」App，也沒有使用 WeatherKit**。功能預設關閉，啟用且面板可見時約每 30 分鐘更新，不是即時同步。免費 API 不需金鑰，但**僅限非商業用途**，有流量限制且不保證服務可用性。定位授權不等於取得「天氣」App 的資料存取權；目前不會消耗任何 WeatherKit 開發者共用額度。[天氣、費用與隱私說明](Docs/weather-pet.zh-Hant.md)。

## 從原始碼建置與檢查

需要完整 Xcode、**macOS 26 或更新 SDK**、Swift tools 6.0 以上，以及供腳本使用的 Python 3。不可刪除 SwiftUI 預覽來通過編譯，也不可僅使用 Command Line Tools。

```bash
git clone https://github.com/wenyen-hsu/Pulse.git Nokori
cd Nokori
swift build
TZ=UTC swift test
./Scripts/check-localization.sh
./Scripts/bundle.sh --zip
./Scripts/dmg.sh
```

產出：`build.noindex/Nokori.app`、`Nokori-<version>.zip`、`Nokori-<version>.dmg`。本機打包不會建立公開 Release。[工具鏈說明](Docs/build-from-source.md) · [打包及發版界線](Docs/releasing.md)。

## 隱私與參與方式

沒有 Pulse 後端或 Pulse 帳號；啟用服務後，程式才會連線讀取該服務的用量，憑證與本機用量紀錄留在你的 Mac。啟用前可查閱[服務商存取方式](Docs/providers/README.md)。請勿公開 Token、Cookie、鑰匙圈資料或未遮蔽的紀錄。

客製版問題請回報至[本儲存庫 Issues](https://github.com/wenyen-hsu/Pulse/issues)，不要要求上游作者支援。請附 macOS 版本、處理器架構、面板樣式及重現步驟，並移除敏感資訊。[貢獻指南](CONTRIBUTING.md) · [安全回報](SECURITY.md) · [文件索引](Docs/README.md)。

## 授權與致謝

感謝 **qunqin24 與 Pulse 貢獻者**建立原始專案。本獨立版本保留 [Apache 2.0 授權](LICENSE)、[NOTICE](NOTICE) 與[第三方聲明](THIRD_PARTY_NOTICES.md)，安裝畫面及「關於」也會顯示致謝。

Apache 2.0 允許在遵守條款下修改與再散布，包括保留必要聲明及授權、標示修改，並遵守第三方素材條款；不授予商標權，也不表示原作者背書。名稱與 logo 的選用不代表已通過商標查核。

**[English](README.md)** · [繁體中文](README.zh-Hant.md)
