//
//  PromptStore.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import Foundation
import Combine
import CryptoKit

@MainActor
class PromptStore: ObservableObject {
    // MARK: - Firebase Managers
    private(set) var authManager: AuthManager
    private(set) var firestoreManager: FirestoreManager

    // MARK: - Published Properties
    @Published var categories: [Category] = []
    @Published var tasks: [PromptTask] = []
    @Published var prompts: [Prompt] = []
    @Published var favorites: [Favorite] = []
    @Published var folders: [Folder] = []
    @Published var usageHistory: [UsageHistory] = []

    // Community
    @Published var communityTemplates: [CommunityTemplate] = []
    @Published var templateLikes: [TemplateLike] = []
    @Published var popularTags: [Tag] = []

    // My Templates
    @Published var myTemplates: [MyTemplate] = []
    @Published var templateUsageHistory: [TemplateUsageHistory] = []

    // Image Prompts
    @Published var imagePromptTemplates: [ImagePromptTemplate] = []
    @Published var imagePromptLikes: [ImagePromptLike] = []

    // Workflows
    @Published var workflows: [Workflow] = []
    @Published var workflowLikes: [WorkflowLike] = []

    // Quick Prompts
    @Published var quickPrompts: [QuickPrompt] = []
    @Published var savedQuickPrompts: [QuickPrompt] = []
    @Published var quickPromptLikes: [QuickPromptLike] = []

    // Navigation state
    @Published var shouldSwitchToMyPage = false

    // Current user ID (simplified for MVP)
    private let anonymousUserId = UUID()

    var currentUserIdString: String {
        authManager.userId ?? anonymousUserId.uuidString
    }

    var currentUserId: UUID {
        if let uuid = UUID(uuidString: currentUserIdString) {
            return uuid
        }
        return deterministicUUID(from: currentUserIdString)
    }

    private func deterministicUUID(from string: String) -> UUID {
        let hash = SHA256.hash(data: Data(string.utf8))
        let bytes = Array(hash.prefix(16))
        guard bytes.count == 16 else {
            return anonymousUserId
        }
        let uuidTuple: uuid_t = (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        )
        return UUID(uuid: uuidTuple)
    }

    // MARK: - UserDefaults Keys
    private enum Keys {
        static let favorites = "favorites"
        static let folders = "folders"
        static let usageHistory = "usageHistory"
        static let userPrompts = "userPrompts"
        static let communityTemplates = "communityTemplates"
        static let templateLikes = "templateLikes"
        static let myTemplates = "myTemplates"
        static let templateUsageHistory = "templateUsageHistory"
        static let uploadedDefaultQuickPrompts = "uploadedDefaultQuickPrompts"
        static let communityQuickPromptsCache = "communityQuickPromptsCache"
        static let communityWorkflowsCache = "communityWorkflowsCache"
        static let communityImagePromptsCache = "communityImagePromptsCache"
    }

    // MARK: - Initialization
    init() {
        self.authManager = AuthManager()
        self.firestoreManager = FirestoreManager()
        loadInitialData()
        loadUserData()
    }

    // For testing with custom managers
    init(authManager: AuthManager, firestoreManager: FirestoreManager) {
        self.authManager = authManager
        self.firestoreManager = firestoreManager
        loadInitialData()
        loadUserData()
    }

    // MARK: - Initial Data Loading
    private func loadInitialData() {
        // カテゴリとタスクのマスタデータ
        categories = Category.initialCategories
        tasks = PromptTask.initialTasks

        // 初期プロンプトデータ
        prompts = InitialPrompts.generate(categories: categories, tasks: tasks)

        // 高度プロンプトを追加（先頭に配置）
        let advancedPrompts = AdvancedPrompts.generate(categories: categories, tasks: tasks)
        prompts.insert(contentsOf: advancedPrompts, at: 0)

        // コミュニティテンプレートのサンプルデータ
        communityTemplates = createSampleCommunityTemplates(categories: categories, tasks: tasks)
        popularTags = createSampleTags()

        // 画像プロンプトは Firebase / ユーザー投稿のみ使用
        imagePromptTemplates = []

        // ワークフローのサンプルデータ
        workflows = createSampleWorkflows()

        // クイックプロンプトのデフォルトデータ
        quickPrompts = QuickPrompt.defaultPrompts

        uploadDefaultQuickPromptsIfNeeded()
    }

    // MARK: - Sample Image Prompt Templates
    private func createSampleImagePromptTemplates() -> [ImagePromptTemplate] {
        return [
            ImagePromptTemplate(
                title: "深緑の自然テクスチャ",
                promptText: "Macro shot of lush green leaves in morning light, natural texture, depth of field, dew drops sparkling, soft bokeh background --ar 5:4 --style photorealistic",
                tags: ["自然", "テクスチャ", "植物"],
                sampleImageUrl: "https://images.unsplash.com/photo-1505764706515-aa95265c5abc?w=1200&h=675&fit=crop",
                fullImageUrl: "https://images.unsplash.com/photo-1505764706515-aa95265c5abc?w=1600&h=900&fit=crop",
                modelType: .midjourney,
                aspectRatio: .ultraWide,
                likeCount: 342,
                useCount: 1205,
                authorName: "cyber_artist"
            ),
            ImagePromptTemplate(
                title: "レッドロックの砂漠ハイウェイ",
                promptText: "Desert canyon road disappearing into dramatic red mountains, cinematic road trip composition, warm sunset tones, travel poster look --ar 16:9",
                tags: ["背景", "ロードトリップ", "砂漠"],
                sampleImageUrl: "https://images.unsplash.com/photo-1493612276216-ee3925520721?w=1400&h=700&fit=crop",
                fullImageUrl: "https://images.unsplash.com/photo-1493612276216-ee3925520721?w=2000&h=1000&fit=crop",
                modelType: .midjourney,
                aspectRatio: .wide,
                likeCount: 528,
                useCount: 2341,
                authorName: "anime_creator"
            ),
            ImagePromptTemplate(
                title: "夕陽に笑うフレンドショット",
                promptText: "Lifestyle photo of friends hugging on a hilltop during golden hour, sun flare, candid joy, travel memory vibe --ar 1:1",
                tags: ["人物", "ライフスタイル", "夕日"],
                sampleImageUrl: "https://images.unsplash.com/photo-1529333166437-7750a6dd5a70?w=1000&h=1000&fit=crop",
                fullImageUrl: "https://images.unsplash.com/photo-1529333166437-7750a6dd5a70?w=1400&h=1400&fit=crop",
                modelType: .dalle,
                aspectRatio: .square,
                likeCount: 189,
                useCount: 876,
                authorName: "logo_master"
            ),
            ImagePromptTemplate(
                title: "浮遊島のファンタジー峡谷",
                promptText: "Epic fantasy canyon with floating islands, cascading waterfalls into clouds, ancient ruins glowing with runes, golden hour rim light --ar 21:9",
                tags: ["ファンタジー", "風景", "アート"],
                sampleImageUrl: "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=1400&h=700&fit=crop",
                fullImageUrl: "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=2000&h=1000&fit=crop",
                modelType: .stableDiffusion,
                aspectRatio: .ultraWide,
                likeCount: 421,
                useCount: 1567,
                authorName: "fantasy_world"
            ),
            ImagePromptTemplate(
                title: "ガジェット系プロダクトレンダリング",
                promptText: "Product render of a matte black smartphone on acrylic blocks, soft studio lighting, subtle gradients, hero shot --ar 4:5",
                tags: ["プロダクト", "ガジェット", "広告"],
                sampleImageUrl: "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=900&h=1125&fit=crop",
                fullImageUrl: "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=1200&h=1500&fit=crop",
                modelType: .firefly,
                aspectRatio: .portrait,
                likeCount: 156,
                useCount: 543,
                authorName: "product_viz"
            ),
            ImagePromptTemplate(
                title: "流体インクの抽象アート",
                promptText: "Fluid ink abstract art, vibrant magenta and teal, marble pattern, macro photography look, high contrast --ar 3:2",
                tags: ["抽象", "アート", "テクスチャ"],
                sampleImageUrl: "https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=1200&h=800&fit=crop",
                fullImageUrl: "https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=1600&h=1067&fit=crop",
                modelType: .stableDiffusion,
                aspectRatio: .landscape,
                likeCount: 234,
                useCount: 678,
                authorName: "abstract_mind"
            ),
            ImagePromptTemplate(
                title: "北欧建築ビジュアライズ",
                promptText: "Scandinavian villa render, warm wooden facade, floor to ceiling windows, pine forest backdrop, sunset lighting --ar 16:9",
                tags: ["建築", "住宅", "ビジュアライズ"],
                sampleImageUrl: "https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=1500&h=844&fit=crop",
                fullImageUrl: "https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=1800&h=1013&fit=crop",
                modelType: .midjourney,
                aspectRatio: .wide,
                likeCount: 284,
                useCount: 931,
                authorName: "arch_render"
            ),
            ImagePromptTemplate(
                title: "ナチュラルカフェの宣材写真",
                promptText: "Lifestyle cafe photography, latte art on wooden table, dried flowers, sun-dappled morning light, film-like grain --ar 3:2",
                tags: ["ライフスタイル", "飲食", "宣材"],
                sampleImageUrl: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=1200&h=800&fit=crop",
                fullImageUrl: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=1600&h=1067&fit=crop",
                modelType: .dalle,
                aspectRatio: .landscape,
                likeCount: 201,
                useCount: 612,
                authorName: "latte_graphics"
            )
        ]
    }

