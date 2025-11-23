//
//  InitialPrompts.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import Foundation

// MARK: - Initial Prompt Data Generator
struct InitialPrompts {

    static func generate(categories: [Category], tasks: [PromptTask]) -> [Prompt] {
        // カテゴリとタスクをIDでアクセスしやすくする
        let categoryMap = Dictionary(uniqueKeysWithValues: categories.map { ($0.name, $0.id) })
        let taskMap = Dictionary(uniqueKeysWithValues: tasks.map { ($0.name, $0.id) })

        return [
            // MARK: - ビジネス カテゴリ (5件)
            Prompt(
                title: "ビジネスメール作成",
                body: """
                以下の条件でビジネスメールを作成してください。

                【宛先】{宛先の会社名・部署・氏名}
                【目的】{メールの目的}
                【トーン】{丁寧/カジュアル/フォーマル}
                【本文に含める内容】{伝えたいポイント}

                適切な件名も提案してください。
                """,
                description: "取引先や社内向けのビジネスメールを効率的に作成できます。目的に応じたトーンで適切な文面を生成します。",
                categoryId: categoryMap["ビジネス"]!,
                taskId: taskMap["文章生成"]!,
                likeCount: 156,
                favoriteCount: 89,
                useCount: 423
            ),

            Prompt(
                title: "会議アジェンダ作成",
                body: """
                以下の会議のアジェンダを作成してください。

                【会議名】{会議のタイトル}
                【目的】{会議の目的}
                【参加者】{参加者の役職・人数}
                【時間】{予定時間}
                【議題】{話し合いたいトピック}

                時間配分も含めて提案してください。
                """,
                description: "効率的な会議運営のためのアジェンダを作成します。時間配分や議題の優先順位も提案します。",
                categoryId: categoryMap["ビジネス"]!,
                taskId: taskMap["文章生成"]!,
                likeCount: 98,
                favoriteCount: 67,
                useCount: 234
            ),

            Prompt(
                title: "提案書の構成案作成",
                body: """
                以下の内容で提案書の構成案を作成してください。

                【提案先】{クライアント名・業種}
                【提案内容】{提案するサービス・商品}
                【解決する課題】{クライアントの課題}
                【予算規模】{想定予算}
                【ページ数目安】{5〜10ページなど}

                各セクションの概要も含めてください。
                """,
                description: "説得力のある提案書の骨格を作成します。クライアントの課題に寄り添った構成を提案します。",
                categoryId: categoryMap["ビジネス"]!,
                taskId: taskMap["アイデア出し"]!,
                likeCount: 134,
                favoriteCount: 112,
                useCount: 345
            ),

            Prompt(
                title: "SWOT分析",
                body: """
                以下のビジネスについてSWOT分析を行ってください。

                【事業・プロジェクト名】{分析対象}
                【業界】{業界・市場}
                【現状の概要】{事業の現状説明}
                【競合情報】{主な競合}

                Strengths（強み）、Weaknesses（弱み）、Opportunities（機会）、Threats（脅威）を各3〜5項目で整理してください。
                """,
                description: "事業やプロジェクトの戦略立案に役立つSWOT分析を実施します。",
                categoryId: categoryMap["ビジネス"]!,
                taskId: taskMap["分析"]!,
                likeCount: 89,
                favoriteCount: 78,
                useCount: 189
            ),

            Prompt(
                title: "プレゼン原稿作成",
                body: """
                以下のプレゼンテーションの原稿を作成してください。

                【テーマ】{プレゼンのテーマ}
                【対象者】{聴衆の属性}
                【時間】{発表時間}
                【目的】{伝えたいこと・行動させたいこと}
                【キーメッセージ】{最も伝えたいこと}

                スライドごとの話す内容と、聴衆の興味を引くオープニングを含めてください。
                """,
                description: "聴衆を惹きつけるプレゼン原稿を作成します。スライド構成に合わせた話す内容を生成します。",
                categoryId: categoryMap["ビジネス"]!,
                taskId: taskMap["文章生成"]!,
                likeCount: 112,
                favoriteCount: 95,
                useCount: 278
            ),

            // MARK: - マーケティング カテゴリ (5件)
            Prompt(
                title: "SNS投稿文作成",
                body: """
                以下の内容でSNS投稿文を作成してください。

                【プラットフォーム】{Twitter/Instagram/Facebook}
                【商品・サービス】{宣伝対象}
                【ターゲット】{想定読者}
                【トーン】{親しみやすい/プロフェッショナル/ユーモア}
                【含めたい情報】{URL、ハッシュタグ、CTAなど}

                文字数制限を考慮し、絵文字も適宜使用してください。
                """,
                description: "各SNSの特性に合わせた効果的な投稿文を作成します。エンゲージメントを高める文面を提案します。",
                categoryId: categoryMap["マーケティング"]!,
                taskId: taskMap["文章生成"]!,
                likeCount: 203,
                favoriteCount: 156,
                useCount: 567
            ),

            Prompt(
                title: "キャッチコピー案出し",
                body: """
                以下の商品・サービスのキャッチコピーを10案作成してください。

                【商品・サービス名】{名称}
                【特徴・強み】{主な特徴}
                【ターゲット】{想定顧客}
                【使用シーン】{広告/パッケージ/Webサイト}
                【トーン】{インパクト重視/信頼感/親しみやすさ}

                短いもの（〜10文字）と長いもの（〜30文字）を混ぜて提案してください。
                """,
                description: "商品やサービスの魅力を端的に伝えるキャッチコピーを複数案生成します。",
                categoryId: categoryMap["マーケティング"]!,
                taskId: taskMap["アイデア出し"]!,
                likeCount: 178,
                favoriteCount: 134,
                useCount: 456
            ),

            Prompt(
                title: "ペルソナ作成",
                body: """
                以下の商品・サービスの理想的な顧客ペルソナを作成してください。

                【商品・サービス】{対象商品}
                【価格帯】{価格帯}
                【解決する課題】{顧客の悩み}
                【競合】{競合商品}

                年齢、職業、年収、家族構成、趣味、価値観、情報収集方法、購買行動パターンを含めてください。名前も付けてリアリティを出してください。
                """,
                description: "マーケティング戦略立案に必要な詳細なペルソナを作成します。具体的な人物像を描きます。",
                categoryId: categoryMap["マーケティング"]!,
                taskId: taskMap["アイデア出し"]!,
                likeCount: 145,
                favoriteCount: 123,
                useCount: 312
            ),

            Prompt(
                title: "LP構成案作成",
                body: """
                以下のランディングページの構成案を作成してください。

                【商品・サービス】{対象}
                【目的】{資料請求/購入/問い合わせ}
                【ターゲット】{想定顧客}
                【強み・USP】{競合との差別化ポイント}
                【価格】{価格情報}

                ファーストビュー、問題提起、解決策、特徴、実績・事例、FAQ、CTAの各セクションを含めてください。
                """,
                description: "コンバージョンを最大化するLPの構成案を作成します。説得力のある流れを設計します。",
                categoryId: categoryMap["マーケティング"]!,
                taskId: taskMap["アイデア出し"]!,
                likeCount: 167,
                favoriteCount: 145,
                useCount: 389
            ),

            Prompt(
                title: "競合分析レポート",
                body: """
                以下の競合について分析レポートを作成してください。

                【自社商品】{自社の商品・サービス}
                【競合】{競合3〜5社}
                【比較ポイント】{価格/機能/サポート/ブランドなど}
                【市場】{ターゲット市場}

                各競合の強み・弱み、自社との比較表、差別化戦略の提案を含めてください。
                """,
                description: "競合他社の分析と自社の差別化ポイントを明確にするレポートを作成します。",
                categoryId: categoryMap["マーケティング"]!,
                taskId: taskMap["分析"]!,
                likeCount: 134,
                favoriteCount: 112,
                useCount: 267
            ),

            // MARK: - ライティング カテゴリ (5件)
            Prompt(
                title: "ブログ記事構成案",
                body: """
                以下のテーマでブログ記事の構成案を作成してください。

                【テーマ】{記事のテーマ}
                【ターゲット読者】{想定読者}
                【記事の目的】{情報提供/問題解決/商品紹介}
                【文字数目安】{文字数}
                【SEOキーワード】{狙いたいキーワード}

                タイトル案、導入文の方向性、見出し構成（H2/H3）、各セクションの概要を含めてください。
                """,
                description: "SEOを意識した効果的なブログ記事の骨格を作成します。読者を惹きつける構成を提案します。",
                categoryId: categoryMap["ライティング"]!,
                taskId: taskMap["アイデア出し"]!,
                likeCount: 234,
                favoriteCount: 189,
                useCount: 678
            ),

            Prompt(
                title: "記事タイトル案作成",
                body: """
                以下の内容で記事タイトルを10案作成してください。

                【記事の内容】{記事の概要}
                【ターゲット】{想定読者}
                【目的】{クリック率向上/SEO/SNSシェア}
                【含めたいキーワード】{必須キーワード}

                数字を使ったもの、疑問形、How to形式など、バリエーションを出してください。
                """,
                description: "クリック率を高める魅力的な記事タイトルを複数案生成します。",
                categoryId: categoryMap["ライティング"]!,
                taskId: taskMap["アイデア出し"]!,
                likeCount: 198,
                favoriteCount: 167,
                useCount: 534
            ),

            Prompt(
                title: "文章の校正・添削",
                body: """
                以下の文章を校正・添削してください。

                【文章】
                {添削してほしい文章}

                【チェックポイント】
                - 誤字脱字
                - 文法ミス
                - 冗長な表現
                - 読みやすさ
                - 論理の一貫性

                修正箇所とその理由を明示してください。
                """,
                description: "文章の誤りを指摘し、より読みやすく説得力のある文章に改善します。",
                categoryId: categoryMap["ライティング"]!,
                taskId: taskMap["添削・校正"]!,
                likeCount: 289,
                favoriteCount: 234,
                useCount: 789
            ),

            Prompt(
                title: "レビュー・感想文作成",
                body: """
                以下の商品・サービスのレビューを作成してください。

                【対象】{商品・サービス名}
                【良かった点】{満足したポイント}
                【気になった点】{改善してほしい点}
                【使用期間】{使用期間}
                【おすすめ度】{5段階評価}

                読者が参考にしやすい具体的なレビューにしてください。
                """,
                description: "商品やサービスの具体的なレビュー文を作成します。購入検討者の参考になる内容を生成します。",
                categoryId: categoryMap["ライティング"]!,
                taskId: taskMap["文章生成"]!,
                likeCount: 145,
                favoriteCount: 112,
                useCount: 345
            ),

            Prompt(
                title: "自己PR文作成",
                body: """
                以下の情報から自己PR文を作成してください。

                【職種】{応募職種}
                【経験・スキル】{主な経験とスキル}
                【強み】{アピールしたい強み}
                【具体的なエピソード】{成果を出した経験}
                【文字数】{目安文字数}

                STAR法（状況・課題・行動・結果）を意識した構成にしてください。
                """,
                description: "就職・転職活動で使える説得力のある自己PR文を作成します。",
                categoryId: categoryMap["ライティング"]!,
                taskId: taskMap["文章生成"]!,
                likeCount: 178,
                favoriteCount: 156,
                useCount: 456
            ),

            // MARK: - 学習・教育 カテゴリ (5件)
            Prompt(
                title: "概念の簡単な説明",
                body: """
                以下の概念を分かりやすく説明してください。

                【概念・用語】{説明してほしい概念}
                【対象者のレベル】{初心者/中級者/専門家}
                【説明の長さ】{短く/詳しく}
                【具体例】{例があると理解しやすい場合はリクエスト}

                専門用語を使う場合は、その都度解説を加えてください。
                """,
                description: "難しい概念や用語を対象者のレベルに合わせて分かりやすく説明します。",
                categoryId: categoryMap["学習・教育"]!,
                taskId: taskMap["説明・解説"]!,
                likeCount: 267,
                favoriteCount: 212,
                useCount: 678
            ),

            Prompt(
                title: "要約作成",
                body: """
                以下の文章を要約してください。

                【原文】
                {要約したい文章}

                【要約の長さ】{〇〇文字程度/〇〇割程度}
                【重視する点】{主張/データ/結論}

                重要なポイントが漏れないようにしてください。
                """,
                description: "長い文章や記事を簡潔に要約します。重要なポイントを逃さずまとめます。",
                categoryId: categoryMap["学習・教育"]!,
                taskId: taskMap["要約"]!,
                likeCount: 312,
                favoriteCount: 267,
                useCount: 890
            ),

            Prompt(
                title: "クイズ・問題作成",
                body: """
                以下のテーマで学習用のクイズを作成してください。

                【テーマ】{学習テーマ}
                【難易度】{初級/中級/上級}
                【問題数】{問題数}
                【形式】{選択式/記述式/○×}
                【対象者】{学習者の属性}

                解答と解説も含めてください。
                """,
                description: "学習内容の定着を確認するためのクイズや問題を作成します。解説付きで理解を深めます。",
                categoryId: categoryMap["学習・教育"]!,
                taskId: taskMap["質問作成"]!,
                likeCount: 189,
                favoriteCount: 156,
                useCount: 423
            ),

            Prompt(
                title: "勉強計画作成",
                body: """
                以下の目標に向けた勉強計画を作成してください。

                【目標】{資格試験/スキル習得など}
                【期限】{目標達成期限}
                【現在のレベル】{現状のスキルレベル}
                【1日の勉強時間】{確保できる時間}
                【使用教材】{持っている教材}

                週ごとのマイルストーンと、具体的な学習内容を提案してください。
                """,
                description: "目標達成に向けた具体的な勉強計画を作成します。無理のないペースで設計します。",
                categoryId: categoryMap["学習・教育"]!,
                taskId: taskMap["アイデア出し"]!,
                likeCount: 234,
                favoriteCount: 198,
                useCount: 567
            ),

            Prompt(
                title: "英文の文法解説",
                body: """
                以下の英文の文法を解説してください。

                【英文】
                {解説してほしい英文}

                【知りたいこと】{特に知りたい文法ポイント}
                【レベル】{初心者/中級/上級}

                文の構造、使われている文法、なぜその表現なのかを解説してください。
                """,
                description: "英文の文法構造を詳しく解説します。文法ポイントを理解しやすく説明します。",
                categoryId: categoryMap["学習・教育"]!,
                taskId: taskMap["説明・解説"]!,
                likeCount: 178,
                favoriteCount: 145,
                useCount: 389
            ),

            // MARK: - プログラミング カテゴリ (5件)
            Prompt(
                title: "コードレビュー",
                body: """
                以下のコードをレビューしてください。

                【言語】{プログラミング言語}
                【コード】
                ```
                {レビューしてほしいコード}
                ```

                【確認してほしい点】
                - バグの可能性
                - パフォーマンス
                - 可読性
                - セキュリティ

                改善提案とその理由を具体的に示してください。
                """,
                description: "コードの問題点を指摘し、改善案を提案します。品質向上に役立ちます。",
                categoryId: categoryMap["プログラミング"]!,
                taskId: taskMap["添削・校正"]!,
                likeCount: 298,
                favoriteCount: 245,
                useCount: 678
            ),

            Prompt(
                title: "関数・メソッド作成",
                body: """
                以下の仕様で関数を作成してください。

                【言語】{プログラミング言語}
                【機能】{実現したい機能}
                【入力】{引数の型と内容}
                【出力】{戻り値の型と内容}
                【制約】{パフォーマンス要件など}

                コメントとテストケースも含めてください。
                """,
                description: "仕様に基づいた関数やメソッドを作成します。テストケース付きで品質を担保します。",
                categoryId: categoryMap["プログラミング"]!,
                taskId: taskMap["コード生成"]!,
                likeCount: 267,
                favoriteCount: 223,
                useCount: 612
            ),

            Prompt(
                title: "エラー解決サポート",
                body: """
                以下のエラーの原因と解決策を教えてください。

                【言語/フレームワーク】{使用技術}
                【エラーメッセージ】
                ```
                {エラーメッセージ}
                ```
                【関連コード】
                ```
                {エラーが発生したコード}
                ```
                【やろうとしていたこと】{実現したかった動作}

                原因の説明と、具体的な修正方法を示してください。
                """,
                description: "エラーの原因を特定し、具体的な解決策を提示します。デバッグ作業を効率化します。",
                categoryId: categoryMap["プログラミング"]!,
                taskId: taskMap["説明・解説"]!,
                likeCount: 345,
                favoriteCount: 289,
                useCount: 890
            ),

            Prompt(
                title: "正規表現作成",
                body: """
                以下の条件に合う正規表現を作成してください。

                【マッチさせたいパターン】{パターンの説明}
                【マッチする例】{具体例}
                【マッチしない例】{除外したい例}
                【使用言語】{JavaScript/Python/etc}

                正規表現と、各部分の解説を含めてください。
                """,
                description: "条件に合った正規表現を作成し、パターンの解説も行います。",
                categoryId: categoryMap["プログラミング"]!,
                taskId: taskMap["コード生成"]!,
                likeCount: 189,
                favoriteCount: 156,
                useCount: 423
            ),

            Prompt(
                title: "SQLクエリ作成",
                body: """
                以下の条件でSQLクエリを作成してください。

                【データベース】{MySQL/PostgreSQL/etc}
                【テーブル構造】
                {テーブル名とカラム情報}

                【取得したいデータ】{欲しい結果の説明}
                【条件】{WHERE条件}
                【ソート・グループ】{ORDER BY/GROUP BY}

                クエリとその説明を含めてください。
                """,
                description: "条件に合ったSQLクエリを作成し、各句の意味も解説します。",
                categoryId: categoryMap["プログラミング"]!,
                taskId: taskMap["コード生成"]!,
                likeCount: 223,
                favoriteCount: 189,
                useCount: 534
            ),

            // MARK: - 日常・生活 カテゴリ (5件)
            Prompt(
                title: "レシピ提案",
                body: """
                以下の条件でレシピを提案してください。

                【材料】{使いたい食材、または冷蔵庫にあるもの}
                【人数】{何人分}
                【調理時間】{目安時間}
                【ジャンル】{和食/洋食/中華/etc}
                【制限】{アレルギー/ダイエット/etc}

                材料リスト、手順、コツを含めてください。
                """,
                description: "手持ちの食材や条件からレシピを提案します。詳しい手順付きで料理初心者も安心。",
                categoryId: categoryMap["日常・生活"]!,
                taskId: taskMap["アイデア出し"]!,
                likeCount: 278,
                favoriteCount: 234,
                useCount: 678
            ),

            Prompt(
                title: "旅行プラン作成",
                body: """
                以下の条件で旅行プランを作成してください。

                【目的地】{行き先}
                【期間】{日数}
                【人数・構成】{人数と年齢層}
                【予算】{交通費・宿泊費・食費など}
                【重視すること】{観光/グルメ/リラックス}
                【移動手段】{車/電車/飛行機}

                タイムスケジュール形式で提案してください。
                """,
                description: "条件に合った旅行プランをタイムスケジュール形式で提案します。",
                categoryId: categoryMap["日常・生活"]!,
                taskId: taskMap["アイデア出し"]!,
                likeCount: 234,
                favoriteCount: 198,
                useCount: 567
            ),

            Prompt(
                title: "贈り物アイデア",
                body: """
                以下の条件でプレゼントのアイデアを10個提案してください。

                【贈る相手】{関係性と属性}
                【シーン】{誕生日/記念日/お礼など}
                【予算】{予算範囲}
                【相手の趣味・好み】{分かっている情報}
                【避けたいもの】{NGなもの}

                各アイデアに選んだ理由も添えてください。
                """,
                description: "贈る相手に合ったプレゼントアイデアを複数提案します。選ぶ際の参考情報付き。",
                categoryId: categoryMap["日常・生活"]!,
                taskId: taskMap["アイデア出し"]!,
                likeCount: 198,
                favoriteCount: 167,
                useCount: 445
            ),

            Prompt(
                title: "断り方・お詫び文作成",
                body: """
                以下の状況での断り方・お詫び文を作成してください。

                【状況】{断りたい/お詫びしたい状況}
                【相手】{相手との関係性}
                【伝える手段】{対面/メール/LINE}
                【トーン】{丁寧/カジュアル}
                【伝えたいニュアンス】{今後の関係を維持したい/etc}

                相手の気持ちを考慮した文面にしてください。
                """,
                description: "角の立たない断り方やお詫びの文面を作成します。人間関係を円滑に保ちます。",
                categoryId: categoryMap["日常・生活"]!,
                taskId: taskMap["文章生成"]!,
                likeCount: 167,
                favoriteCount: 145,
                useCount: 389
            ),

            Prompt(
                title: "家計の見直しアドバイス",
                body: """
                以下の家計状況を分析し、節約アドバイスをください。

                【月収】{手取り月収}
                【支出内訳】
                {固定費と変動費の内訳}

                【貯蓄目標】{月々の貯蓄目標}
                【家族構成】{家族構成}
                【削れない支出】{優先度が高い支出}

                具体的な節約ポイントと優先順位を提案してください。
                """,
                description: "家計の支出を分析し、具体的な節約ポイントを提案します。",
                categoryId: categoryMap["日常・生活"]!,
                taskId: taskMap["分析"]!,
                likeCount: 189,
                favoriteCount: 156,
                useCount: 423
            ),

            // MARK: - クリエイティブ カテゴリ (5件)
            Prompt(
                title: "ストーリーアイデア",
                body: """
                以下の条件で物語のアイデアを3つ提案してください。

                【ジャンル】{ファンタジー/ミステリー/恋愛/etc}
                【舞台】{時代・場所}
                【主人公像】{主人公の属性}
                【テーマ】{扱いたいテーマ}
                【長さ】{短編/中編/長編}

                各アイデアにあらすじとキャラクター案を含めてください。
                """,
                description: "条件に基づいた物語のアイデアを複数提案します。創作のきっかけに。",
                categoryId: categoryMap["クリエイティブ"]!,
                taskId: taskMap["アイデア出し"]!,
                likeCount: 156,
                favoriteCount: 134,
                useCount: 345
            ),

            Prompt(
                title: "キャラクター設定作成",
                body: """
                以下の条件でキャラクター設定を作成してください。

                【役割】{主人公/ヒロイン/敵役/etc}
                【作品ジャンル】{ジャンル}
                【性格のキーワード】{性格の方向性}
                【外見イメージ】{ざっくりとした外見}
                【背景設定】{持たせたい過去や環境}

                名前、年齢、外見、性格、能力、過去、目標、口癖を含めてください。
                """,
                description: "魅力的なキャラクターの詳細設定を作成します。小説やゲーム制作に活用できます。",
                categoryId: categoryMap["クリエイティブ"]!,
                taskId: taskMap["アイデア出し"]!,
                likeCount: 145,
                favoriteCount: 123,
                useCount: 312
            ),

            Prompt(
                title: "ネーミングアイデア",
                body: """
                以下の条件で名前のアイデアを20個提案してください。

                【対象】{商品/サービス/キャラクター/店名/etc}
                【コンセプト】{伝えたいイメージ}
                【ジャンル・業界】{分野}
                【言語】{日本語/英語/造語OK}
                【文字数】{目安文字数}
                【避けたい響き】{NGなイメージ}

                各名前に込めた意味も説明してください。
                """,
                description: "コンセプトに合ったネーミング案を多数提案します。由来の説明付き。",
                categoryId: categoryMap["クリエイティブ"]!,
                taskId: taskMap["アイデア出し"]!,
                likeCount: 198,
                favoriteCount: 167,
                useCount: 456
            ),

            Prompt(
                title: "色の組み合わせ提案",
                body: """
                以下の条件でカラーパレットを提案してください。

                【用途】{Webサイト/ロゴ/インテリア/etc}
                【イメージ】{与えたい印象}
                【メインカラー】{決まっている場合}
                【色数】{3色/5色/etc}
                【避けたい色】{使いたくない色}

                HEXコードと各色の役割（メイン/サブ/アクセント）を示してください。
                """,
                description: "目的に合ったカラーパレットを提案します。デザイン作業の効率化に。",
                categoryId: categoryMap["クリエイティブ"]!,
                taskId: taskMap["アイデア出し"]!,
                likeCount: 134,
                favoriteCount: 112,
                useCount: 289
            ),

            Prompt(
                title: "写真の撮影アドバイス",
                body: """
                以下の条件での撮影アドバイスをください。

                【被写体】{何を撮るか}
                【目的】{SNS投稿/商品撮影/記念写真}
                【機材】{スマホ/一眼/etc}
                【環境】{室内/屋外/時間帯}
                【イメージ】{撮りたい雰囲気}

                構図、ライティング、カメラ設定のアドバイスを具体的にください。
                """,
                description: "被写体や目的に合った撮影テクニックをアドバイスします。",
                categoryId: categoryMap["クリエイティブ"]!,
                taskId: taskMap["説明・解説"]!,
                likeCount: 123,
                favoriteCount: 98,
                useCount: 267
            ),

            // MARK: - 分析・リサーチ カテゴリ (5件)
            Prompt(
                title: "データの傾向分析",
                body: """
                以下のデータの傾向を分析してください。

                【データ】
                {分析したいデータ}

                【分析の目的】{知りたいこと}
                【背景情報】{データの文脈}
                【出力形式】{箇条書き/レポート形式}

                主要な傾向、異常値、考察、次のアクションを含めてください。
                """,
                description: "提供されたデータから傾向や洞察を抽出します。意思決定のサポートに。",
                categoryId: categoryMap["分析・リサーチ"]!,
                taskId: taskMap["分析"]!,
                likeCount: 178,
                favoriteCount: 145,
                useCount: 389
            ),

            Prompt(
                title: "市場調査サポート",
                body: """
                以下のテーマで市場調査の観点を整理してください。

                【調査テーマ】{調査対象の市場・業界}
                【目的】{新規参入/競合分析/トレンド把握}
                【知りたいこと】{具体的な疑問点}
                【予算・リソース】{調査にかけられる規模}

                調査すべき項目、情報源、調査方法を提案してください。
                """,
                description: "市場調査の計画立案をサポートします。調査項目と方法を整理します。",
                categoryId: categoryMap["分析・リサーチ"]!,
                taskId: taskMap["アイデア出し"]!,
                likeCount: 145,
                favoriteCount: 123,
                useCount: 312
            ),

            Prompt(
                title: "アンケート設問作成",
                body: """
                以下の目的でアンケートの設問を作成してください。

                【調査目的】{知りたいこと}
                【対象者】{回答者の属性}
                【設問数】{目安の設問数}
                【形式】{選択式/自由記述/混合}
                【利用シーン】{社内調査/顧客調査/etc}

                バイアスを避ける設問設計を心がけてください。
                """,
                description: "調査目的に合ったアンケート設問を作成します。回答率を高める設計に。",
                categoryId: categoryMap["分析・リサーチ"]!,
                taskId: taskMap["質問作成"]!,
                likeCount: 156,
                favoriteCount: 134,
                useCount: 345
            ),

            Prompt(
                title: "文献・記事の要点整理",
                body: """
                以下の文献・記事の要点を整理してください。

                【文献・記事】
                {内容またはURL}

                【整理の目的】{論文執筆/ビジネス活用/学習}
                【重視する観点】{方法論/結果/応用可能性}
                【出力形式】{箇条書き/表/マインドマップ形式}

                重要なポイント、キーワード、引用すべき箇所を明示してください。
                """,
                description: "文献や記事の要点を目的に応じて整理します。情報整理の効率化に。",
                categoryId: categoryMap["分析・リサーチ"]!,
                taskId: taskMap["要約"]!,
                likeCount: 189,
                favoriteCount: 156,
                useCount: 423
            ),

            Prompt(
                title: "仮説立案サポート",
                body: """
                以下の問題に対する仮説を立案してください。

                【問題・課題】{解決したい問題}
                【背景情報】{現状の状況}
                【これまでの取り組み】{試したこと}
                【制約条件】{予算/時間/リソース}

                複数の仮説と、それぞれの検証方法を提案してください。
                """,
                description: "問題解決のための仮説を複数立案し、検証方法も提案します。",
                categoryId: categoryMap["分析・リサーチ"]!,
                taskId: taskMap["アイデア出し"]!,
                likeCount: 134,
                favoriteCount: 112,
                useCount: 289
            ),

            // MARK: - コミュニケーション カテゴリ (5件)
            Prompt(
                title: "スピーチ原稿作成",
                body: """
                以下の条件でスピーチ原稿を作成してください。

                【場面】{結婚式/朝礼/表彰式/etc}
                【話者の立場】{新郎/上司/受賞者/etc}
                【時間】{スピーチ時間}
                【トーン】{感動的/ユーモア/フォーマル}
                【含めたいエピソード】{具体的なエピソード}

                冒頭の掴みと締めの言葉を工夫してください。
                """,
                description: "場面に合ったスピーチ原稿を作成します。聴衆の心に残る内容に仕上げます。",
                categoryId: categoryMap["コミュニケーション"]!,
                taskId: taskMap["文章生成"]!,
                likeCount: 178,
                favoriteCount: 156,
                useCount: 423
            ),

            Prompt(
                title: "フィードバックの伝え方",
                body: """
                以下の状況でのフィードバックの伝え方を教えてください。

                【対象者】{部下/同僚/外注先}
                【フィードバック内容】{伝えたいこと}
                【目的】{改善/称賛/方向修正}
                【関係性】{普段の関係性}
                【伝える手段】{対面/メール/チャット}

                相手のモチベーションを下げずに伝える方法を提案してください。
                """,
                description: "効果的なフィードバックの伝え方を提案します。相手との関係性を考慮します。",
                categoryId: categoryMap["コミュニケーション"]!,
                taskId: taskMap["文章生成"]!,
                likeCount: 145,
                favoriteCount: 123,
                useCount: 312
            ),

            Prompt(
                title: "交渉・説得の戦略",
                body: """
                以下の交渉・説得の戦略を提案してください。

                【目的】{達成したいこと}
                【相手】{交渉相手の立場・属性}
                【相手のメリット】{相手にとっての利点}
                【予想される反論】{想定される反対意見}
                【譲れないライン】{最低限の条件}

                論理と感情の両面からのアプローチを提案してください。
                """,
                description: "Win-Winの交渉戦略を提案します。相手を説得するポイントを整理します。",
                categoryId: categoryMap["コミュニケーション"]!,
                taskId: taskMap["アイデア出し"]!,
                likeCount: 156,
                favoriteCount: 134,
                useCount: 345
            ),

            Prompt(
                title: "質問リスト作成",
                body: """
                以下の目的で質問リストを作成してください。

                【目的】{インタビュー/ヒアリング/面接}
                【対象者】{質問する相手}
                【知りたいこと】{得たい情報}
                【時間】{持ち時間}
                【形式】{オープン/クローズド}

                優先順位を付けて、深掘りのフォローアップ質問も含めてください。
                """,
                description: "目的に合った質問リストを作成します。深い情報を引き出す設計に。",
                categoryId: categoryMap["コミュニケーション"]!,
                taskId: taskMap["質問作成"]!,
                likeCount: 167,
                favoriteCount: 145,
                useCount: 389
            ),

            Prompt(
                title: "議事録作成",
                body: """
                以下の会議メモから議事録を作成してください。

                【会議メモ】
                {会議のメモ・走り書き}

                【出席者】{参加者リスト}
                【会議の目的】{会議の目的}
                【フォーマット】{正式/簡易}

                決定事項、アクションアイテム（担当者・期限）、次回予定を明確にしてください。
                """,
                description: "会議メモから読みやすい議事録を作成します。アクションアイテムを明確化します。",
                categoryId: categoryMap["コミュニケーション"]!,
                taskId: taskMap["文章生成"]!,
                likeCount: 189,
                favoriteCount: 167,
                useCount: 456
            ),

            // MARK: - その他 カテゴリ (5件)
            Prompt(
                title: "比較表作成",
                body: """
                以下の項目の比較表を作成してください。

                【比較対象】{比較したいもの（3〜5項目）}
                【比較軸】{比較したいポイント}
                【重視する観点】{最も重要な判断基準}
                【出力形式】{表/箇条書き}

                総合評価とおすすめも含めてください。
                """,
                description: "複数の選択肢を比較する表を作成します。意思決定をサポートします。",
                categoryId: categoryMap["その他"]!,
                taskId: taskMap["分析"]!,
                likeCount: 198,
                favoriteCount: 167,
                useCount: 456
            ),

            Prompt(
                title: "メリット・デメリット整理",
                body: """
                以下の事柄のメリット・デメリットを整理してください。

                【対象】{検討している事柄}
                【文脈】{どういう状況での検討か}
                【重視する観点】{特に気にしていること}
                【比較対象】{現状や代替案}

                各項目を5つ程度ずつ挙げ、総合的なアドバイスもください。
                """,
                description: "意思決定のためのメリット・デメリットを整理します。客観的な判断材料に。",
                categoryId: categoryMap["その他"]!,
                taskId: taskMap["分析"]!,
                likeCount: 178,
                favoriteCount: 156,
                useCount: 423
            ),

            Prompt(
                title: "翻訳（日英・英日）",
                body: """
                以下の文章を翻訳してください。

                【原文】
                {翻訳したい文章}

                【翻訳の方向】{日本語→英語 / 英語→日本語}
                【トーン】{フォーマル/カジュアル/ビジネス}
                【用途】{メール/資料/会話}
                【専門分野】{特定の分野があれば}

                必要に応じて複数のバリエーションを提案してください。
                """,
                description: "文脈に合った自然な翻訳を提供します。トーンや用途を考慮します。",
                categoryId: categoryMap["その他"]!,
                taskId: taskMap["翻訳"]!,
                likeCount: 267,
                favoriteCount: 223,
                useCount: 678
            ),

            Prompt(
                title: "言い換え・リライト",
                body: """
                以下の文章を言い換えてください。

                【原文】
                {言い換えたい文章}

                【目的】{分かりやすく/フォーマルに/カジュアルに/短く}
                【対象読者】{誰向けに}
                【トーン】{変えたいトーン}
                【制約】{文字数制限など}

                元の意味を保ちながら言い換えてください。
                """,
                description: "文章を目的に合わせて言い換えます。読者や場面に適した表現に。",
                categoryId: categoryMap["その他"]!,
                taskId: taskMap["文章生成"]!,
                likeCount: 189,
                favoriteCount: 156,
                useCount: 445
            ),

            Prompt(
                title: "To-Doリスト作成",
                body: """
                以下のプロジェクト・タスクのTo-Doリストを作成してください。

                【プロジェクト・タスク名】{名称}
                【目標】{達成したいこと}
                【期限】{最終期限}
                【現状】{今どこまで進んでいるか}
                【メンバー】{担当者がいれば}

                優先順位、担当者、期限を付けて、漏れがないようにしてください。
                """,
                description: "プロジェクトを実行可能なTo-Doに分解します。抜け漏れを防ぎます。",
                categoryId: categoryMap["その他"]!,
                taskId: taskMap["アイデア出し"]!,
                likeCount: 212,
                favoriteCount: 189,
                useCount: 534
            )
        ]
    }
}
