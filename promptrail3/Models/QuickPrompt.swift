//
//  QuickPrompt.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/20.
//

import SwiftUI
import FirebaseFirestore

// MARK: - Quick Category
enum QuickCategory: String, CaseIterable, Codable {
    case writing = "文章"
    case idea = "アイデア"
    case task = "タスク"
    case imageGen = "画像生成"
    case business = "ビジネス"
    case life = "生活"
    case entertainment = "エンタメ"
    case learning = "学習"
    case health = "健康"
    case creative = "クリエイティブ"

    var icon: String {
        switch self {
        case .writing: return "doc.text"
        case .idea: return "lightbulb"
        case .task: return "checklist"
        case .imageGen: return "photo.on.rectangle"
        case .business: return "briefcase"
        case .life: return "house"
        case .entertainment: return "tv"
        case .learning: return "book"
        case .health: return "heart"
        case .creative: return "paintbrush"
        }
    }

    var color: Color {
        switch self {
        case .writing: return .prCategoryBlue
        case .idea: return .prCategoryAmber
        case .task: return .prCategoryGreen
        case .imageGen: return .prCategoryPurple
        case .business: return Color(red: 0.2, green: 0.4, blue: 0.8)
        case .life: return Color(red: 0.3, green: 0.7, blue: 0.5)
        case .entertainment: return Color(red: 0.9, green: 0.3, blue: 0.5)
        case .learning: return Color(red: 0.5, green: 0.5, blue: 0.9)
        case .health: return Color(red: 0.9, green: 0.4, blue: 0.4)
        case .creative: return Color(red: 0.7, green: 0.3, blue: 0.9)
        }
    }
}