    // MARK: - Sample Workflows
    private func createSampleWorkflows() -> [Workflow] {
        // ワークフロー1: ブログ記事作成
        let blog_step1Id = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        let blog_step2Id = UUID(uuidString: "11111111-1111-1111-1111-111111111112")!
        let blog_step3Id = UUID(uuidString: "11111111-1111-1111-1111-111111111113")!
        let blogWorkflowId = UUID(uuidString: "11111111-1111-1111-1111-111111111110")!

        // ワークフロー2: コードレビュー
        let code_step1Id = UUID(uuidString: "22222222-2222-2222-2222-222222222221")!
        let code_step2Id = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
        let codeWorkflowId = UUID(uuidString: "22222222-2222-2222-2222-222222222220")!

        // ワークフロー3: 企画書作成
        let plan_step1Id = UUID(uuidString: "33333333-3333-3333-3333-333333333331")!
        let plan_step2Id = UUID(uuidString: "33333333-3333-3333-3333-333333333332")!
        let plan_step3Id = UUID(uuidString: "33333333-3333-3333-3333-333333333333")!
        let planWorkflowId = UUID(uuidString: "33333333-3333-3333-3333-333333333330")!

        // ワークフロー4: 英語添削
        let eng_step1Id = UUID(uuidString: "44444444-4444-4444-4444-444444444441")!
        let eng_step2Id = UUID(uuidString: "44444444-4444-4444-4444-444444444442")!
        let engWorkflowId = UUID(uuidString: "44444444-4444-4444-4444-444444444440")!

        return [
            Workflow(
                id: blogWorkflowId,
                title: "ブログ記事作成ワークフロー",
                description: "トピックからアウトライン、本文、推敲まで段階的にブログ記事を作成します。SEO対策も含めた完成度の高い記事が作れます。",
                steps: [
                    WorkflowStep(
                        id: blog_step1Id,
                        name: "アウトライン作成",
                        description: "トピックから記事の骨格を生成",
                        promptTemplate: "以下のトピックについて、SEOを意識したブログ記事のアウトラインを作成してください。\n\nトピック: {トピック}\nターゲット読者: {ターゲット読者}\n\n以下の形式で出力してください:\n1. タイトル案（3つ）\n2. 導入部の概要\n3. 本文の見出し構成（H2, H3を含む）\n4. まとめの概要\n5. 想定される関連キーワード",
                        inputsSchema: [
                            WorkflowInputField(label: "トピック", placeholder: "例: SwiftUIでアプリ開発を始める方法", required: true),
                            WorkflowInputField(label: "ターゲット読者", placeholder: "例: プログラミング初心者", required: false)
                        ],
                        transitions: [
                            StepTransition(label: "次へ", nextStepId: blog_step2Id)
                        ]
                    ),
                    WorkflowStep(
                        id: blog_step2Id,
                        name: "本文執筆",
                        description: "アウトラインに基づいて本文を執筆",
                        promptTemplate: "以下のアウトラインに基づいて、各セクションの本文を執筆してください。\n\n- 各セクションは200-400字程度\n- 具体例やコード例を含める\n- 読みやすい文章で\n- 専門用語は初出時に説明を加える\n\nアウトライン:\n{outline}",
                        requireUserPaste: true,
                        transitions: [
                            StepTransition(label: "次へ", nextStepId: blog_step3Id)
                        ]
                    ),
                    WorkflowStep(
                        id: blog_step3Id,
                        name: "推敲・校正",
                        description: "文章を推敲し、品質を向上",
                        promptTemplate: "以下のブログ記事を推敲・校正してください。\n\nチェックポイント:\n- 誤字脱字\n- 文法的な誤り\n- 冗長な表現\n- 論理の流れ\n- SEO対策（キーワードの適切な配置）\n\n修正箇所は【修正前】→【修正後】の形式で示し、最後に改善版の全文を出力してください。\n\n記事:\n{draft}",
                        requireUserPaste: true
                    )
                ],
                tags: ["ライティング", "ブログ", "SEO"],
                likeCount: 156,
                useCount: 423,
                authorName: "content_pro"
            ),
            Workflow(
                id: codeWorkflowId,
                title: "コードレビュー & リファクタリング",
                description: "コードの問題点を分析し、段階的に改善提案を行います。パフォーマンス、可読性、保守性の観点から総合的にレビューします。",
                steps: [
                    WorkflowStep(
                        id: code_step1Id,
                        name: "初期分析",
                        description: "コードの問題点を洗い出す",
                        promptTemplate: "以下のコードを分析し、問題点を洗い出してください。\n\n言語/フレームワーク: {言語}\n\n分析観点:\n1. バグ・潜在的な問題\n2. パフォーマンスの問題\n3. 可読性の問題\n4. セキュリティの問題\n5. 設計上の問題\n\n重要度（高/中/低）と共に問題点をリストアップしてください。\n\nコード:\n{code}",
                        inputsSchema: [
                            WorkflowInputField(label: "言語", placeholder: "例: Swift, Python, JavaScript", required: true),
                            WorkflowInputField(label: "code", placeholder: "レビュー対象のコードを貼り付け", required: true)
                        ],
                        transitions: [
                            StepTransition(label: "次へ", nextStepId: code_step2Id)
                        ]
                    ),
                    WorkflowStep(
                        id: code_step2Id,
                        name: "リファクタリング提案",
                        description: "改善案と修正コードを生成",
                        promptTemplate: "前のステップで特定された問題点に基づいて、リファクタリング案を提示してください。\n\n各問題点について:\n1. 問題の説明\n2. 改善方法\n3. 修正後のコード\n\n最後に、すべての修正を適用した完全なコードを出力してください。\n\n分析結果:\n{result}",
                        requireUserPaste: true
                    )
                ],
                tags: ["コーディング", "レビュー", "品質"],
                likeCount: 234,
                useCount: 567,
                authorName: "code_quality"
            ),
            Workflow(
                id: planWorkflowId,
                title: "企画書作成ワークフロー",
                description: "アイデアから企画書の各セクションを段階的に作成します。背景分析、目的設定、実行計画まで網羅します。",
                steps: [
                    WorkflowStep(
                        id: plan_step1Id,
                        name: "背景・課題分析",
                        description: "企画の背景と解決すべき課題を整理",
                        promptTemplate: "以下の企画アイデアについて、背景と課題を分析してください。\n\n企画アイデア: {アイデア}\n対象業界/分野: {業界}\n\n以下の形式で出力:\n1. 現状の課題・問題点\n2. 市場/業界のトレンド\n3. ターゲットユーザーのペイン\n4. 既存ソリューションの限界\n5. この企画で解決できること",
                        inputsSchema: [
                            WorkflowInputField(label: "アイデア", placeholder: "例: 社内コミュニケーション活性化アプリ", required: true),
                            WorkflowInputField(label: "業界", placeholder: "例: 人事・HR、小売、製造", required: false)
                        ],
                        transitions: [
                            StepTransition(label: "次へ", nextStepId: plan_step2Id)
                        ]
                    ),
                    WorkflowStep(
                        id: plan_step2Id,
                        name: "企画概要作成",
                        description: "目的、ゴール、KPIを設定",
                        promptTemplate: "背景分析に基づいて、企画の概要を作成してください。\n\n以下の形式で出力:\n1. 企画タイトル（キャッチーなもの）\n2. 企画の目的（Why）\n3. 企画の概要（What）\n4. 期待される効果\n5. 成功指標（KPI）3-5個\n6. ターゲットユーザー詳細\n\n背景分析:\n{previous}",
                        requireUserPaste: true,
                        transitions: [
                            StepTransition(label: "次へ", nextStepId: plan_step3Id)
                        ]
                    ),
                    WorkflowStep(
                        id: plan_step3Id,
                        name: "実行計画作成",
                        description: "具体的なアクションプランを策定",
                        promptTemplate: "企画概要に基づいて、実行計画を作成してください。\n\n以下の形式で出力:\n1. フェーズ分け（準備/実行/評価）\n2. 各フェーズの主要タスク\n3. 必要なリソース（人員/予算/ツール）\n4. リスクと対策\n5. スケジュール概要\n6. 次のアクション（直近1週間）\n\n企画概要:\n{previous}",
                        requireUserPaste: true
                    )
                ],
                tags: ["ビジネス", "企画", "プランニング"],
                likeCount: 189,
                useCount: 412,
                authorName: "biz_planner"
            ),
            Workflow(
                id: engWorkflowId,
                title: "英語学習：文法添削ワークフロー",
                description: "英文を添削し、文法解説と改善版を提供します。ネイティブ表現への言い換えも学べます。",
                steps: [
                    WorkflowStep(
                        id: eng_step1Id,
                        name: "文法チェック",
                        description: "英文の文法をチェック",
                        promptTemplate: "以下の英文を文法的に添削してください。\n\n学習者のレベル: {レベル}\n\n英文:\n{英文}\n\n以下の形式で出力:\n1. 誤りのある箇所と正しい形\n2. なぜ誤りなのかの説明\n3. 関連する文法ルール\n4. 類似のよくある間違い例",
                        inputsSchema: [
                            WorkflowInputField(label: "レベル", placeholder: "例: 初級、中級、上級、TOEIC600点相当", required: false),
                            WorkflowInputField(label: "英文", placeholder: "添削してほしい英文を入力", required: true)
                        ],
                        transitions: [
                            StepTransition(label: "次へ", nextStepId: eng_step2Id)
                        ]
                    ),
                    WorkflowStep(
                        id: eng_step2Id,
                        name: "表現の改善",
                        description: "より自然な表現に改善",
                        promptTemplate: "文法添削の結果に基づいて、より自然でネイティブらしい表現に改善してください。\n\n以下の形式で出力:\n1. 改善版の英文\n2. 使用したイディオム/表現の解説\n3. フォーマル版とカジュアル版の両方\n4. シチュエーション別の言い換え例\n\n添削結果:\n{previous}",
                        requireUserPaste: true
                    )
                ],
                tags: ["学習", "英語", "文法"],
                likeCount: 312,
                useCount: 876,
                authorName: "english_tutor"
            )
        ]
    }

