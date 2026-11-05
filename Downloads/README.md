# Nokori Liquid trial / 液態試用版

**[English project page](../README.md) · [繁體中文首頁](../README.zh-Hant.md)**

## Download / 下載

**[Download universal DMG / 下載 Universal DMG](Nokori-1.12.6-liquid-scatter-f5370ee-trial-universal.dmg?raw=true)** · [SHA-256](SHA256SUMS)

| Item / 項目 | Details / 說明 |
| --- | --- |
| Build / 版本 | Nokori 1.12.6 Liquid-scatter trial / 液態散排試用版 |
| Source / 程式來源 | [`f5370ee`](https://github.com/wenyen-hsu/Pulse/commit/f5370eeba337ce03cb5280e7e3688d90a9b5bef1) · [PR #16](https://github.com/wenyen-hsu/Pulse/pull/16) |
| Size / 大小 | 17,945,282 bytes, about 18 MB / 約 18 MB |
| Architecture / 架構 | Apple Silicon (`arm64`) + Intel (`x86_64`) |
| System / 系統 | macOS 14+; full Liquid Glass requires macOS 26+ / 完整液態玻璃外觀需 macOS 26 以上 |
| Signing / 簽章 | Ad-hoc signed, **not Apple-notarized** / 臨時簽章，**未經 Apple 公證** |
| Integrity / 完整性 | [Package verification](Nokori-1.12.6-liquid-scatter-f5370ee-verification.json) · [Full bundle manifest](Nokori-1.12.6-liquid-scatter-f5370ee-bundle-manifest.json) |

## 繁體中文

這是**已揭露限制的液態試用版，不是全模式完整驗收或正式穩定版**。使用同一份原生受測程式打包，沒有在驗證後重新編譯或重新簽章；沒有版本標籤、正式 GitHub Release 或自動更新。訪客不需登入 Devin 即可下載。

**本版包含液態預設與全部帳號散排。** 新設定預設使用液態寵物，保留已儲存的樣式。液態模式不再分頁，中央保留寵物，周圍圖示與額度環隨數量一起縮放。圓形寵物浮點保留每頁八個帳號。也包含點擊天氣更新、每分鐘一次與單次查詢防護，以及拖曳放開後不再意外刷新全部帳號的修正。

**已知限制：77 個帳號時，經典側欄會超出螢幕而無法看見。** 此問題未修正，已由使用者接受列為試用限制，不列為通過。大量帳號請使用液態寵物或圓形寵物浮點。

1. 結束舊 Nokori／Pulse Pet；**保留原版 Pulse**。
2. 開啟 DMG，把 **Nokori** 拖進「應用程式」，只取代舊 Nokori。
3. 首次若被 macOS 阻擋，僅在信任來源時，使用「系統設定 → 隱私權與安全性 → 仍要打開」。
4. 天氣預設關閉。在「設定 → 外觀」啟用自動天氣後，可手選城市或主動允許定位。天氣會暫時取代已存 PNG，關閉後恢復；不刪除圖片。[天氣來源、費用與隱私](../Docs/weather-pet.zh-Hant.md)。

**原生驗證：** 在 Apple Silicon VM 使用真實滑鼠及明確標示的本機正額度 fixtures，驗證 9／17／77 帳號同時散排、最後帳號懸停／獨立點擊、位置穩定與最大 PNG 中央淨空；不是 77 個真實服務商的登入或用量驗證。拖曳測試以帳號計數及匿名天氣連線計數確認沒有意外刷新。圓形 Next 到 10/10，另以九帳號驗證 Previous。真實台北天氣、兩模式點擊更新、冷卻／查詢中防重複、受控逾時後保留小時鐘與成功重試、隱藏暫停、重開後 PNG 還原、樣式保存與無效值回退、原版 Pulse 雙開及設定隔離均有原生證據。測試狀態已還原。

**量測邊界：** 減少動態效果只量測 avatar 區域的 ON／OFF 對照，不代表量測全部動畫。經典側欄九帳號可見、可操作，啟動及約 12 分 39 秒觀察窗沒有天氣連線；不能據此宣稱所有排程路徑均已驗證。

**仍未驗證：** 首次定位授權、個別允許／拒絕與成功 GPS 待使用者自己的 Mac 驗證，VM 全域定位服務維持關閉。按下瞬間仍收合的精確狀態、精確重入延遲、Intel 實機、舊 macOS、窄／多螢幕、首次安全性放行、真實帳號用量／通知及所有真實天氣轉換未完整驗證。

**Devin 用量：** 本版改善「桌面快照未提供適用額度」的說明，不會把缺少欄位解釋成零或用完；沒有為缺少用量的 Mac App 快照新增即時數字。

## English

This is a **Liquid trial with disclosed limitations, not complete acceptance of every mode or a stable release**. It packages the exact native-tested app without rebuilding or re-signing. There is no tag, formal GitHub Release or enabled updater.

New settings default to Liquid pet, while saved choices remain unchanged. All enabled Liquid accounts appear together, with shared visual/hit-target scaling and a clear central pet area. Circular Pet orb retains eight accounts per page. This build also includes weather-click refresh with a one-minute cooldown/single-flight guard, and the drag-release refresh fix.

**Known failure: the legacy Classic rail is not visible with 77 enabled accounts because its window extends beyond the display.** The user accepted this as a trial limitation; it was not fixed or counted as passed. Use Liquid pet or circular Pet orb for large lists.

Quit the older Nokori/Pulse Pet, open the DMG and replace only **Nokori** in Applications; **keep original Pulse**. If blocked on first launch, use **System Settings → Privacy & Security → Open Anyway** only if you trust the download. Weather is off by default. Choose a city or explicitly allow location access in Appearance; saved PNGs return when weather is disabled. [Source, costs and privacy](../Docs/weather-pet.md).

**Native evidence:** Real mouse input on an Apple Silicon VM covered 9/17/77 labelled local positive-quota fixtures, final-slot hover/isolated clicks, stable packing, maximum PNG clearance, and drag counter checks. These are not 77 live provider authentication/usage tests. Circular Next reached 10/10; Previous was separately tested with nine fixtures. Live Taipei weather, centre clicks in both modes, cooldown/in-flight guards, controlled timeout/clock/retry, hidden pause, PNG restoration after relaunch, saved/invalid style handling, genuine Pulse coexistence and settings isolation were exercised. Temporary state was restored.

**Measurement boundaries:** Reduce Motion was measured only in the sampled avatar region. Classic-nine was visible and interactive; no weather CONNECT occurred at startup or during the approximately 12-minute-39-second observation window. This does not establish every scheduling path.

**Not verified:** First-time location permission, app-specific grant/denial and successful GPS remain for the user's Mac; global Location Services was unchanged and off. Exact collapsed-at-mouse-down and re-entry timing, Intel hardware, older macOS, narrow/multiple displays, first-use security approval, real provider usage/notifications and every live weather transition remain unverified or non-exhaustive.

The Devin diagnostic now explains when a desktop snapshot reports no applicable limits; missing fields are not treated as zero/exhausted usage. This does not add real-time usage to snapshots that contain none.

## Package integrity / 安裝包完整性

The preserved, built, installed, staged, read-only mounted and extracted installation-copy bundles matched the full manifest, including file bytes, permissions and symlink targets. Strict/deep code signature checks, both architectures' SDK 26.0 stamps, identity/resources, mounted read-only `--json` startup and `hdiutil verify` passed. / 保存、建置、安裝、暫存、唯讀掛載及解出的安裝副本完整清單一致；包含檔案內容、權限與符號連結目標，並通過簽章、兩架構 SDK、識別／資源及啟動檢查。

Executable SHA-256 / 執行檔雜湊：`102dcf3f3061d0ada007a9d32f7c4723bc649f915ff7992d7b6a55d435c6f706`.

GitHub CI is separate evidence. Earlier merged-source jobs were cancelled before steps because no hosted runner was acquired, not a compilation/test pass. Consult the publication PR and [Actions](https://github.com/wenyen-hsu/Pulse/actions) for fresh results. / GitHub CI 與原生驗證分開記錄；先前未分配到 runner 而取消的作業不算通過。

## Verify / 核對下載

```bash
shasum -a 256 Nokori-1.12.6-liquid-scatter-f5370ee-trial-universal.dmg
```

Expected SHA-256 / 預期雜湊：`a4c1d865116ba58f6eff4fa4d993465b65f120fcaf66d8d6495f031bb034401c` ([SHA256SUMS](SHA256SUMS)).

## Archived trials / 舊試用版

Both files and original checksums remain unchanged. Neither contains Liquid default/scatter, weather-click refresh or the later drag fix. / 兩份原檔及原雜湊保留；均不包含液態預設／散排、點擊天氣更新與後續拖曳修正。

- [`58c8a96` weather-exclusive trial / 天氣互斥版](Nokori-1.12.6-weather-exclusive-58c8a96-trial-universal.dmg?raw=true): weather overrides PNG and restores it when disabled. Its Devin diagnostic predates the newer explanation. / 包含天氣覆蓋 PNG 與關閉還原，Devin 提示仍為舊版。
- [`64e1028` weather trial / 舊天氣版](Nokori-1.12.6-weather-64e1028-trial-universal.dmg?raw=true): original PNG-priority behavior pauses weather. / PNG 優先並暫停天氣。
- [Previous packaging/verification record / 舊版驗證紀錄](https://github.com/wenyen-hsu/Pulse/blob/d843e2db2773a4c3464477775e0b9000324c1dfb/Downloads/README.md).

The source retains [Apache 2.0](../LICENSE), [NOTICE](../NOTICE) and [third-party notices](../THIRD_PARTY_NOTICES.md). Open-Meteo's free API is **non-commercial only**, rate-limited and not Apple Weather/WeatherKit. No WeatherKit quota is used. / 保留原作者致謝與授權；Open-Meteo 免費 API 另有非商業用途及流量限制，不是 Apple 天氣／WeatherKit，也不消耗 WeatherKit 額度。
