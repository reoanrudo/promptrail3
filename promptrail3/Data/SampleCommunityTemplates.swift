//
//  SampleCommunityTemplates.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import Foundation

// サンプルのコミュニティテンプレート
func createSampleCommunityTemplates(categories: [Category], tasks: [PromptTask]) -> [CommunityTemplate] {
    guard let marketingCategory = categories.first(where: { $0.name == "マーケティング" }),
          let businessCategory = categories.first(where: { $0.name == "ビジネス" }),
          let writingCategory = categories.first(where: { $0.name == "ライティング" }),
          let programmingCategory = categories.first(where: { $0.name == "プログラミング" }),
          let learningCategory = categories.first(where: { $0.name == "学習・教育" }),
          let createTask = tasks.first(where: { $0.name == "生成" }),
          let analyzeTask = tasks.first(where: { $0.name == "分析" }),
          let ideaTask = tasks.first(where: { $0.name == "アイデア出し" })
    else { return [] }

    let userId = UUID() // サンプル用の共通ユーザーID

    return [
        // 1. 人気テンプレ
        CommunityTemplate(
            userId: userId,
            title: "感情に訴えるキャッチコピー生成",
            body: """
あなたはコピーライティングの専門家です。

## 商品情報
- 商品名：{商品名}
- ターゲット：{ターゲット層}
- 主な特徴：{主な特徴}
- 解決する悩み：{解決する悩み}

## 出力要件
以下の5つの感情パターンでキャッチコピーを各3案ずつ生成してください：

1. **希望・期待** - 未来の理想像を描く
2. **恐怖・不安** - 失うことへの恐れを刺激
3. **好奇心** - 知りたい欲求を刺激
4. **共感** - 同じ悩みを持つ仲間意識
5. **優越感** - 特別な存在になれる期待

各コピーには、なぜその感情に訴求するかの簡単な解説を添えてください。
""",
            description: "5つの感情パターンに基づいたキャッチコピーを生成します。ターゲットの心理に深く刺さるコピーを作りたい時に。",
            categoryId: marketingCategory.id,
            taskId: createTask.id,
            tags: ["コピーライティング", "マーケティング", "広告"],
            templateVariables: [
                TemplateVariable(variableName: "商品名", label: "商品名", placeholder: "例：オーガニック美容クリーム", order: 0),
                TemplateVariable(variableName: "ターゲット層", label: "ターゲット層", placeholder: "例：30代女性、敏感肌で悩んでいる", order: 1),
                TemplateVariable(variableName: "主な特徴", label: "主な特徴", placeholder: "例：天然成分100%、低刺激", order: 2),
                TemplateVariable(variableName: "解決する悩み", label: "解決する悩み", placeholder: "例：乾燥肌、肌荒れ", order: 3)
            ],
            likeCount: 342,
            useCount: 1567,
            authorName: "マーケター太郎"
        ),

        // 2. ビジネス向け
        CommunityTemplate(
            userId: userId,
            title: "1on1ミーティング質問テンプレート",
            body: """
あなたは経験豊富なマネージャーです。

## 状況
- メンバー名：{メンバー名}
- 役職/担当：{役職}
- 最近の様子：{最近の様子}
- 1on1の目的：{目的}

## 出力
以下のカテゴリごとに3つずつ、効果的な質問を生成してください：

### 1. 業務の進捗・課題
- 現状把握と障害の特定

### 2. キャリア・成長
- 将来の展望と成長機会

### 3. チーム・環境
- 働きやすさと人間関係

### 4. フィードバック
- 上司への要望や改善点

各質問には、なぜその質問が効果的かの一言解説を添えてください。
""",
            description: "チームメンバーとの1on1で使える質問リストを生成。部下の本音を引き出し、信頼関係を構築するのに役立ちます。",
            categoryId: businessCategory.id,
            taskId: ideaTask.id,
            tags: ["マネジメント", "1on1", "チームビルディング"],
            likeCount: 256,
            useCount: 892,
            authorName: "マネジメント研究家"
        ),

        // 3. ライティング
        CommunityTemplate(
            userId: userId,
            title: "説得力のある提案書の構成作成",
            body: """
あなたはビジネスコンサルタントです。

## 提案概要
- 提案タイトル：{提案タイトル}
- 提案先：{提案先（企業名・部署）}
- 提案の目的：{目的}
- 主な提案内容：{提案内容の概要}
- 想定予算規模：{予算}

## 出力形式
以下の構成で提案書のアウトラインを作成してください：

1. **エグゼクティブサマリー**
   - 1ページで読める要約

2. **現状分析と課題**
   - データに基づく現状把握
   - 顕在・潜在課題の整理

3. **提案内容**
   - ソリューションの詳細
   - 実施ステップ
   - スケジュール

4. **期待効果**
   - 定量的効果（KPI）
   - 定性的効果

5. **投資対効果**
   - コスト内訳
   - ROI試算

6. **リスクと対策**

7. **次のステップ**

各セクションに含めるべきポイントを3-5個リストアップしてください。
""",
            description: "クライアントや上司を納得させる提案書の構成を作成。ロジカルで説得力のある資料作りの骨子が得られます。",
            categoryId: writingCategory.id,
            taskId: createTask.id,
            tags: ["提案書", "ビジネス文書", "プレゼン"],
            likeCount: 189,
            useCount: 734,
            authorName: "ビジネスライター"
        ),

        // 4. プログラミング
        CommunityTemplate(
            userId: userId,
            title: "コードレビューチェックリスト生成",
            body: """
あなたはシニアソフトウェアエンジニアです。

## レビュー対象
- プログラミング言語：{言語}
- 機能/コンポーネント：{機能名}
- コードの規模：{行数や複雑度}
- 重視するポイント：{パフォーマンス/セキュリティ/可読性など}

## 出力
以下のカテゴリでコードレビューチェックリストを生成してください：

### 1. 機能要件
- 仕様通りに動作するか

### 2. コード品質
- 命名規則
- コメント
- 重複排除
- 単一責任原則

### 3. パフォーマンス
- 計算量
- メモリ使用
- N+1問題

### 4. セキュリティ
- 入力検証
- 認証・認可
- 機密情報の扱い

### 5. テスタビリティ
- ユニットテスト
- モック化のしやすさ

### 6. 保守性
- 将来の変更への対応
- ドキュメント

各項目を「確認済み / 要修正 / 該当なし」で評価できる形式にしてください。
""",
            description: "言語やプロジェクトに合わせたコードレビューのチェックリストを生成。レビューの質を均一化し、見落としを防ぎます。",
            categoryId: programmingCategory.id,
            taskId: analyzeTask.id,
            tags: ["コードレビュー", "開発", "品質管理"],
            likeCount: 423,
            useCount: 2134,
            authorName: "テックリード"
        ),

        // 5. 学習向け
        CommunityTemplate(
            userId: userId,
            title: "効率的な学習計画ジェネレーター",
            body: """
あなたは学習設計の専門家です。

## 学習目標
- 学びたいこと：{学習テーマ}
- 現在のレベル：{初心者/中級者/上級者}
- 目標レベル：{目標}
- 利用可能な時間：{週あたりの学習時間}
- 期限：{いつまでに}

## 出力
以下の形式で学習計画を作成してください：

### 1. 学習ロードマップ
- フェーズ分け（基礎→応用→実践）
- 各フェーズの目標と期間

### 2. 週次スケジュール
- 曜日ごとの学習内容
- 1回あたりの学習時間

### 3. 推奨リソース
- 無料教材（YouTube、記事）
- 有料教材（書籍、オンラインコース）
- 実践的なプロジェクト案

### 4. マイルストーン
- 週次の達成目標
- 中間チェックポイント
- 最終ゴール

### 5. つまずきポイントと対策
- よくある挫折ポイント
- モチベーション維持のコツ

具体的で実行可能な計画にしてください。
""",
            description: "目標に合わせた学習計画を自動生成。独学でも迷わず進められるロードマップが手に入ります。",
            categoryId: learningCategory.id,
            taskId: createTask.id,
            tags: ["学習計画", "自己啓発", "スキルアップ"],
            likeCount: 567,
            useCount: 2891,
            authorName: "学習ハッカー"
        ),

        // 6. 新着テンプレ
        CommunityTemplate(
            userId: userId,
            title: "ユーザーインタビュー質問設計",
            body: """
あなたはUXリサーチャーです。

## リサーチ概要
- 製品/サービス名：{サービス名}
- リサーチ目的：{目的}
- ターゲットユーザー：{ペルソナ}
- インタビュー時間：{所要時間}

## 出力
以下の構成でインタビュー質問を設計してください：

### 1. アイスブレイク（5分）
- 緊張をほぐす導入質問

### 2. 背景理解（10分）
- ユーザーの属性・環境
- 関連する経験・習慣

### 3. 課題・ニーズ探索（15分）
- 現在の課題
- 理想の状態
- 感情面での不満

### 4. 行動・意思決定（10分）
- 選択基準
- 情報収集方法

### 5. 製品/コンセプトへの反応（10分）
- 第一印象
- 魅力的な点・懸念点

### 6. クロージング（5分）
- 追加で話したいこと
- 次回協力への意向

各質問には「なぜこの質問をするか」のインタビュアー向けメモを添えてください。
""",
            description: "ユーザーインタビューの質問リストを構造的に設計。バイアスを避けながら、深いインサイトを引き出せます。",
            categoryId: businessCategory.id,
            taskId: ideaTask.id,
            tags: ["UXリサーチ", "インタビュー", "ユーザー理解"],
            likeCount: 78,
            useCount: 234,
            createdAt: Date().addingTimeInterval(-3600), // 1時間前
            authorName: "UXデザイナー"
        ),

        // 7. マーケティング
        CommunityTemplate(
            userId: userId,
            title: "A/Bテスト仮説設計フレームワーク",
            body: """
あなたはグロースハッカーです。

## テスト概要
- 対象ページ/機能：{対象}
- 現状の課題：{課題}
- 主要KPI：{KPI}
- 想定サンプルサイズ：{ユーザー数}

## 出力
以下の形式でA/Bテストの設計を行ってください：

### 1. 仮説の構造化
「{対象ユーザー}に対して{変更内容}を実施すると、{理由}により、{期待される結果}になる」の形式で仮説を3つ立ててください。

### 2. 変更案の詳細
各仮説について：
- コントロール（現状）
- バリエーション（変更後）
- 変更の理論的根拠

### 3. 測定指標
- 主要指標（1つ）
- 副次指標（2-3つ）
- ガードレール指標

### 4. テスト設計
- 必要サンプルサイズ
- 推奨テスト期間
- セグメンテーション

### 5. 判定基準
- 統計的有意性の閾値
- 実用的有意性の基準
- 意思決定ルール

根拠のある仮説と実行可能な設計にしてください。
""",
            description: "効果的なA/Bテストの仮説と設計を生成。データドリブンな意思決定を加速します。",
            categoryId: marketingCategory.id,
            taskId: analyzeTask.id,
            tags: ["A/Bテスト", "グロース", "データ分析"],
            likeCount: 156,
            useCount: 567,
            authorName: "グロースマーケター"
        ),

        // 8. ライティング
        CommunityTemplate(
            userId: userId,
            title: "読者を惹きつけるブログ導入文",
            body: """
あなたは人気ブロガーです。

## 記事情報
- 記事タイトル：{タイトル}
- 主なキーワード：{キーワード}
- ターゲット読者：{読者像}
- 読者の悩み：{悩み}
- 記事で得られる価値：{価値}

## 出力
以下の5パターンで導入文（リード文）を生成してください：

### 1. 問題提起型
読者の悩みに共感し、解決を約束

### 2. 数字・データ型
驚きの統計で興味を引く

### 3. ストーリー型
具体的なエピソードで惹きつける

### 4. 質問型
読者に問いかけて巻き込む

### 5. 逆説型
常識を覆す主張で注目させる

各パターン150-200字程度で、読み進めたくなる導入文を作成してください。
""",
            description: "離脱を防ぐ魅力的な導入文を5パターン生成。記事の完読率アップに効果的です。",
            categoryId: writingCategory.id,
            taskId: createTask.id,
            tags: ["ブログ", "ライティング", "導入文"],
            likeCount: 234,
            useCount: 1023,
            authorName: "ブロガーZ"
        )
    ]
}

// 人気タグのサンプル
func createSampleTags() -> [Tag] {
    return [
        Tag(name: "ビジネス", useCount: 1234),
        Tag(name: "マーケティング", useCount: 987),
        Tag(name: "ライティング", useCount: 876),
        Tag(name: "プログラミング", useCount: 765),
        Tag(name: "学習", useCount: 654),
        Tag(name: "コピーライティング", useCount: 543),
        Tag(name: "提案書", useCount: 432),
        Tag(name: "コードレビュー", useCount: 321),
        Tag(name: "1on1", useCount: 234),
        Tag(name: "A/Bテスト", useCount: 123)
    ]
}