// MARK: - Quick Prompt
struct QuickPrompt: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let description: String
    let promptText: String
    let category: QuickCategory
    let isDefault: Bool
    var useCount: Int
    var likeCount: Int
    let createdAt: Date
    var updatedAt: Date
    var userId: String? // ユーザーが作成したプロンプトの場合に設定

    // 詳細説明項目
    var usageDescription: String // 用途
    var prerequisites: String // 前提
    var expectedOutput: String // 期待出力
    var ngExamples: String // NG例

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: QuickPrompt, rhs: QuickPrompt) -> Bool {
        lhs.id == rhs.id
    }

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        promptText: String,
        category: QuickCategory,
        isDefault: Bool = false,
        useCount: Int = 0,
        likeCount: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        userId: String? = nil,
        usageDescription: String = "",
        prerequisites: String = "",
        expectedOutput: String = "",
        ngExamples: String = ""
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.promptText = promptText
        self.category = category
        self.isDefault = isDefault
        self.useCount = useCount
        self.likeCount = likeCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.userId = userId
        self.usageDescription = usageDescription
        self.prerequisites = prerequisites
        self.expectedOutput = expectedOutput
        self.ngExamples = ngExamples
    }

    // MARK: - Firestore Support

    enum CodingKeys: String, CodingKey {
        case id, title, description, promptText, category, isDefault
        case useCount, likeCount, createdAt, updatedAt, userId
        case usageDescription, prerequisites, expectedOutput, ngExamples
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // IDをStringからUUIDに変換
        if let idString = try? container.decode(String.self, forKey: .id) {
            self.id = UUID(uuidString: idString) ?? UUID()
        } else {
            self.id = try container.decode(UUID.self, forKey: .id)
        }

        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.promptText = try container.decode(String.self, forKey: .promptText)
        self.category = try container.decode(QuickCategory.self, forKey: .category)
        self.isDefault = try container.decode(Bool.self, forKey: .isDefault)
        self.useCount = try container.decode(Int.self, forKey: .useCount)
        self.likeCount = try container.decode(Int.self, forKey: .likeCount)

        // DateをTimestampから変換
        if let timestamp = try? container.decode(Timestamp.self, forKey: .createdAt) {
            self.createdAt = timestamp.dateValue()
        } else {
            self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        }

        if let timestamp = try? container.decode(Timestamp.self, forKey: .updatedAt) {
            self.updatedAt = timestamp.dateValue()
        } else {
            self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        }

        self.userId = try? container.decode(String.self, forKey: .userId)

        // 詳細説明項目（オプショナル、既存データ対応）
        self.usageDescription = (try? container.decode(String.self, forKey: .usageDescription)) ?? ""
        self.prerequisites = (try? container.decode(String.self, forKey: .prerequisites)) ?? ""
        self.expectedOutput = (try? container.decode(String.self, forKey: .expectedOutput)) ?? ""
        self.ngExamples = (try? container.decode(String.self, forKey: .ngExamples)) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // UUIDをStringに変換
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(promptText, forKey: .promptText)
        try container.encode(category, forKey: .category)
        try container.encode(isDefault, forKey: .isDefault)
        try container.encode(useCount, forKey: .useCount)
        try container.encode(likeCount, forKey: .likeCount)

        // DateをTimestampに変換
        try container.encode(Timestamp(date: createdAt), forKey: .createdAt)
        try container.encode(Timestamp(date: updatedAt), forKey: .updatedAt)

        if let userId = userId {
            try container.encode(userId, forKey: .userId)
        }

        // 詳細説明項目
        try container.encode(usageDescription, forKey: .usageDescription)
        try container.encode(prerequisites, forKey: .prerequisites)
        try container.encode(expectedOutput, forKey: .expectedOutput)
        try container.encode(ngExamples, forKey: .ngExamples)
    }

    // Firestore用のDictionary変換
    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "id": id.uuidString,
            "title": title,
            "description": description,
            "promptText": promptText,
            "category": category.rawValue,
            "isDefault": isDefault,
            "useCount": useCount,
            "likeCount": likeCount,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt)
        ]

        if let userId = userId {
            data["userId"] = userId
        }

        // 詳細説明項目
        data["usageDescription"] = usageDescription
        data["prerequisites"] = prerequisites
        data["expectedOutput"] = expectedOutput
        data["ngExamples"] = ngExamples

        return data
    }

    static func fromFirestoreData(_ data: [String: Any]) -> QuickPrompt? {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString),
              let title = data["title"] as? String,
              let description = data["description"] as? String,
              let promptText = data["promptText"] as? String,
              let categoryString = data["category"] as? String,
              let category = QuickCategory(rawValue: categoryString),
              let isDefault = data["isDefault"] as? Bool,
              let useCount = data["useCount"] as? Int,
              let likeCount = data["likeCount"] as? Int,
              let createdAtTimestamp = data["createdAt"] as? Timestamp,
              let updatedAtTimestamp = data["updatedAt"] as? Timestamp
        else {
            return nil
        }

        let userId = data["userId"] as? String

        // 詳細説明項目（オプショナル、既存データ対応）
        let usageDescription = data["usageDescription"] as? String ?? ""
        let prerequisites = data["prerequisites"] as? String ?? ""
        let expectedOutput = data["expectedOutput"] as? String ?? ""
        let ngExamples = data["ngExamples"] as? String ?? ""

        return QuickPrompt(
            id: id,
            title: title,
            description: description,
            promptText: promptText,
            category: category,
            isDefault: isDefault,
            useCount: useCount,
            likeCount: likeCount,
            createdAt: createdAtTimestamp.dateValue(),
            updatedAt: updatedAtTimestamp.dateValue(),
            userId: userId,
            usageDescription: usageDescription,
            prerequisites: prerequisites,
            expectedOutput: expectedOutput,
            ngExamples: ngExamples
        )
    }
}

// MARK: - Quick Prompt Like
struct QuickPromptLike: Identifiable, Codable {
    let id: UUID
    let userId: String
    let promptId: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        userId: String,
        promptId: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.promptId = promptId
        self.createdAt = createdAt
    }

    // MARK: - Firestore Support

    enum CodingKeys: String, CodingKey {
        case id, userId, promptId, createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let idString = try? container.decode(String.self, forKey: .id) {
            self.id = UUID(uuidString: idString) ?? UUID()
        } else {
            self.id = try container.decode(UUID.self, forKey: .id)
        }

        self.userId = try container.decode(String.self, forKey: .userId)
        self.promptId = try container.decode(String.self, forKey: .promptId)

        if let timestamp = try? container.decode(Timestamp.self, forKey: .createdAt) {
            self.createdAt = timestamp.dateValue()
        } else {
            self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id.uuidString, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(promptId, forKey: .promptId)
        try container.encode(Timestamp(date: createdAt), forKey: .createdAt)
    }

    func toFirestoreData() -> [String: Any] {
        return [
            "id": id.uuidString,
            "userId": userId,
            "promptId": promptId,
            "createdAt": Timestamp(date: createdAt)
        ]
    }

    static func fromFirestoreData(_ data: [String: Any]) -> QuickPromptLike? {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString),
              let userId = data["userId"] as? String,
              let promptId = data["promptId"] as? String,
              let createdAtTimestamp = data["createdAt"] as? Timestamp
        else {
            return nil
        }

        return QuickPromptLike(
            id: id,
            userId: userId,
            promptId: promptId,
            createdAt: createdAtTimestamp.dateValue()
        )
    }
}

