# Nokori white-Pop Liquid trial / 白色 Pop 液態試用版

**[English project page](../README.md) · [繁體中文首頁](../README.zh-Hant.md)**

## Download / 下載

**Delivery blocked / 暫停交付。** The browser-downloaded DMG was rejected as damaged despite matching source bytes. Do not install this candidate. A separate ZIP built directly from the frozen app is under test, not yet accepted. / 瀏覽器下載的 DMG 與來源位元組一致，但被系統標為損毀，請勿安裝。直接由凍結程式封裝的 ZIP 正在另行驗證，尚未通過交付驗收。

| Item / 項目 | Details / 說明 |
| --- | --- |
| Build / 版本 | Nokori 1.12.6 white-Pop Liquid trial / 白色 Pop 液態試用版 |
| App source / 程式來源 | [67923c1](https://github.com/wenyen-hsu/Pulse/commit/67923c1dafd7a35e9c50cf64ddae4c7680f2de2d) · [PR #20](https://github.com/wenyen-hsu/Pulse/pull/20); source tree matches merged main 92f1217 |
| Size / 大小 | 17,585,092 bytes, about 18 MB / 約 18 MB |
| Architecture / 架構 | Apple Silicon (arm64) + Intel (x86_64); both SDK 26.0 / 雙架構均寫入 SDK 26.0 |
| System / 系統 | macOS 14+; full Liquid Glass requires macOS 26+ / 完整液態玻璃需 macOS 26 以上 |
| Signing / 簽章 | Ad-hoc signed, **not Apple-notarized** / 臨時簽章，**未經 Apple 公證** |
| Integrity / 完整性 | [Package verification](Nokori-1.12.6-white-pop-67923c1-verification.json) · [Full bundle manifest](Nokori-1.12.6-white-pop-67923c1-bundle-manifest.json) |

## 繁體中文

這是**已揭露限制的試用版，不是全模式完整驗收或正式穩定版**。使用同一份已完成原生驗證的 67923c1 程式，驗證後沒有重新編譯或重新簽章；沒有版本標籤、正式 GitHub Release 或自動更新。

**安裝包已包含白色玻璃 Pop 圖示。** 黃色太陽、深藍輪廓與固定紅弧不隨帳號用量改變，沒有藍色裝飾點；不是即時 Dock 用量。液態預設、全部帳號散排、圓形每頁八帳號、天氣點擊更新及拖曳放開後的刷新防護均保留；已儲存的樣式不變。

**已知限制：77 個帳號時，經典側欄會超出螢幕而無法看見。** 此問題未修正，已接受列為試用限制，不列為通過。大量帳號請用液態寵物或圓形寵物浮點。

天氣預設關閉，啟用後可手選城市或主動允許定位；天氣暫時取代 PNG，關閉後恢復，不刪除圖片。[天氣來源、費用與隱私](../Docs/weather-pet.zh-Hant.md)。Devin 快照缺少適用額度時仍如實說明，不畫成零或用完，也沒有新增快照缺少的即時用量。

## English

This is a **trial with disclosed limitations, not complete acceptance of every mode or a stable release**. It packages the frozen, native-tested 67923c1 app without rebuilding or re-signing. There is no tag, formal GitHub Release or enabled updater.

The package now includes the white-glass Pop icon: yellow sun, navy outlines and a fixed red brand arc, without a blue accent dot. It is not live usage or a dynamic Dock indicator. Liquid defaults, all-account scatter, eight-account Circular pages, weather-click refresh and drag-release protection remain; saved style choices are preserved.

**Known failure: Classic rail extends beyond the display with 77 enabled accounts.** This accepted trial limitation was not fixed or counted as passed. Use Liquid pet or Circular Pet orb for large lists. Weather is opt-in, supports manual city fallback and restores the saved PNG when disabled. [Source, costs and privacy](../Docs/weather-pet.md). Missing Devin limits are not treated as zero/exhausted usage; no real-time figures are invented.

## First launch / 首次開啟

1. Quit older **Nokori / Pulse Pet**; keep original **Pulse**. / 結束舊 Nokori／Pulse Pet，保留原版 Pulse。
2. Drag **Nokori** from the DMG to **Applications**, replacing only old Nokori, then open the installed app. / 把 Nokori 拖進「應用程式」，只取代舊 Nokori，再從「應用程式」開啟。
3. For **“Apple could not verify … is free of malware”**, choose **Done**, **not Move to Trash**. This wording alone is not an explicit malware detection. / 若顯示 Apple「無法驗證」警告，選 **Done（完成）**，不要選 **Move to Trash（移到垃圾桶）**；這段文字本身不代表已偵測到惡意程式。
4. Only if you trust the source, use **System Settings → Privacy & Security → Security → Nokori → Open Anyway** and complete Apple's on-device confirmation. Do not share your password. / 僅在信任來源時，於「系統設定 → 隱私權與安全性 → 安全性」找 Nokori 的「仍要打開」，在 Mac 上完成系統確認，不把密碼提供給他人。
5. If Nokori is absent, first check that it remains in Applications. Move to Trash removes the installed copy; copy it from the DMG again and trigger the warning. If no button appears, stop and record the full warning and Security section. / 若沒有 Nokori，先確認 App 還在「應用程式」；移到垃圾桶後須重新安裝並觸發提示。仍沒有按鈕時，請停止並保留完整警告及安全性區塊畫面。

**Stop for an explicit malware detection or “will damage your computer” warning; do not override it.** Do not disable Gatekeeper/XProtect, remove quarantine or use global overrides. / **若明確指出已偵測到惡意程式或「將會損害電腦」，請停止，不繞過警告。** 不關閉 Gatekeeper／XProtect、不移除隔離標記或使用全域例外。[Apple's official guidance / Apple 官方說明](https://support.apple.com/en-us/102445)。

Private testing does not require App Store publication. Ad-hoc signing does not provide Developer ID/notarization trust for Internet downloads; this trial can still require per-app approval. / 私下試用不需要上架 App Store；臨時簽章不等於 Developer ID／公證，網路下載仍可能需要單一 App 放行。

The user completed Apple's per-app flow for the older f5370ee blue-icon trial with Gatekeeper enabled and quarantine retained. This is **not proof of fresh-download approval for the new bundle**. / 使用者曾以此流程開啟舊 f5370ee 藍色圖示包，當時 Gatekeeper 啟用且隔離標記保留；**不據此把新包首開放行算成通過**。

## Verification and limits / 驗證與限制

**Native-tested app:** Real mouse input on an Apple Silicon VM covered Light/Dark Finder/Dock icons; fixed arc across 16% → 87% → genuine no-limits readings; Dock close/menu Quit/relaunch; 9/17/77 labelled positive-quota fixtures without a Liquid pager and with central pet clearance; last-account hover, isolated click, 60-second hover/drag counter checks and genuine re-entry refresh; Circular Next/Previous; Taipei weather fixture and PNG disable/restore. Fixtures are not live provider evidence. Test preferences/data were restored. / **原生程式驗證：** Apple Silicon VM 真實滑鼠涵蓋明暗圖示、用量及真正無讀值時紅弧固定、退出重開、9／17／77 帳號 fixture 散排、末帳號懸停、獨立點擊、長時間懸停／拖曳不刷新、真正離開重入後刷新、圓形分頁、天氣 fixture 與 PNG 互斥還原。Fixtures 不代表真實服務商資料；測試設定／資料已還原。

**Downloaded DMG acceptance: failed before mount.** The real Chrome download matches SHA-256/size and retains quarantine, but macOS 26.6.2 reports the DMG is damaged. Testing stopped without override; Finder/footer/copy/installed-app/first-launch remain untested. / **下載 DMG 驗收：掛載前失敗。** 實際 Chrome 下載的雜湊／大小一致且保留隔離，但 macOS 26.6.2 顯示映像損毀；未繞過，Finder／底圖／複製／安裝版及首開均未測。

**Weather gap closed on the unchanged local-build app:** Updating/spinner/disabled Refresh were visible; a real repeated click about five seconds into the request did not duplicate it. Completion advanced 9:00→9:15; immediate cooldown repeat stayed at CONNECT count2. PNG controls and the actual saved PNG restored when weather was disabled. / **未改動的本機建置版已補驗天氣：** 更新中／spinner／停用按鈕可見，請求中約五秒再次點擊沒有重複請求；完成後時間 9:00→9:15，冷卻重點仍維持 CONNECT 計數2；關閉天氣後控制項及實際 PNG 還原。此結果不代表下載首開通過。

**Still unverified or non-exhaustive:** first-time location permission, grant/denial and successful GPS; Intel hardware; older macOS; narrow/multiple displays; this bundle's downloaded first-use approval; all real provider usage/notifications and live weather transitions; exact sub-second input timing. / **仍未驗證或未完整驗證：** 首次定位授權、允許／拒絕與成功 GPS、Intel 實機、舊 macOS、窄／多螢幕、新包下載首開放行、所有真實用量／通知與天氣轉換及精確次秒輸入時序。

**Package integrity:** All 281 entries match the frozen native-tested, staged, read-only mounted and extracted installation-copy bundles, including bytes, permissions and symlink targets. Strict/deep signatures, architectures, both SDK 26.0 stamps, identity/resources, disabled updater feed, mounted read-only cache-only JSON startup and hdiutil verification passed. / **封裝完整性：** 凍結程式、暫存、唯讀掛載及解出的副本 281 筆內容／權限／symlink 一致；嚴格簽章、雙架構 SDK、識別／資源、停用更新來源、唯讀快取 JSON 啟動與映像驗證通過。

Build, UTC tests, asset tests and localization do not replace native input evidence. Consult the publication PR and [Actions](https://github.com/wenyen-hsu/Pulse/actions) for actual CI results; queued/cancelled/skipped jobs are not passes. / 建置、UTC 測試、資產與本地化不取代原生輸入證據；CI 以發布 PR 與 Actions 實際結果為準，排隊、取消或略過不算通過。

## Verify / 核對下載

Run / 執行：`shasum -a 256 Nokori-1.12.6-white-pop-67923c1-trial-universal.dmg`

Expected SHA-256 / 預期雜湊：`1789447ca3b752f698e526b6e4aab8fd07039e662efb37f87629559c4a2dd6af` ([SHA256SUMS](SHA256SUMS)).

Executable SHA-256 / 執行檔雜湊：`0ab5ba6e08a5e39df827380e41210ec3a3b22466ade59c66caf51b87c5b21d8b`.

## Archived trials / 舊試用版

Original files, manifests and checksums remain unchanged. / 原檔、清單與雜湊均保留不變。

- [f5370ee blue-icon Liquid scatter trial / 藍色圖示液態散排版](Nokori-1.12.6-liquid-scatter-f5370ee-trial-universal.dmg?raw=true): Liquid default/scatter, weather-click and drag fixes; no white-Pop icon or later Intel source portability fixes. / 包含液態預設／散排、點擊天氣與拖曳修正，不含白色 Pop 圖示與後續 Intel 原始碼相容性修正。[Original verification / 原驗證](Nokori-1.12.6-liquid-scatter-f5370ee-verification.json) · [Original guide / 原說明](https://github.com/wenyen-hsu/Pulse/blob/67923c1dafd7a35e9c50cf64ddae4c7680f2de2d/Downloads/README.md).
- [58c8a96 weather-exclusive trial / 天氣互斥版](Nokori-1.12.6-weather-exclusive-58c8a96-trial-universal.dmg?raw=true): weather overrides PNG and restores it when disabled; predates scatter/click-refresh. / 天氣覆蓋 PNG 與關閉還原，早於散排／點擊更新。
- [64e1028 weather trial / 舊天氣版](Nokori-1.12.6-weather-64e1028-trial-universal.dmg?raw=true): original PNG-priority behaviour. / PNG 優先的舊行為。

[Apache 2.0](../LICENSE), [NOTICE](../NOTICE) and [third-party notices](../THIRD_PARTY_NOTICES.md) are retained. Open-Meteo's free API is **non-commercial only**, rate-limited and not Apple Weather/WeatherKit. No WeatherKit quota is used. / 保留原作者致謝與授權；Open-Meteo 免費 API 另有非商業用途及流量限制，不是 Apple 天氣／WeatherKit，也不消耗 WeatherKit 額度。
