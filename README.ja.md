<p align="center"><img src="AppIcon/nokori-icon.svg" width="144" height="144" alt="Nokori 白いガラスとポップな太陽、固定の赤い弧のロゴ" /></p>

# Nokori

**[English](README.md) · [繁體中文](README.zh-Hant.md)**<br>
[简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Русский](README.ru.md)

中央の太陽ペットと、円形・液体ガラスの表示を備えた macOS 用 AI 使用量モニター。

下記の試用版には、白いガラスのポップなアイコンが含まれます。**赤い弧は固定のブランド意匠で、実際の使用量を示しません**。[アイコンと生成方法](Docs/branding.md)。

> [qunqin24 氏の Pulse](https://github.com/qunqin24/Pulse) を基にした独立版です。原作者による公認を意味しません。本独立版の名前は **Nokori（旧 Pulse Pet）** に決定しました。

## この版の機能

新規設定では **Liquid pet** が標準です。保存済みの表示スタイルは変更しません。試用版 `67923c1` には、この初期設定、全アカウントの分散配置、天気のクリック更新、ドラッグ終了時に全アカウントを意図せず更新する問題の修正が含まれます。

**既知の制限：** 77 アカウントを有効にすると、従来のサイドバーが画面外にはみ出し、見えなくなる場合があります。アカウントが多い場合は Liquid pet または円形の Pet orb を使用してください。[検証範囲と制限](Downloads/README.md)。

Liquid pet は有効な全アカウントのアイコンと使用量リングをしずくの中に配置し、ページを分けません。数が多いとアイコンが小さくなり、ポインタを合わせると名前と使用量の詳細を表示します。ペットは中央のままです。円形の Pet orb は従来のページ切り替えを維持します。

- **Pet orb：** 従来の円形を維持し、開閉時ともペットを中央に表示します。
- **Liquid pet：** 少し広がった不規則な輪郭。ドラッグ中は後ろに伸び、離すと収束します。表面張力と粘性の視覚的な近似で、流体シミュレーションではありません。「視差効果を減らす」設定では伸びと反動を停止します。
- **Classic rail：** 従来の画面端パネルも選べます。
- ポインタを近づけるとアカウントのリングが展開し、リングに合わせると詳細カードを表示します。パネルとカードを離れると収納します。
- 動く Little sun が標準です。猫・狐・兎や透過 PNG、サイズ変更にも対応します。
- [天気連動ペット](Docs/weather-pet.md)として雲・雨・雷・雪・霧・月も選べます。固定の絵柄はオフラインで使用できます。現地の天気と連動させる場合は、位置情報を明示的に許可するか都市を選びます。位置情報を拒否しても都市検索を利用できます。Open-Meteo の無料サービスは非商用のみです。
- 使用量、アカウント、履歴、メニューバー、通知、連携を維持します。[機能一覧](Docs/features.md) · [対応サービス](Docs/supported-services.md)。
- 警告の 75%、80%、90%、95% に加え、**1〜100%** を入力できます。

## インストールと設定

**[試用版 DMG をダウンロード — Apple Silicon＋Intel](Downloads/Nokori-1.12.6-white-pop-67923c1-trial-universal.dmg?raw=true)** · [SHA-256 と検証範囲](Downloads/README.md)。このリポジトリから直接配布する試用版で、安定版やタグ付き GitHub Release ではありません。初回の位置情報許可と実際の位置取得は未検証です。元の Pulse の配布物には本版の変更は含まれません。

1. DMG を開き、**Nokori.app** をアプリケーションへ移動します。元の **Pulse.app** は置き換えません。
2. 設定、アプリデータ、ログイン項目、URL スキームは独立し、元の設定は移行しません。上流の自動更新は無効です。
3. 起動後に監視するサービスを選びます。メニューバーに常駐し、パネルの右クリックでも設定を開けます。
4. 試用版はアドホック署名のみで **Apple 未公証**です。Apple が検証できない旨の警告では、ゴミ箱に入れず **Done（完了）**を選びます。配布元を信頼できる場合に限り、システム設定 → プライバシーとセキュリティ → このまま開くを使用してください。マルウェアの検出やコンピュータを損傷する旨が明示された場合は中止してください。[初回起動の案内](Downloads/README.md)。

macOS 14 以降、完全な Liquid Glass 表示には macOS 26 以降が必要です。Universal パッケージは Apple Silicon と Intel 向けですが、本版のパネルは Intel 実機・旧 macOS では未検証です。

両アプリは同じサービスのアカウント、CLI ログイン、キーチェーンを使う場合があります。データを分けても利用枠は増えません。Claude Code の共有 status line 連携は片方だけで有効にしてください。

- **設定 → 外観 → パネルスタイル：** Pet orb / Liquid pet / Classic rail。
- **設定 → 一般 → インターフェイス言語：** 英語、繁体字・簡体字中国語、日本語、韓国語、ロシア語、またはシステム設定に従う。冒頭のリンクは README のみを切り替えます。
- **設定 → 通知：** しきい値か任意の割合を選んで適用し、macOS の通知を許可します。取得した値に基づく通知で、連続したリアルタイム監視ではありません。

> **Pulse Pet からの更新：** 旧版を終了し、Nokori をインストールしてから古い Pulse Pet のアプリ本体だけを削除してください。設定とデータは削除せず、従来の独立した識別情報を維持します。新旧名の同じアプリを同時に起動しないでください。原版 Pulse と Nokori は同時に使えます。[ブランドと互換性](Docs/branding.md)。

## 天気データの提供元と費用

自動天気は **Open-Meteo** を利用しており、**Apple の「天気」アプリを読み取ったり、WeatherKit を使ったりはしません**。初期状態では無効です。有効にしてフローティングパネルを表示すると、約 30 分ごとに更新します。リアルタイム同期ではありません。無料 API にキーは不要ですが、**非商用に限られ**、リクエスト数に制限があり、サービスの可用性は保証されません。位置情報の許可は現在地の取得に対するもので、「天気」アプリへのアクセス権ではありません。現在、WeatherKit の開発者共通枠は消費しません。[提供元・費用・プライバシーの詳細（英語）](Docs/weather-pet.md#data-source-and-cost)。

## ソースからビルド

完全な Xcode、macOS 26 以降の SDK、Swift tools 6.0 以降、Python 3 が必要です。プレビューを削除したり、Command Line Tools だけでビルドしたりしないでください。

```bash
git clone https://github.com/wenyen-hsu/Pulse.git Nokori
cd Nokori
swift build
TZ=UTC swift test
./Scripts/check-localization.sh
./Scripts/bundle.sh --zip
./Scripts/dmg.sh
```

出力は `build.noindex/Nokori.app`、`Nokori-<version>.zip`、`Nokori-<version>.dmg` です。ローカルでのパッケージ作成は公開リリースを作成しません。[ツールチェーン](Docs/build-from-source.md) · [配布について](Docs/releasing.md)。

## プライバシー・参加・ライセンス

Pulse のサーバーやアカウントはありません。有効にしたサービスへ使用量を問い合わせ、認証情報とローカル履歴は Mac に保持します。[アクセス方法](Docs/providers/README.md)を確認してください。トークン、Cookie、キーチェーン、未編集のログを公開しないでください。

本版の問題は[このリポジトリの Issues](https://github.com/wenyen-hsu/Pulse/issues)へ、macOS、アーキテクチャ、表示モード、再現手順を添えて報告してください。上流作者への本版のサポート依頼は控えてください。[貢献](CONTRIBUTING.md) · [セキュリティ](SECURITY.md) · [文書一覧](Docs/README.md)。

**qunqin24 氏と Pulse の貢献者の皆様に感謝します。** [Apache 2.0](LICENSE)、[NOTICE](NOTICE)、[第三者ライセンス](THIRD_PARTY_NOTICES.md)を維持し、インストーラと「このアプリについて」にも謝辞を表示します。変更・再配布はライセンス条件に従い、必要な表記とライセンス、変更表示、第三者の条件を守ってください。商標権や原作者の公認は付与されません。名称とロゴの選択は商標調査の完了を意味しません。

**[English](README.md) · [繁體中文](README.zh-Hant.md)**<br>
[简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Русский](README.ru.md)
