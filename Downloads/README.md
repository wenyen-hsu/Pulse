# Nokori trial download / Nokori 試用下載

**[English project page](../README.md) · [繁體中文首頁](../README.zh-Hant.md)**

## Download / 下載

**[Download universal DMG / 下載 Universal DMG](Nokori-1.12.6-weather-64e1028-trial-universal.dmg?raw=true)** · [SHA-256](SHA256SUMS)

| Item / 項目 | Details / 說明 |
| --- | --- |
| Build / 版本 | Nokori 1.12.6 weather trial / 天氣寵物試用版 |
| Source / 程式來源 | [`64e1028`](https://github.com/wenyen-hsu/Pulse/commit/64e1028070d9a35a0e5dcdfad3c77e540514cdca) · [PR #8](https://github.com/wenyen-hsu/Pulse/pull/8) |
| Size / 大小 | 17,917,104 bytes, about 18 MB / 約 18 MB |
| Architecture / 架構 | Apple Silicon (`arm64`) + Intel (`x86_64`) |
| System / 系統 | macOS 14+; full Liquid Glass requires macOS 26+ / 完整液態玻璃外觀需 macOS 26 以上 |
| Signing / 簽章 | Ad-hoc signed, **not Apple-notarized** / 臨時簽章，**未經 Apple 公證** |

## 繁體中文

這是已交付的同一份天氣寵物試用包，使用原生桌面測試通過的程式打包，沒有重新編譯。此下載不是正式穩定版，也沒有建立版本標籤或啟用自動更新。下載檔暫放本目錄，讓訪客不需登入 Devin 就能取得。

**此包尚未包含後續的天氣／手選寵物互斥控制。** 本包仍由 PNG 優先顯示並暫停天氣；原始碼新增的「啟用天氣時停用手選與圖片控制、關閉後恢復」需另經原生桌面驗證再製作新版安裝包。

1. 先結束舊的 Nokori／Pulse Pet；**保留原版 Pulse**。
2. 開啟 DMG，把 **Nokori** 拖進「應用程式」，只取代舊 Nokori，不取代 Pulse。
3. 首次若被 macOS 阻擋，僅在信任來源時，到「系統設定 → 隱私權與安全性 → 仍要打開」。
4. 在「設定 → 外觀 → 自動天氣寵物」啟用天氣。預設關閉；使用內建寵物並顯示浮點面板後，可選目前位置並按「允許定位」，或搜尋城市後選取結果。詳見[天氣來源、費用與隱私](../Docs/weather-pet.zh-Hant.md)。

**驗證範圍：** Apple Silicon 原生桌面已驗證城市天氣備援、固定天氣造型、PNG 優先、暫停查詢、圓形／液態互動及原版 Pulse 雙開。DMG 完整性、簽章與受測程式一致性已核對。**首次定位授權彈窗、App 個別允許／拒絕及成功裝置定位仍待使用者在自己的 Mac 測試**；VM 系統定位服務關閉，沒有把這些項目列為通過。

Intel 實機、舊 macOS、窄／多螢幕、首次 Gatekeeper 放行、真實服務商登入／用量及通知送達尚未完整驗證；精確 120／200 ms 重入取消時序與每種天氣的即時轉換也未實測。Universal 架構不等於已在兩種硬體上驗證。

## English

This is the same delivered weather-pet trial, packaged from the exact native-tested app without rebuilding. It is **not a stable release**; no version tag or automatic update was created. The installer is temporarily kept here so visitors can download it without a Devin login.

**This installer predates the exclusive weather/manual-pet controls.** It still gives PNGs priority and pauses weather. The source change that disables manual/image controls while weather is on and restores them when off needs fresh native acceptance and a new installer.

1. Quit the old Nokori/Pulse Pet. **Keep the original Pulse installed.**
2. Open the DMG and drag **Nokori** into Applications, replacing only an older Nokori, never Pulse.
3. If macOS blocks first launch, use System Settings → Privacy & Security → Open Anyway only if you trust the package.
4. Enable Settings → Appearance → Automatic weather pet. It is off by default. With a built-in pet and visible orb, select Current location and press Allow location access, or search for a city and select a result. See [weather source, cost and privacy](../Docs/weather-pet.md).

**Verification:** Native Apple Silicon testing covered live city fallback, fixed weather artwork, PNG priority, paused fetching, circular/liquid interactions and side-by-side operation with original Pulse. Image integrity, signing and identity with the tested bundle were verified. **First-time location permission, app-specific grant/denial and successful device location still require testing on the user's Mac**; the VM's global Location Services was off, so these are not counted as passed.

Intel hardware, older macOS, narrow/multiple displays, first-launch Gatekeeper approval, real provider login/usage and notification delivery are not fully verified. Exact 120/200 ms re-entry cancellation and every live weather transition were not measured. A universal binary does not mean both hardware architectures were tested.

## Verify / 核對下載

Download the DMG and `SHA256SUMS` into the same folder, then run / 將 DMG 與 `SHA256SUMS` 下載至同一資料夾後執行：

```bash
shasum -a 256 -c SHA256SUMS
```

Expected / 預期結果：`Nokori-1.12.6-weather-64e1028-trial-universal.dmg: OK`.

The source retains [Apache 2.0](../LICENSE), [NOTICE](../NOTICE) and [third-party notices](../THIRD_PARTY_NOTICES.md). Open-Meteo's free API has separate **non-commercial-only** terms; this is not an unlimited or commercial weather subscription. / 程式保留原作者致謝與授權；Open-Meteo 免費 API 另有**僅限非商業用途**與流量限制，不因程式採 Apache 2.0 就免除。