// MARK: - Sample Data
extension QuickPrompt {
    static let defaultPrompts: [QuickPrompt] = [
        // 文章カテゴリ（3個）
        QuickPrompt(
            title: "文章の要約と構造化",
            description: "長文を整理して要点を抽出",
            promptText: "以下の文章を読み、主要な論点を3つのポイントにまとめ、それぞれに見出しと詳細説明を付けて構造化してください：\n\n{text}",
            category: .writing,
            isDefault: true,
            useCount: 412,
            usageDescription: "会議の議事録、長いメール、記事など、情報量が多い文章を素早く理解したいときに使用します。重要なポイントだけを抽出して整理できます。",
            prerequisites: "要約したい元の文章が必要です。可能であれば1000文字以上の長文が適しています。",
            expectedOutput: "3つの主要論点が見出しと詳細説明でまとめられた構造化された要約文。各ポイントは箇条書きで明確に示されます。",
            ngExamples: "極端に短い文章（数行程度）や、既に箇条書きになっている文章には不向きです。また、専門用語が多すぎる場合は事前に用語説明を追加してください。"
        ),
        QuickPrompt(
            title: "ビジネスメール作成",
            description: "状況に応じた丁寧な文面を生成",
            promptText: "以下の情報をもとに、適切なトーンでビジネスメールを作成してください。\n\n【相手】：{recipient}\n【目的】：{purpose}\n【伝えたい内容】：{content}\n【希望するトーン】：{tone}（例：丁寧、カジュアル、緊急）",
            category: .writing,
            isDefault: true,
            useCount: 387,
            usageDescription: "取引先へのお礼、依頼、謝罪、報告など、様々なビジネスシーンでのメール作成に活用できます。",
            prerequisites: "送信相手の立場、メールの目的、伝えたい内容の概要を事前に整理しておいてください。",
            expectedOutput: "件名、本文（挨拶・本題・結び）がビジネスマナーに沿って構成された丁寧なメール文面。",
            ngExamples: "カジュアルすぎる表現を避けたい場合は、トーンを「丁寧」に指定してください。また、機密情報や個人情報は含めないでください。"
        ),
        QuickPrompt(
            title: "文章の推敲と改善",
            description: "表現・論理・構成を総合的にブラッシュアップ",
            promptText: "以下の文章について、①誤字脱字、②論理の飛躍、③冗長な表現、④わかりにくい箇所を指摘し、改善案と理由をセットで提示してください：\n\n{text}",
            category: .writing,
            isDefault: true,
            useCount: 298,
            usageDescription: "ブログ記事、プレゼン資料、報告書など、公開前や提出前の文章をより洗練させたいときに使用します。",
            prerequisites: "推敲したい文章の初稿が必要です。完成度が高すぎると改善点が見つかりにくい場合があります。",
            expectedOutput: "誤字脱字の指摘、論理展開の改善提案、冗長表現の削減案、わかりにくい箇所の書き直し案が具体的な理由とともに提示されます。",
            ngExamples: "詩や小説など、意図的に曖昧な表現を使っている文章には適していません。また、専門用語の正確性チェックには不向きです。"
        ),

        // アイデアカテゴリ（2個）
        QuickPrompt(
            title: "多角的アイデア発想",
            description: "異なる視点から創造的な案を生成",
            promptText: "{topic}について、以下の異なる視点からそれぞれ2つずつアイデアを出してください：\n1. 既存の常識を疑う視点\n2. テクノロジーを活用する視点\n3. ユーザー体験を重視する視点\n4. コスト削減の視点\n5. 社会的インパクトの視点",
            category: .idea,
            isDefault: true,
            useCount: 356
        ),
        QuickPrompt(
            title: "企画の骨子設計",
            description: "目的から逆算した実行可能な企画を構築",
            promptText: "{project}の企画書を作成します。以下を明確に記載してください：\n\n1. 背景と課題認識\n2. 企画の目的（定量的な目標含む）\n3. ターゲット層の詳細\n4. 実施施策（3〜5個）\n5. 想定スケジュールとマイルストーン\n6. 必要リソースと予算概算\n7. 成功指標（KPI）",
            category: .idea,
            isDefault: true,
            useCount: 289
        ),

        // タスクカテゴリ（3個）
        QuickPrompt(
            title: "タスクの優先順位マトリクス",
            description: "緊急度×重要度で分類し実行順を提案",
            promptText: "以下のタスクを「緊急度」と「重要度」の2軸で評価し、4象限のマトリクスに分類してください。その上で、実行すべき順番と各タスクへの推奨アプローチを提示してください：\n\n{tasks}",
            category: .task,
            isDefault: true,
            useCount: 401
        ),
        QuickPrompt(
            title: "逆算式プロジェクト計画",
            description: "ゴールから逆算してマイルストーンを設定",
            promptText: "【最終ゴール】：{goal}\n【期限】：{deadline}\n【制約条件】：{constraints}\n\nこの情報をもとに、期限から逆算したプロジェクト計画を作成してください。各フェーズに必要な成果物、担当領域、リスクと対策も含めてください。",
            category: .task,
            isDefault: true,
            useCount: 312
        ),
        QuickPrompt(
            title: "効果的な会議設計",
            description: "目的達成型の議題とタイムテーブルを作成",
            promptText: "【会議の目的】：{meeting_purpose}\n【参加者】：{participants}\n【所要時間】：{duration}\n\n上記をもとに、①明確なゴール設定、②議題とタイムテーブル、③各議題の進行方法、④会議前の準備事項、⑤会議後のアクションアイテムを含む会議設計を提案してください。",
            category: .task,
            isDefault: true,
            useCount: 267
        ),

        // 画像生成カテゴリ（2個）
        QuickPrompt(
            title: "プロダクト撮影風プロンプト",
            description: "商業利用可能な高品質商品画像",
            promptText: "{product}, professional product photography, clean white background, studio lighting setup with softbox, sharp focus, high resolution 8K, commercial photography style, centered composition, subtle shadows, photorealistic",
            category: .imageGen,
            isDefault: true,
            useCount: 478
        ),
        QuickPrompt(
            title: "コンセプトアート生成",
            description: "世界観を表現する雰囲気重視のビジュアル",
            promptText: "{concept_description}, concept art, {art_style} style, dramatic lighting, rich color palette, atmospheric perspective, highly detailed, professional illustration, trending on ArtStation, 4K quality",
            category: .imageGen,
            isDefault: true,
            useCount: 423
        ),

        // ビジネスカテゴリ（5個）
        QuickPrompt(
            title: "会議アジェンダ作成",
            description: "目的に沿った効率的な会議プランを設計",
            promptText: "以下の会議について、効果的なアジェンダを作成してください：\n\n【会議名】：{meeting_name}\n【目的】：{purpose}\n【参加者】：{participants}\n【時間】：{duration}\n\n各議題に時間配分と期待されるアウトプットを明記してください。",
            category: .business,
            isDefault: true,
            useCount: 345
        ),
        QuickPrompt(
            title: "SWOT分析フレームワーク",
            description: "事業・製品の強み弱み機会脅威を整理",
            promptText: "{subject}についてSWOT分析を実施してください。\n\n強み(Strengths)、弱み(Weaknesses)、機会(Opportunities)、脅威(Threats)をそれぞれ3〜5項目ずつリストアップし、そこから導かれる戦略的示唆を3つ提示してください。",
            category: .business,
            isDefault: true,
            useCount: 298
        ),
        QuickPrompt(
            title: "プレゼン資料の構成案",
            description: "聴衆を引き込むストーリー展開を設計",
            promptText: "以下のテーマでプレゼン資料を作成します。効果的なスライド構成を提案してください：\n\n【テーマ】：{theme}\n【対象】：{audience}\n【時間】：{duration}分\n【目的】：{goal}\n\n各スライドのタイトルとキーメッセージ、ビジュアルの提案を含めてください。",
            category: .business,
            isDefault: true,
            useCount: 412
        ),
        QuickPrompt(
            title: "営業トークスクリプト",
            description: "顧客の課題に刺さる提案の流れを構築",
            promptText: "以下の製品・サービスの営業トークスクリプトを作成してください：\n\n【製品/サービス】：{product}\n【ターゲット顧客】：{target}\n【主な課題】：{pain_point}\n【解決価値】：{value}\n\nオープニング、課題の共感、解決策の提示、クロージングの流れで構成してください。",
            category: .business,
            isDefault: true,
            useCount: 267
        ),
        QuickPrompt(
            title: "KPI設定とモニタリング計画",
            description: "目標達成のための測定可能な指標を設計",
            promptText: "{project}のKPI設定を支援してください。\n\n1. 最終目標とそれを測る主要指標（KGI）\n2. 中間指標となるKPI（3〜5個）\n3. 各指標の測定方法と頻度\n4. 目標値と警戒ライン\n5. アクションプラン\n\nを明確にしてください。",
            category: .business,
            isDefault: true,
            useCount: 189
        ),

        // 生活カテゴリ（5個）
        QuickPrompt(
            title: "献立プランニング",
            description: "栄養バランスを考慮した1週間の食事計画",
            promptText: "以下の条件で1週間の献立を作成してください：\n\n【人数】：{people}人\n【予算】：週{budget}円程度\n【制約】：{constraints}（例：アレルギー、嫌いな食材）\n【目標】：{goal}（例：タンパク質強化、減塩）\n\n買い物リストも含めて提案してください。",
            category: .life,
            isDefault: true,
            useCount: 523
        ),
        QuickPrompt(
            title: "家計簿分析と節約提案",
            description: "支出パターンから改善ポイントを発見",
            promptText: "以下の月間支出データを分析し、節約できそうなポイントと具体的な改善策を3つ提案してください：\n\n{expense_data}\n\n【手取り収入】：{income}円\n【目標貯蓄額】：{saving_goal}円/月",
            category: .life,
            isDefault: true,
            useCount: 387
        ),
        QuickPrompt(
            title: "引っ越しチェックリスト",
            description: "漏れのない段階的な引っ越し準備計画",
            promptText: "{date}に引っ越し予定です。以下の情報をもとに、時系列のチェックリストを作成してください：\n\n【現住所】：{current}\n【新住所】：{new}\n【家族構成】：{family}\n【特記事項】：{notes}\n\n1ヶ月前、2週間前、1週間前、前日、当日、翌日以降に分けて整理してください。",
            category: .life,
            isDefault: true,
            useCount: 234
        ),
        QuickPrompt(
            title: "整理収納プラン",
            description: "スペースを最大活用する収納アイデア",
            promptText: "{space}の整理収納プランを提案してください。\n\n【現状の課題】：{problem}\n【収納したいもの】：{items}\n【予算】：{budget}円程度\n\n具体的な収納グッズの提案、配置図、実行ステップを含めてください。",
            category: .life,
            isDefault: true,
            useCount: 312
        ),
        QuickPrompt(
            title: "旅行プラン作成",
            description: "効率的で楽しい旅程を最適化",
            promptText: "以下の条件で旅行プランを作成してください：\n\n【行き先】：{destination}\n【期間】：{duration}\n【人数・構成】：{travelers}\n【予算】：{budget}円\n【興味】：{interests}\n\n日別の行程、おすすめスポット、予算配分、持ち物リストを含めてください。",
            category: .life,
            isDefault: true,
            useCount: 456
        ),

        // エンタメカテゴリ（4個）
        QuickPrompt(
            title: "映画レビュー作成",
            description: "ネタバレ配慮した説得力のある評価",
            promptText: "映画「{movie_title}」のレビューを書いてください。\n\n1. 総合評価（5点満点）\n2. あらすじ（ネタバレなし）\n3. 見どころポイント（3つ）\n4. おすすめできる人・できない人\n5. 印象的なシーンや演出\n\nネタバレは明記して分けてください。",
            category: .entertainment,
            isDefault: true,
            useCount: 289
        ),
        QuickPrompt(
            title: "推し活プラン",
            description: "推しをもっと楽しむための企画アイデア",
            promptText: "{subject}の推し活をもっと充実させたいです。以下の切り口でアイデアを提案してください：\n\n1. 日常的に楽しめる活動（3つ）\n2. SNSでの発信ネタ（3つ）\n3. イベント・コラボの楽しみ方\n4. グッズ収集・整理のアイデア\n5. 同じ推しの人と繋がる方法",
            category: .entertainment,
            isDefault: true,
            useCount: 412
        ),
        QuickPrompt(
            title: "ゲーム攻略アドバイス",
            description: "効率的なプレイ戦略と攻略のコツ",
            promptText: "ゲーム「{game_title}」について、以下の攻略アドバイスをください：\n\n【現在の状況】：{current_state}\n【目標】：{goal}\n【困っていること】：{problem}\n\n効率的な攻略手順、おすすめの装備・スキル、注意点を具体的に教えてください。",
            category: .entertainment,
            isDefault: true,
            useCount: 367
        ),
        QuickPrompt(
            title: "創作ストーリープロット",
            description: "キャラと世界観から展開するストーリー骨格",
            promptText: "以下の設定で物語のプロットを作成してください：\n\n【ジャンル】：{genre}\n【主人公】：{protagonist}\n【世界観】：{setting}\n【テーマ】：{theme}\n\n起承転結の構成で、主要な転換点と見せ場を3つずつ含めてください。",
            category: .entertainment,
            isDefault: true,
            useCount: 445
        ),

        // 学習カテゴリ（4個）
        QuickPrompt(
            title: "学習計画表作成",
            description: "目標から逆算した実現可能な学習スケジュール",
            promptText: "以下の目標達成のための学習計画を作成してください：\n\n【目標】：{goal}\n【期限】：{deadline}\n【現在のレベル】：{current_level}\n【1日の学習時間】：{daily_hours}時間\n\n週単位の学習内容、マイルストーン、チェックポイントを含めてください。",
            category: .learning,
            isDefault: true,
            useCount: 398
        ),
        QuickPrompt(
            title: "概念の簡単説明",
            description: "難しい内容を初心者にわかりやすく解説",
            promptText: "{concept}について、{target_audience}にもわかるように説明してください。\n\n1. 一言でいうと何か\n2. なぜ重要なのか\n3. 具体例を使った解説\n4. よくある誤解\n5. 理解を深めるための次のステップ\n\n専門用語は避け、身近な例えを使ってください。",
            category: .learning,
            isDefault: true,
            useCount: 512
        ),
        QuickPrompt(
            title: "試験対策問題作成",
            description: "理解度チェックと弱点発見のための練習問題",
            promptText: "{subject}の試験対策として、以下の形式で問題を作成してください：\n\n【範囲】：{scope}\n【難易度】：{difficulty}\n【問題数】：{count}問\n\n問題、選択肢（該当する場合）、解答、解説をセットで提供してください。",
            category: .learning,
            isDefault: true,
            useCount: 334
        ),
        QuickPrompt(
            title: "読書ノート作成",
            description: "本の内容を定着させる構造的メモ",
            promptText: "本「{book_title}」の読書ノートを作成してください：\n\n1. 本の概要（3行程度）\n2. 最も重要な学び（3つ）\n3. 具体的なアクションプラン（3つ）\n4. 印象的な引用（3つ）\n5. 関連して読みたい本\n\n実生活にどう活かすかを重視してください。",
            category: .learning,
            isDefault: true,
            useCount: 267
        ),

        // 健康カテゴリ（4個）
        QuickPrompt(
            title: "運動メニュー作成",
            description: "目的と体力に合わせたトレーニングプラン",
            promptText: "以下の条件でトレーニングメニューを作成してください：\n\n【目的】：{goal}（例：ダイエット、筋力アップ、体力維持）\n【運動経験】：{experience}\n【利用できる環境】：{environment}（例：自宅、ジム）\n【1回の時間】：{duration}分\n【週の頻度】：週{frequency}回\n\n具体的な種目、回数、セット数、注意点を含めてください。",
            category: .health,
            isDefault: true,
            useCount: 456
        ),
        QuickPrompt(
            title: "睡眠改善アドバイス",
            description: "質の高い睡眠のための生活習慣改善案",
            promptText: "睡眠の質を改善したいです。以下の現状から改善案を提案してください：\n\n【現在の睡眠時間】：{sleep_hours}時間\n【就寝時刻】：{bedtime}\n【起床時刻】：{wake_time}\n【睡眠の悩み】：{problems}\n【生活パターン】：{lifestyle}\n\n段階的に実行できる具体的な改善策を5つ提案してください。",
            category: .health,
            isDefault: true,
            useCount: 389
        ),
        QuickPrompt(
            title: "ストレス対処法リスト",
            description: "シーン別のセルフケア方法を整理",
            promptText: "以下の状況でのストレス対処法を、すぐできるもの・時間をかけるもの・長期的なものに分けて提案してください：\n\n【ストレス要因】：{stressor}\n【性格傾向】：{personality}\n【利用可能な時間】：{available_time}\n\n心理的アプローチ、身体的アプローチ、環境調整の3つの観点から提案してください。",
            category: .health,
            isDefault: true,
            useCount: 423
        ),
        QuickPrompt(
            title: "健康診断結果の解釈",
            description: "検査数値から生活改善ポイントを理解",
            promptText: "以下の健康診断結果について、わかりやすく解説してください：\n\n{health_check_data}\n\n1. 各数値の意味と基準値との比較\n2. 注意すべきポイント（3つ）\n3. 生活習慣で改善できること\n4. 専門医への相談が推奨される項目\n\n※医療的判断は医師の診察を受けるよう促してください。",
            category: .health,
            isDefault: true,
            useCount: 301
        ),

        // クリエイティブカテゴリ（4個）
        QuickPrompt(
            title: "SNS投稿文案作成",
            description: "目的に応じた魅力的なSNS投稿テキスト",
            promptText: "以下の条件でSNS投稿文を作成してください：\n\n【プラットフォーム】：{platform}（例：Twitter、Instagram、LinkedIn）\n【目的】：{purpose}（例：認知拡大、エンゲージメント、販売促進）\n【伝えたい内容】：{content}\n【ターゲット】：{target}\n【トーン】：{tone}\n\nハッシュタグの提案も含めてください。",
            category: .creative,
            isDefault: true,
            useCount: 534
        ),
        QuickPrompt(
            title: "キャッチコピー生成",
            description: "商品・サービスの魅力を凝縮した一言",
            promptText: "{product}のキャッチコピーを10案作成してください。\n\n【ターゲット】：{target}\n【訴求ポイント】：{selling_point}\n【トーン】：{tone}（例：力強い、親しみやすい、高級感）\n\n各案について、どのような心理的効果を狙っているか簡単に説明してください。",
            category: .creative,
            isDefault: true,
            useCount: 467
        ),
        QuickPrompt(
            title: "ブランディング戦略",
            description: "一貫性のあるブランドイメージ構築",
            promptText: "{brand}のブランディング戦略を設計してください。\n\n【現状】：{current_state}\n【目指すイメージ】：{desired_image}\n【ターゲット層】：{target}\n\n1. ブランドアイデンティティ（コンセプト、パーソナリティ）\n2. ビジュアルの方向性（色、フォント、デザインテイスト）\n3. コミュニケーショントーン\n4. タッチポイント別の表現方法\n5. 実施ロードマップ",
            category: .creative,
            isDefault: true,
            useCount: 298
        ),
        QuickPrompt(
            title: "動画コンテンツ企画",
            description: "視聴者を引き込む構成と演出アイデア",
            promptText: "以下の条件で動画コンテンツの企画を作成してください：\n\n【プラットフォーム】：{platform}（例：YouTube、TikTok、Instagram Reels）\n【テーマ】：{theme}\n【長さ】：{duration}\n【ターゲット】：{target}\n\n1. タイトル案（3つ）\n2. サムネイルのアイデア\n3. 台本の流れ（導入・本編・まとめ）\n4. 視聴維持のための工夫\n5. CTA（行動喚起）",
            category: .creative,
            isDefault: true,
            useCount: 412
        )
    ]
}