    // MARK: - User Data Persistence
    private func loadUserData() {
        // お気に入りの読み込み
        if let data = UserDefaults.standard.data(forKey: Keys.favorites),
           let decoded = try? JSONDecoder().decode([Favorite].self, from: data) {
            favorites = decoded
        }

        // フォルダの読み込み
        if let data = UserDefaults.standard.data(forKey: Keys.folders),
           let decoded = try? JSONDecoder().decode([Folder].self, from: data) {
            folders = decoded
        }

        // 使用履歴の読み込み
        if let data = UserDefaults.standard.data(forKey: Keys.usageHistory),
           let decoded = try? JSONDecoder().decode([UsageHistory].self, from: data) {
            usageHistory = decoded
        }

        // ユーザー作成プロンプトの読み込み
        if let data = UserDefaults.standard.data(forKey: Keys.userPrompts),
           let decoded = try? JSONDecoder().decode([Prompt].self, from: data) {
            prompts.append(contentsOf: decoded)
        }

        // マイテンプレートの読み込み
        if let data = UserDefaults.standard.data(forKey: Keys.myTemplates),
           let decoded = try? JSONDecoder().decode([MyTemplate].self, from: data) {
            myTemplates = decoded
        }

        // テンプレート使用履歴の読み込み
        if let data = UserDefaults.standard.data(forKey: Keys.templateUsageHistory),
           let decoded = try? JSONDecoder().decode([TemplateUsageHistory].self, from: data) {
            templateUsageHistory = decoded
        }

        if let data = UserDefaults.standard.data(forKey: Keys.communityQuickPromptsCache),
           let decoded = try? JSONDecoder().decode([QuickPrompt].self, from: data) {
            let sorted = decoded.sorted { $0.createdAt > $1.createdAt }
            for prompt in sorted {
                if !quickPrompts.contains(where: { $0.id == prompt.id }) {
                    quickPrompts.append(prompt)
                }
            }
        }

        if let data = UserDefaults.standard.data(forKey: Keys.communityWorkflowsCache),
           let decoded = try? JSONDecoder().decode([Workflow].self, from: data) {
            for workflow in decoded {
                if !workflows.contains(where: { $0.id == workflow.id }) {
                    workflows.append(workflow)
                }
            }
        }

        if let data = UserDefaults.standard.data(forKey: Keys.communityImagePromptsCache),
           let decoded = try? JSONDecoder().decode([ImagePromptTemplate].self, from: data) {
            for template in decoded where !template.authorId.isEmpty {
                if !imagePromptTemplates.contains(where: { $0.id == template.id }) {
                    imagePromptTemplates.append(template)
                }
            }
        }
    }

    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: Keys.favorites)
        }
    }

    private func saveFolders() {
        if let encoded = try? JSONEncoder().encode(folders) {
            UserDefaults.standard.set(encoded, forKey: Keys.folders)
        }
    }

    private func saveUsageHistory() {
        if let encoded = try? JSONEncoder().encode(usageHistory) {
            UserDefaults.standard.set(encoded, forKey: Keys.usageHistory)
        }
    }

    // MARK: - Category & Task Helpers
    func category(for id: UUID) -> Category? {
        categories.first { $0.id == id }
    }

    func task(for id: UUID) -> PromptTask? {
        tasks.first { $0.id == id }
    }

    func prompt(for id: UUID) -> Prompt? {
        prompts.first { $0.id == id }
    }

    // MARK: - Favorite Management
    func isFavorite(_ promptId: UUID) -> Bool {
        favorites.contains { $0.promptId == promptId }
    }

    func toggleFavorite(_ promptId: UUID) {
        if let index = favorites.firstIndex(where: { $0.promptId == promptId }) {
            favorites.remove(at: index)
        } else {
            let favorite = Favorite(promptId: promptId)
            favorites.append(favorite)
        }
        saveFavorites()
    }

    func addToFavorites(_ promptId: UUID, folderId: UUID? = nil) {
        guard !isFavorite(promptId) else { return }
        let favorite = Favorite(promptId: promptId, folderId: folderId)
        favorites.append(favorite)
        saveFavorites()
    }

    func removeFromFavorites(_ promptId: UUID) {
        favorites.removeAll { $0.promptId == promptId }
        saveFavorites()
    }

    // MARK: - Folder Management
    func createFolder(name: String) {
        let sortOrder = (folders.map { $0.sortOrder }.max() ?? 0) + 1
        let folder = Folder(name: name, sortOrder: sortOrder)
        folders.append(folder)
        saveFolders()
    }

    func deleteFolder(_ folderId: UUID) {
        folders.removeAll { $0.id == folderId }
        // フォルダ内のお気に入りのフォルダ参照を解除
        for i in favorites.indices {
            if favorites[i].folderId == folderId {
                favorites[i].folderId = nil
            }
        }
        saveFolders()
        saveFavorites()
    }

    // MARK: - Usage History Management
    func recordUsage(promptId: UUID, variables: [String: String] = [:]) {
        let history = UsageHistory(promptId: promptId, variablesJson: variables)
        usageHistory.insert(history, at: 0)

        // 最大100件に制限
        if usageHistory.count > 100 {
            usageHistory = Array(usageHistory.prefix(100))
        }

        saveUsageHistory()

        // プロンプトの使用回数を更新
        if let index = prompts.firstIndex(where: { $0.id == promptId }) {
            prompts[index].useCount += 1
        }
    }

    func recentHistory(limit: Int = 5) -> [UsageHistory] {
        Array(usageHistory.prefix(limit))
    }

    // MARK: - Search & Filter
    func searchPrompts(query: String) -> [Prompt] {
        guard !query.isEmpty else { return prompts }
        let lowercased = query.lowercased()
        return prompts.filter {
            $0.title.lowercased().contains(lowercased) ||
            $0.body.lowercased().contains(lowercased) ||
            ($0.description?.lowercased().contains(lowercased) ?? false)
        }
    }

    func filterPrompts(categoryId: UUID? = nil, taskId: UUID? = nil) -> [Prompt] {
        prompts.filter { prompt in
            let matchesCategory = categoryId == nil || prompt.categoryId == categoryId
            let matchesTask = taskId == nil || prompt.taskId == taskId
            return matchesCategory && matchesTask
        }
    }

    func sortedPrompts(_ prompts: [Prompt], by sortType: SortType) -> [Prompt] {
        switch sortType {
        case .popular:
            return prompts.sorted { $0.likeCount > $1.likeCount }
        case .newest:
            return prompts.sorted { $0.createdAt > $1.createdAt }
        case .mostUsed:
            return prompts.sorted { $0.useCount > $1.useCount }
        case .favoriteCount:
            return prompts.sorted { $0.favoriteCount > $1.favoriteCount }
        }
    }

    // MARK: - Favorite Prompts
    func favoritePrompts() -> [Prompt] {
        let favoriteIds = Set(favorites.map { $0.promptId })
        return prompts.filter { favoriteIds.contains($0.id) }
    }

    func favoritePrompts(in folderId: UUID?) -> [Prompt] {
        let folderFavorites = favorites.filter { $0.folderId == folderId }
        let favoriteIds = Set(folderFavorites.map { $0.promptId })
        return prompts.filter { favoriteIds.contains($0.id) }
    }

    // MARK: - Community Template Management

    func communityTemplate(for id: UUID) -> CommunityTemplate? {
        communityTemplates.first { $0.id == id }
    }

    func publishTemplate(
        title: String,
        body: String,
        description: String,
        categoryId: UUID,
        taskId: UUID,
        tags: [String],
        authorName: String
    ) {
        let template = CommunityTemplate(
            userId: currentUserId,
            title: title,
            body: body,
            description: description,
            categoryId: categoryId,
            taskId: taskId,
            tags: tags,
            authorName: authorName
        )
        communityTemplates.insert(template, at: 0)
        saveCommunityTemplates()
        uploadCommunityTemplateToFirestore(template)
    }

    private func saveCommunityTemplates() {
        if let encoded = try? JSONEncoder().encode(communityTemplates) {
            UserDefaults.standard.set(encoded, forKey: Keys.communityTemplates)
        }
    }

    private func saveTemplateLikes() {
        if let encoded = try? JSONEncoder().encode(templateLikes) {
            UserDefaults.standard.set(encoded, forKey: Keys.templateLikes)
        }
    }

    // MARK: - Like Management

    func isTemplateLiked(_ templateId: UUID) -> Bool {
        templateLikes.contains { $0.templateId == templateId && $0.userId == currentUserId }
    }

    func toggleTemplateLike(_ templateId: UUID) {
        if let index = templateLikes.firstIndex(where: { $0.templateId == templateId && $0.userId == currentUserId }) {
            templateLikes.remove(at: index)
            if let templateIndex = communityTemplates.firstIndex(where: { $0.id == templateId }) {
                communityTemplates[templateIndex].likeCount -= 1
            }
        } else {
            let like = TemplateLike(userId: currentUserId, templateId: templateId)
            templateLikes.append(like)
            if let templateIndex = communityTemplates.firstIndex(where: { $0.id == templateId }) {
                communityTemplates[templateIndex].likeCount += 1
            }
        }
        saveTemplateLikes()
        saveCommunityTemplates()
    }

    func deleteCommunityTemplate(_ templateId: UUID) async {
        guard let template = communityTemplates.first(where: { $0.id == templateId }),
              template.userId == currentUserId else {
            print("⚠️ Delete denied: current user does not own template \(templateId)")
            return
        }

        communityTemplates.removeAll { $0.id == templateId }
        saveCommunityTemplates()

        do {
            try await firestoreManager.deleteCommunityTemplate(
                templateId: templateId.uuidString,
                userId: currentUserIdString
            )
        } catch {
            print("❌ Failed to delete community template: \(error.localizedDescription)")
        }
    }

    // MARK: - Template Usage

    func recordTemplateUsage(_ templateId: UUID) {
        if let index = communityTemplates.firstIndex(where: { $0.id == templateId }) {
            communityTemplates[index].useCount += 1
            saveCommunityTemplates()
        }
    }

    // MARK: - Community Search & Filter

    func searchCommunityTemplates(query: String) -> [CommunityTemplate] {
        guard !query.isEmpty else { return communityTemplates }
        let lowercased = query.lowercased()
        return communityTemplates.filter {
            $0.title.lowercased().contains(lowercased) ||
            $0.description.lowercased().contains(lowercased) ||
            $0.tags.contains { $0.lowercased().contains(lowercased) } ||
            $0.authorName.lowercased().contains(lowercased)
        }
    }

    func filterCommunityTemplates(categoryId: UUID? = nil, tag: String? = nil) -> [CommunityTemplate] {
        communityTemplates.filter { template in
            let matchesCategory = categoryId == nil || template.categoryId == categoryId
            let matchesTag = tag == nil || template.tags.contains { $0 == tag }
            return matchesCategory && matchesTag && template.status == .published
        }
    }

    func sortedCommunityTemplates(_ templates: [CommunityTemplate], by sortType: CommunitySortType) -> [CommunityTemplate] {
        switch sortType {
        case .newest:
            return templates.sorted { $0.createdAt > $1.createdAt }
        case .popular:
            return templates.sorted { $0.likeCount > $1.likeCount }
        case .mostUsed:
            return templates.sorted { $0.useCount > $1.useCount }
        }
    }

    // MARK: - Save Template to Favorites

    func saveCommunityTemplateToFavorites(_ template: CommunityTemplate) {
        // CommunityTemplateをPromptに変換してお気に入りに追加
        let prompt = Prompt(
            id: template.id,
            title: template.title,
            body: template.body,
            description: template.description,
            categoryId: template.categoryId,
            taskId: template.taskId,
            authorName: template.authorName,
            likeCount: template.likeCount,
            favoriteCount: 0,
            useCount: template.useCount,
            createdAt: template.createdAt
        )

        if !prompts.contains(where: { $0.id == template.id }) {
            prompts.append(prompt)
        }

        addToFavorites(template.id)
    }

    // MARK: - My Template Management

    func myTemplate(for id: UUID) -> MyTemplate? {
        myTemplates.first { $0.id == id }
    }

    func createMyTemplate(
        title: String,
        body: String,
        description: String,
        categoryId: UUID,
        taskId: UUID,
        tags: [String] = [],
        variables: [TemplateVariable] = [],
        isPublic: Bool = false,
        folderId: UUID? = nil
    ) {
        let template = MyTemplate(
            title: title,
            body: body,
            description: description,
            categoryId: categoryId,
            taskId: taskId,
            tags: tags,
            variables: variables,
            isPublic: isPublic,
            folderId: folderId,
            sourceType: .custom
        )
        myTemplates.insert(template, at: 0)
        saveMyTemplates()
    }

    func updateMyTemplate(_ template: MyTemplate) {
        if let index = myTemplates.firstIndex(where: { $0.id == template.id }) {
            var updated = template
            updated.updatedAt = Date()
            myTemplates[index] = updated
            saveMyTemplates()
        }
    }

    func deleteMyTemplate(_ templateId: UUID) {
        myTemplates.removeAll { $0.id == templateId }
        saveMyTemplates()
    }

    func duplicateMyTemplate(_ template: MyTemplate) {
        let copy = MyTemplate(
            title: "\(template.title) コピー",
            body: template.body,
            description: template.description,
            categoryId: template.categoryId,
            taskId: template.taskId,
            tags: template.tags,
            variables: template.variables,
            isPublic: false,
            folderId: nil,
            originalTemplateId: template.originalTemplateId ?? template.id,
            sampleImageUrl: template.sampleImageUrl,
            fullImageUrl: template.fullImageUrl,
            sourceType: template.sourceType
        )
        myTemplates.insert(copy, at: 0)
        saveMyTemplates()
    }

    func duplicateCommunityTemplate(_ communityTemplate: CommunityTemplate) {
        let myTemplate = MyTemplate(
            title: communityTemplate.title,
            body: communityTemplate.body,
            description: communityTemplate.description,
            categoryId: communityTemplate.categoryId,
            taskId: communityTemplate.taskId,
            tags: communityTemplate.tags,
            variables: communityTemplate.templateVariables,
            isPublic: false,
            originalTemplateId: communityTemplate.id,
            sourceType: .workflow
        )
        myTemplates.insert(myTemplate, at: 0)
        saveMyTemplates()
        shouldSwitchToMyPage = true
    }

    func publishMyTemplate(_ templateId: UUID, authorName: String) {
        guard let template = myTemplate(for: templateId) else { return }

        let communityTemplate = CommunityTemplate(
            userId: currentUserId,
            originalPromptId: template.id,
            title: template.title,
            body: template.body,
            description: template.description,
            categoryId: template.categoryId,
            taskId: template.taskId,
            tags: template.tags,
            templateVariables: template.variables,
            authorName: authorName
        )
        communityTemplates.insert(communityTemplate, at: 0)
        saveCommunityTemplates()
        uploadCommunityTemplateToFirestore(communityTemplate)

        // マイテンプレを公開状態に更新
        if let index = myTemplates.firstIndex(where: { $0.id == templateId }) {
            myTemplates[index].isPublic = true
            saveMyTemplates()
        }
    }

    func recordMyTemplateUsage(_ templateId: UUID, variableValues: [String: String] = [:]) {
        let history = TemplateUsageHistory(
            templateId: templateId,
            variableValues: variableValues
        )
        templateUsageHistory.insert(history, at: 0)

        // 最大100件に制限
        if templateUsageHistory.count > 100 {
            templateUsageHistory = Array(templateUsageHistory.prefix(100))
        }

        saveTemplateUsageHistory()
    }

    private func saveMyTemplates() {
        if let encoded = try? JSONEncoder().encode(myTemplates) {
            UserDefaults.standard.set(encoded, forKey: Keys.myTemplates)
        }
    }

    private func saveTemplateUsageHistory() {
        if let encoded = try? JSONEncoder().encode(templateUsageHistory) {
            UserDefaults.standard.set(encoded, forKey: Keys.templateUsageHistory)
        }
    }

    private func saveCommunityQuickPromptsCache() {
        let customPrompts = quickPrompts.filter { !$0.isDefault }
        if let encoded = try? JSONEncoder().encode(customPrompts) {
            UserDefaults.standard.set(encoded, forKey: Keys.communityQuickPromptsCache)
        }
    }

    private func saveCommunityWorkflowsCache() {
        if let encoded = try? JSONEncoder().encode(workflows) {
            UserDefaults.standard.set(encoded, forKey: Keys.communityWorkflowsCache)
        }
    }

    private func saveCommunityImagePromptsCache() {
        let customTemplates = imagePromptTemplates.filter { !$0.authorId.isEmpty }
        if let encoded = try? JSONEncoder().encode(customTemplates) {
            UserDefaults.standard.set(encoded, forKey: Keys.communityImagePromptsCache)
        }
    }

    private func uploadCommunityTemplateToFirestore(_ template: CommunityTemplate) {
        Task {
            guard await ensureFirebaseAuthentication() else {
                print("⚠️ Skipping community template upload because user is not authenticated")
                return
            }
            do {
                try await firestoreManager.saveCommunityTemplate(template)
            } catch {
                print("❌ Failed to upload community template: \(error.localizedDescription)")
            }
        }
    }

    private func uploadQuickPromptToFirestore(_ prompt: QuickPrompt, userIdOverride: String? = nil) {
        Task {
            guard await ensureFirebaseAuthentication() else {
                print("⚠️ Skipping quick prompt upload because user is not authenticated")
                return
            }
            do {
                let userId = userIdOverride ?? currentUserIdString
                try await firestoreManager.saveQuickPrompt(prompt, userId: userId)
            } catch {
                print("❌ Failed to upload quick prompt: \(error.localizedDescription)")
            }
        }
    }

    private func uploadDefaultQuickPromptsIfNeeded() {
        let flag = UserDefaults.standard.bool(forKey: Keys.uploadedDefaultQuickPrompts)
        guard !flag else { return }

        Task {
            guard await ensureFirebaseAuthentication() else {
                print("⚠️ Skipping default quick prompt seeding because user is not authenticated")
                return
            }
            for prompt in quickPrompts where prompt.isDefault {
                do {
                    let userId = prompt.userId ?? (authManager.userId ?? "system")
                    try await firestoreManager.saveQuickPrompt(prompt, userId: userId)
                } catch {
                    print("❌ Failed to seed quick prompt: \(error.localizedDescription)")
                }
            }
            UserDefaults.standard.set(true, forKey: Keys.uploadedDefaultQuickPrompts)
        }
    }

    private func ensureFirebaseAuthentication() async -> Bool {
        if authManager.userId != nil {
            return true
        }
        do {
            try await authManager.signInAnonymously()
            return authManager.userId != nil
        } catch {
            print("❌ Failed to authenticate anonymously: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Quick Prompt Management

    func publishQuickPrompt(
        title: String,
        description: String,
        promptText: String,
        category: QuickCategory,
        tags: [String],
        authorName: String,
        usageDescription: String,
        prerequisites: String,
        expectedOutput: String,
        ngExamples: String
    ) {
        var prompt = QuickPrompt(
            title: title,
            description: description,
            promptText: promptText,
            category: category,
            isDefault: false,
            useCount: 0,
            likeCount: 0,
            usageDescription: usageDescription,
            prerequisites: prerequisites,
            expectedOutput: expectedOutput,
            ngExamples: ngExamples
        )
        prompt.userId = currentUserIdString
        prompt.updatedAt = Date()
        quickPrompts.insert(prompt, at: 0)
        uploadQuickPromptToFirestore(prompt)
        saveCommunityQuickPromptsCache()
    }

    func isQuickPromptLiked(_ promptId: UUID) -> Bool {
        quickPromptLikes.contains { $0.promptId == promptId.uuidString && $0.userId == currentUserIdString }
    }

    func toggleQuickPromptLike(_ promptId: UUID) {
        if let index = quickPromptLikes.firstIndex(where: { $0.promptId == promptId.uuidString && $0.userId == currentUserIdString }) {
            quickPromptLikes.remove(at: index)
            if let promptIndex = quickPrompts.firstIndex(where: { $0.id == promptId }) {
                quickPrompts[promptIndex].likeCount -= 1
            }
        } else {
            let like = QuickPromptLike(userId: currentUserIdString, promptId: promptId.uuidString)
            quickPromptLikes.append(like)
            if let promptIndex = quickPrompts.firstIndex(where: { $0.id == promptId }) {
                quickPrompts[promptIndex].likeCount += 1
            }
        }
    }

    func recordQuickPromptUsage(_ promptId: UUID) {
        if let index = quickPrompts.firstIndex(where: { $0.id == promptId }) {
            quickPrompts[index].useCount += 1
            saveCommunityQuickPromptsCache()
        }
    }

    func saveQuickPrompt(_ prompt: QuickPrompt) {
        // QuickPromptをMyTemplateとして保存
        let myTemplate = MyTemplate(
            title: prompt.title,
            body: prompt.promptText,
            description: prompt.description,
            categoryId: categories.first?.id ?? UUID(),
            taskId: tasks.first?.id ?? UUID(),
            tags: [prompt.category.rawValue],
            variables: extractVariables(from: prompt.promptText),
            isPublic: false,
            originalTemplateId: prompt.id,
            sourceType: .quick
        )
        myTemplates.insert(myTemplate, at: 0)
        saveMyTemplates()
    }

    func deleteQuickPrompt(_ promptId: UUID) {
        savedQuickPrompts.removeAll { $0.id == promptId }
    }

    func duplicateQuickPrompt(_ prompt: QuickPrompt) {
        let copy = QuickPrompt(
            title: "\(prompt.title) コピー",
            description: prompt.description,
            promptText: prompt.promptText,
            category: prompt.category,
            isDefault: false,
            useCount: prompt.useCount
        )
        savedQuickPrompts.insert(copy, at: 0)
    }

    private func extractVariables(from text: String) -> [TemplateVariable] {
        guard let regex = try? NSRegularExpression(pattern: "\\{([^}]+)\\}") else {
            return []
        }
        let nsText = text as NSString
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))

        var seen = Set<String>()
        var variables: [TemplateVariable] = []

        for match in matches {
            if match.numberOfRanges > 1 {
                let range = match.range(at: 1)
                let name = nsText.substring(with: range)
                if !seen.contains(name) {
                    seen.insert(name)
                    let variable = TemplateVariable(
                        variableName: name,
                        label: name,
                        placeholder: name,
                        order: variables.count
                    )
                    variables.append(variable)
                }
            }
        }

        return variables
    }

    // MARK: - Image Prompt Management

    func isImagePromptLiked(_ templateId: UUID) -> Bool {
        imagePromptLikes.contains { $0.templateId == templateId.uuidString && $0.userId == currentUserIdString }
    }

    func toggleImagePromptLike(_ templateId: UUID) {
        if let index = imagePromptLikes.firstIndex(where: { $0.templateId == templateId.uuidString && $0.userId == currentUserIdString }) {
            imagePromptLikes.remove(at: index)
            if let templateIndex = imagePromptTemplates.firstIndex(where: { $0.id == templateId }) {
                imagePromptTemplates[templateIndex].likeCount -= 1
            }
        } else {
            let like = ImagePromptLike(userId: currentUserIdString, templateId: templateId.uuidString)
            imagePromptLikes.append(like)
            if let templateIndex = imagePromptTemplates.firstIndex(where: { $0.id == templateId }) {
                imagePromptTemplates[templateIndex].likeCount += 1
            }
        }
    }

    func recordImagePromptUsage(_ templateId: UUID) {
        if let index = imagePromptTemplates.firstIndex(where: { $0.id == templateId }) {
            imagePromptTemplates[index].useCount += 1
        }
    }

    func deleteImagePromptTemplate(_ templateId: UUID) {
        imagePromptTemplates.removeAll { $0.id == templateId && $0.authorId == currentUserIdString }
    }

    func duplicateImagePromptLocally(_ template: ImagePromptTemplate) {
        let copy = ImagePromptTemplate(
            title: "\(template.title) コピー",
            promptText: template.promptText,
            tags: template.tags,
            sampleImageUrl: template.sampleImageUrl,
            fullImageUrl: template.fullImageUrl,
            modelType: template.modelType,
            aspectRatio: template.aspectRatio,
            likeCount: template.likeCount,
            useCount: template.useCount,
            authorId: currentUserIdString,
            authorName: template.authorName
        )
        imagePromptTemplates.insert(copy, at: 0)
    }

    func duplicateImagePromptTemplate(_ template: ImagePromptTemplate) {
        // 画像プロンプトをMyTemplateとして保存
        let myTemplate = MyTemplate(
            title: template.title,
            body: template.promptText,
            description: "モデル: \(template.modelType.rawValue) / アスペクト比: \(template.aspectRatio.rawValue)",
            categoryId: categories.first?.id ?? UUID(),
            taskId: tasks.first?.id ?? UUID(),
            tags: template.tags,
            variables: [],
            isPublic: false,
            originalTemplateId: template.id,
            sampleImageUrl: template.sampleImageUrl,
            fullImageUrl: template.fullImageUrl,
            sourceType: .picture
        )
        myTemplates.insert(myTemplate, at: 0)
        saveMyTemplates()
    }

    // MARK: - Workflow Management

    func isWorkflowLiked(_ workflowId: UUID) -> Bool {
        workflowLikes.contains { $0.workflowId == workflowId.uuidString && $0.userId == currentUserIdString }
    }

    func toggleWorkflowLike(_ workflowId: UUID) {
        if let index = workflowLikes.firstIndex(where: { $0.workflowId == workflowId.uuidString && $0.userId == currentUserIdString }) {
            workflowLikes.remove(at: index)
            if let wfIndex = workflows.firstIndex(where: { $0.id == workflowId }) {
                workflows[wfIndex].likeCount -= 1
            }
        } else {
            let like = WorkflowLike(userId: currentUserIdString, workflowId: workflowId.uuidString)
            workflowLikes.append(like)
            if let wfIndex = workflows.firstIndex(where: { $0.id == workflowId }) {
                workflows[wfIndex].likeCount += 1
            }
        }
    }

    func deleteWorkflow(_ workflowId: UUID) {
        workflows.removeAll { $0.id == workflowId && $0.authorId == currentUserIdString }
    }

    func duplicateWorkflow(_ workflow: Workflow) {
        // ワークフローのステップ情報を説明文に含める
        let stepsDescription = workflow.steps.enumerated().map { index, step in
            "ステップ\(index + 1): \(step.name)"
        }.joined(separator: "\n")

        let myTemplate = MyTemplate(
            title: workflow.title,
            body: stepsDescription,
            description: workflow.description,
            categoryId: categories.first?.id ?? UUID(),
            taskId: tasks.first?.id ?? UUID(),
            tags: workflow.tags,
            variables: [],
            isPublic: false,
            originalTemplateId: workflow.id,
            sourceType: .workflow
        )
        myTemplates.insert(myTemplate, at: 0)
        saveMyTemplates()
    }

    func recordWorkflowUsage(_ workflowId: UUID) {
        if let index = workflows.firstIndex(where: { $0.id == workflowId }) {
            workflows[index].useCount += 1
        }
    }

    // MARK: - Template Type Detection

    func getTemplateSourceType(_ template: MyTemplate) -> TemplateSourceType {
        if let storedType = template.sourceType {
            return storedType
        }

        guard let originalId = template.originalTemplateId else {
            return .custom
        }

        // QuickPromptから保存されたかチェック
        if quickPrompts.contains(where: { $0.id == originalId }) {
            return .quick
        }

        // Workflowから保存されたかチェック
        if workflows.contains(where: { $0.id == originalId }) {
            return .workflow
        }

        // ImagePromptから保存されたかチェック
        if imagePromptTemplates.contains(where: { $0.id == originalId }) {
            return .picture
        }

        return .custom
    }

    // MARK: - Firebase Integration for MyTemplate

    /// テンプレートを保存（Firebase + ローカル）
    func saveMyTemplate(_ template: MyTemplate) async throws {
        // ローカルに保存
        if let index = myTemplates.firstIndex(where: { $0.id == template.id }) {
            myTemplates[index] = template
        } else {
            myTemplates.append(template)
        }
        saveMyTemplates()

        // Firebaseに保存（認証済みの場合のみ）
        if authManager.isAuthenticated, let userId = authManager.userId {
            try await firestoreManager.saveTemplate(template, userId: userId)
        }
    }

    /// テンプレートを更新（Firebase + ローカル）
    func updateMyTemplateWithFirebase(_ template: MyTemplate) async throws {
        // ローカルを更新
        if let index = myTemplates.firstIndex(where: { $0.id == template.id }) {
            var updated = template
            updated.updatedAt = Date()
            myTemplates[index] = updated
            saveMyTemplates()

            // Firebaseを更新（認証済みの場合のみ）
            if authManager.isAuthenticated, let userId = authManager.userId {
                try await firestoreManager.updateTemplate(updated, userId: userId)
            }
        }
    }

    /// テンプレートを削除（Firebase + ローカル）
    func deleteMyTemplateWithFirebase(_ templateId: UUID) async throws {
        // ローカルから削除
        guard let template = myTemplates.first(where: { $0.id == templateId }) else { return }
        myTemplates.removeAll { $0.id == templateId }
        saveMyTemplates()

        // Firebaseから削除（認証済みの場合のみ）
        if authManager.isAuthenticated, let userId = authManager.userId {
            try await firestoreManager.deleteTemplate(template, userId: userId)
        }
    }

    /// テンプレートをフォーク（Firestoreから自分のコレクションにコピー）
    func forkTemplate(_ template: MyTemplate) async throws {
        guard authManager.isAuthenticated, let userId = authManager.userId else {
            throw NSError(domain: "PromptStore", code: -1, userInfo: [NSLocalizedDescriptionKey: "ログインが必要です"])
        }

        // Firestoreでフォーク
        let forkedTemplate = try await firestoreManager.forkTemplate(template, userId: userId)

        // ローカルに追加
        myTemplates.append(forkedTemplate)
        saveMyTemplates()

        // 画面をマイページに切り替え
        shouldSwitchToMyPage = true
    }

    /// ユーザーのテンプレートをFirestoreから読み込み
    func loadUserTemplatesFromFirebase() async throws {
        guard authManager.isAuthenticated, let userId = authManager.userId else { return }

        let templates = try await firestoreManager.fetchUserTemplates(userId: userId)

        // ローカルとマージ（重複を避ける）
        for template in templates {
            if !myTemplates.contains(where: { $0.id == template.id }) {
                myTemplates.append(template)
            }
        }

        saveMyTemplates()
    }

    /// 公開テンプレートを検索
    func searchPublicTemplates(query: String) async throws -> [MyTemplate] {
        return try await firestoreManager.searchPublicTemplates(query: query)
    }

    /// タグで公開テンプレートを検索
    func fetchTemplatesByTag(_ tag: String) async throws -> [MyTemplate] {
        return try await firestoreManager.fetchTemplatesByTag(tag)
    }

    // MARK: - Community Quick Prompts Integration

    /// コミュニティクイックプロンプトを読み込み
    func loadCommunityQuickPrompts() async throws {
        let prompts = try await firestoreManager.fetchCommunityQuickPrompts()

        // 既存のユーザー投稿（非デフォルト）を一旦クリア
        quickPrompts.removeAll { !$0.isDefault }

        // 新しい投稿を作成日時順で配置
        let sortedPrompts = prompts.sorted { $0.createdAt > $1.createdAt }
        quickPrompts.append(contentsOf: sortedPrompts)
        saveCommunityQuickPromptsCache()
    }

    /// クイックプロンプトをコミュニティに保存
    func saveQuickPromptToCommunity(_ prompt: QuickPrompt) async throws {
        guard authManager.isAuthenticated, let userId = authManager.userId else {
            throw NSError(domain: "PromptStore", code: -1, userInfo: [NSLocalizedDescriptionKey: "ログインが必要です"])
        }

        try await firestoreManager.saveQuickPrompt(prompt, userId: userId)

        // ローカルリストにも追加
        if !quickPrompts.contains(where: { $0.id == prompt.id }) {
            quickPrompts.append(prompt)
        }
    }

    /// カテゴリ別クイックプロンプトを読み込み
    func loadQuickPromptsByCategory(_ category: QuickCategory) async throws -> [QuickPrompt] {
        return try await firestoreManager.fetchQuickPromptsByCategory(category)
    }

    /// クイックプロンプトのいいねをトグル（Firestore連携）
    func toggleQuickPromptLikeWithFirebase(_ promptId: UUID) async throws {
        guard authManager.isAuthenticated, let userId = authManager.userId else {
            // ローカルのみで処理
            toggleQuickPromptLike(promptId)
            return
        }

        let isLiked = try await firestoreManager.toggleQuickPromptLike(
            promptId: promptId.uuidString,
            userId: userId
        )

        // ローカル状態を更新
        if isLiked {
            let like = QuickPromptLike(userId: userId, promptId: promptId.uuidString)
            quickPromptLikes.append(like)
            if let index = quickPrompts.firstIndex(where: { $0.id == promptId }) {
                quickPrompts[index].likeCount += 1
            }
        } else {
            quickPromptLikes.removeAll { $0.promptId == promptId.uuidString && $0.userId == userId }
            if let index = quickPrompts.firstIndex(where: { $0.id == promptId }) {
                quickPrompts[index].likeCount -= 1
            }
        }
    }

    // MARK: - Community Workflows Integration

    /// コミュニティワークフローを読み込み
    func loadCommunityWorkflows() async throws {
        let newWorkflows = try await firestoreManager.fetchCommunityWorkflows()

        // ローカルデータとマージ（サンプルワークフローは維持）
        for workflow in newWorkflows {
            if !workflows.contains(where: { $0.id == workflow.id }) {
                workflows.append(workflow)
            }
        }
        saveCommunityWorkflowsCache()
    }

    /// ワークフローをコミュニティに保存
    func saveWorkflowToCommunity(_ workflow: Workflow) async throws {
        guard authManager.isAuthenticated, let userId = authManager.userId else {
            throw NSError(domain: "PromptStore", code: -1, userInfo: [NSLocalizedDescriptionKey: "ログインが必要です"])
        }

        try await firestoreManager.saveWorkflow(workflow, userId: userId)

        // ローカルリストにも追加
        if !workflows.contains(where: { $0.id == workflow.id }) {
            workflows.append(workflow)
        }
        saveCommunityWorkflowsCache()
    }

    /// タグ別ワークフローを読み込み
    func loadWorkflowsByTag(_ tag: String) async throws -> [Workflow] {
        return try await firestoreManager.fetchWorkflowsByTag(tag)
    }

    /// ワークフローのいいねをトグル（Firestore連携）
    func toggleWorkflowLikeWithFirebase(_ workflowId: UUID) async throws {
        guard authManager.isAuthenticated, let userId = authManager.userId else {
            // ローカルのみで処理
            toggleWorkflowLike(workflowId)
            return
        }

        let isLiked = try await firestoreManager.toggleWorkflowLike(
            workflowId: workflowId.uuidString,
            userId: userId
        )

        // ローカル状態を更新
        if isLiked {
            let like = WorkflowLike(userId: userId, workflowId: workflowId.uuidString)
            workflowLikes.append(like)
            if let index = workflows.firstIndex(where: { $0.id == workflowId }) {
                workflows[index].likeCount += 1
            }
        } else {
            workflowLikes.removeAll { $0.workflowId == workflowId.uuidString && $0.userId == userId }
            if let index = workflows.firstIndex(where: { $0.id == workflowId }) {
                workflows[index].likeCount -= 1
            }
        }
    }

    // MARK: - Community Image Prompts Integration

    /// コミュニティ画像プロンプトを読み込み
    func loadCommunityImagePrompts() async throws {
        let newPrompts = try await firestoreManager.fetchCommunityImagePrompts()

        // ローカルデータとマージ（サンプルは維持）
        for prompt in newPrompts {
            if !imagePromptTemplates.contains(where: { $0.id == prompt.id }) {
                imagePromptTemplates.append(prompt)
            }
        }
        saveCommunityImagePromptsCache()
    }

    /// 画像プロンプトをコミュニティに保存
    func saveImagePromptToCommunity(_ prompt: ImagePromptTemplate) async throws {
        guard authManager.isAuthenticated, let userId = authManager.userId else {
            throw NSError(domain: "PromptStore", code: -1, userInfo: [NSLocalizedDescriptionKey: "ログインが必要です"])
        }

        try await firestoreManager.saveImagePrompt(prompt, userId: userId)

        // ローカルリストにも追加
        if !imagePromptTemplates.contains(where: { $0.id == prompt.id }) {
            imagePromptTemplates.append(prompt)
        }
        saveCommunityImagePromptsCache()
    }

    /// モデルタイプ別画像プロンプトを読み込み
    func loadImagePromptsByModel(_ modelType: ImageModelType) async throws -> [ImagePromptTemplate] {
        return try await firestoreManager.fetchImagePromptsByModel(modelType)
    }

    /// タグ別画像プロンプトを読み込み
    func loadImagePromptsByTag(_ tag: String) async throws -> [ImagePromptTemplate] {
        return try await firestoreManager.fetchImagePromptsByTag(tag)
    }

    /// 画像プロンプトのいいねをトグル（Firestore連携）
    func toggleImagePromptLikeWithFirebase(_ promptId: UUID) async throws {
        guard authManager.isAuthenticated, let userId = authManager.userId else {
            // ローカルのみで処理
            toggleImagePromptLike(promptId)
            return
        }

        let isLiked = try await firestoreManager.toggleImagePromptLike(
            promptId: promptId.uuidString,
            userId: userId
        )

        // ローカル状態を更新
        if isLiked {
            let like = ImagePromptLike(userId: userId, templateId: promptId.uuidString)
            imagePromptLikes.append(like)
            if let index = imagePromptTemplates.firstIndex(where: { $0.id == promptId }) {
                imagePromptTemplates[index].likeCount += 1
            }
        } else {
            imagePromptLikes.removeAll { $0.templateId == promptId.uuidString && $0.userId == userId }
            if let index = imagePromptTemplates.firstIndex(where: { $0.id == promptId }) {
                imagePromptTemplates[index].likeCount -= 1
            }
        }
    }
}

// MARK: - Template Source Type
enum TemplateSourceType: String, Codable {
    case quick
    case workflow
    case picture
    case custom
}

// MARK: - Sort Type
enum SortType: String, CaseIterable {
    case popular = "人気順"
    case newest = "新着順"
    case mostUsed = "使用回数順"
    case favoriteCount = "お気に入り数順"
}
