# Nokori trial download / Nokori 試用下載

**[English project page](../README.md) · [繁體中文首頁](../README.zh-Hant.md)**

## Download / 下載

**[Download universal DMG / 下載 Universal DMG](Nokori-1.12.6-weather-exclusive-58c8a96-trial-universal.dmg?raw=true)** · [SHA-256](SHA256SUMS)

| Item / 項目 | Details / 說明 |
| --- | --- |
| Build / 版本 | Nokori 1.12.6 weather-exclusive trial / 天氣互斥試用版 |
| Source / 程式來源 | [`58c8a96`](https://github.com/wenyen-hsu/Pulse/commit/58c8a9619017519b11a758f9cf6b5d5334d676e5) · [PR #9](https://github.com/wenyen-hsu/Pulse/pull/9) |
| Size / 大小 | 17,918,290 bytes, about 18 MB / 約 18 MB |
| Architecture / 架構 | Apple Silicon (`arm64`) + Intel (`x86_64`) |
| System / 系統 | macOS 14+; full Liquid Glass requires macOS 26+ / 完整液態玻璃外觀需 macOS 26 以上 |
| Signing / 簽章 | Ad-hoc signed, **not Apple-notarized** / 臨時簽章，**未經 Apple 公證** |

## 繁體中文

此包使用通過新一輪原生桌面測試的程式打包，沒有在驗證後重新編譯。這不是正式穩定版，也沒有建立版本標籤或啟用自動更新。下載檔放在本目錄，訪客不需登入 Devin 就能取得。

**此包已包含天氣與手選寵物互斥。** 啟用自動天氣時，固定寵物選單、匯入 PNG 與使用內建寵物按鈕會停用；天氣暫時取代已儲存的 PNG，不刪除原設定。關閉天氣後恢復原寵物或圖片，大小仍可調整。

1. 先結束舊的 Nokori／Pulse Pet；**保留原版 Pulse**。
2. 開啟 DMG，把 **Nokori** 拖進「應用程式」，只取代舊 Nokori，不取代 Pulse。
3. 首次若被 macOS 阻擋，僅在信任來源時，到「系統設定 → 隱私權與安全性 → 仍要打開」。
4. 在「設定 → 外觀 → 自動天氣寵物」啟用天氣。預設關閉；顯示浮點面板後，可選目前位置並按「允許定位」，或搜尋城市後選取結果。詳見[天氣來源、費用與隱私](../Docs/weather-pet.zh-Hant.md)。

**原生驗證範圍：** Apple Silicon 上以真實滑鼠操作驗證手選／圖片控制停用、台北城市天氣資料取代已存 PNG、重開後保留圖片與大小、關閉天氣後還原、隱藏面板暫停與恢復、圓形／液態互動、拖曳回彈及原版 Pulse 雙開。DMG 完整性、簽章及包內完整程式與受測版本一致性已核對。

**仍未驗證：** 首次定位授權彈窗、App 個別允許／拒絕及成功裝置定位待使用者在自己的 Mac 測試；VM 系統定位服務維持關閉。經典側欄可操作，切回浮點會恢復天氣，但側欄內部暫停狀態只有自動測試覆蓋，未由原生介面直接證實。Intel 實機、舊 macOS、窄／多螢幕、首次安全性放行、精確重入延遲、真實服務商用量／通知及所有真實天氣轉換仍未驗證，不能把城市備援測試當成這些項目已通過。

這次不包含 Devin Mac App 用量讀取相容性修正，該回報仍待診斷。

## English

This trial is packaged from the app accepted in a fresh native desktop run, without rebuilding afterward. It is not a stable release, has no version tag, and does not enable automatic updates. The file is hosted here so visitors do not need a Devin account to download it.

**This installer includes exclusive weather/manual-pet controls.** Automatic weather disables the fixed-pet picker, Import PNG and Use built-in pet. Weather temporarily replaces a saved PNG without deleting it; switching weather off restores the saved pet or image. Size remains adjustable.

1. Quit the older Nokori/Pulse Pet; **keep original Pulse**.
2. Open the DMG and drag **Nokori** into Applications. Replace only the older Nokori, not Pulse.
3. If macOS blocks first launch, use **System Settings → Privacy & Security → Open Anyway** only if you trust this download.
4. Enable **Settings → Appearance → Automatic weather pet**. It is off by default. With the orb visible, choose current location and press **Allow location access**, or search for a city and select its result. See [weather source, costs and privacy](../Docs/weather-pet.md).

**Native verification:** On Apple Silicon, real pointer input covered disabled manual/image controls, live Taipei city weather overriding a saved PNG, image/size persistence across relaunch, restoration with weather off, hidden-panel pause/resume, circular/liquid interaction, drag settling and coexistence with original Pulse. Image integrity, signing and the full packaged bundle's identity with the tested app were verified.

**Not verified:** First-time OS permission, app-specific grant/denial and successful device location still require the user's Mac; global Location Services was unchanged and off in the VM. Classic rail works and weather resumes on returning to an orb, but its internal paused state is covered by automated tests, not direct native UI evidence. Intel hardware, older macOS, narrow/multiple displays, first-use security approval, exact re-entry timing, real provider usage/notifications and every possible live weather transition remain untested. City fallback does not prove those cases.

This build does not fix the reported Devin Mac App usage compatibility issue; that report still needs diagnosis.

## Previous trial / 舊試用版

[`64e1028` weather trial / 舊天氣試用版](Nokori-1.12.6-weather-64e1028-trial-universal.dmg?raw=true) remains available with its original checksum. It predates the exclusive controls: PNGs take priority and pause weather. / 保留原檔及原雜湊；此舊包尚無互斥控制，PNG 會優先顯示並暫停天氣。

## Verify / 核對下載

Run this beside the downloaded DMG and compare with its row in [SHA256SUMS](SHA256SUMS). / 在下載檔所在資料夾執行，並與雜湊表中同檔名一行比較：

```bash
shasum -a 256 Nokori-1.12.6-weather-exclusive-58c8a96-trial-universal.dmg
```

Expected SHA-256 / 預期雜湊：`7e96e61f27e2c021ded1c5328f96da7d07d785aa5d54bd1bad344f02dab9add1`.

The source retains [Apache 2.0](../LICENSE), [NOTICE](../NOTICE) and [third-party notices](../THIRD_PARTY_NOTICES.md). Open-Meteo's free API has separate **non-commercial-only** terms; this is not an unlimited or commercial weather subscription. / 程式保留原作者致謝與授權；Open-Meteo 免費 API 另有**僅限非商業用途**與流量限制，不因程式採 Apache 2.0 就免除。
