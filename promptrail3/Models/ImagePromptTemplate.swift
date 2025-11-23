//
//  ImagePromptTemplate.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import Foundation
import FirebaseFirestore

// MARK: - Image Prompt Template
struct ImagePromptTemplate: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var promptText: String
    var tags: [String]
    var sampleImageUrl: String
    var fullImageUrl: String
    var modelType: ImageModelType
    var aspectRatio: AspectRatio
    var likeCount: Int
    var useCount: Int
    let createdAt: Date
    var authorId: String
    var authorName: String

    init(
        id: UUID = UUID(),
        title: String,
        promptText: String,
        tags: [String] = [],
        sampleImageUrl: String,
        fullImageUrl: String,
        modelType: ImageModelType = .midjourney,
        aspectRatio: AspectRatio = .square,
        likeCount: Int = 0,
        useCount: Int = 0,
        createdAt: Date = Date(),
        authorId: String = "",
        authorName: String = ""
    ) {
        self.id = id
        self.title = title
        self.promptText = promptText
        self.tags = tags
        self.sampleImageUrl = sampleImageUrl
        self.fullImageUrl = fullImageUrl
        self.modelType = modelType
        self.aspectRatio = aspectRatio
        self.likeCount = likeCount
        self.useCount = useCount
        self.createdAt = createdAt
        self.authorId = authorId
        self.authorName = authorName
    }

    static func == (lhs: ImagePromptTemplate, rhs: ImagePromptTemplate) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // MARK: - Firestore Support

    enum CodingKeys: String, CodingKey {
        case id, title, promptText, tags, sampleImageUrl, fullImageUrl
        case modelType, aspectRatio, likeCount, useCount, createdAt, authorId, authorName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let idString = try? container.decode(String.self, forKey: .id) {
            self.id = UUID(uuidString: idString) ?? UUID()
        } else {
            self.id = try container.decode(UUID.self, forKey: .id)
        }

        self.title = try container.decode(String.self, forKey: .title)
        self.promptText = try container.decode(String.self, forKey: .promptText)
        self.tags = try container.decode([String].self, forKey: .tags)
        self.sampleImageUrl = try container.decode(String.self, forKey: .sampleImageUrl)
        self.fullImageUrl = try container.decode(String.self, forKey: .fullImageUrl)
        self.modelType = try container.decode(ImageModelType.self, forKey: .modelType)
        self.aspectRatio = try container.decode(AspectRatio.self, forKey: .aspectRatio)
        self.likeCount = try container.decode(Int.self, forKey: .likeCount)
        self.useCount = try container.decode(Int.self, forKey: .useCount)

        if let timestamp = try? container.decode(Timestamp.self, forKey: .createdAt) {
            self.createdAt = timestamp.dateValue()
        } else {
            self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        }

        self.authorId = try container.decode(String.self, forKey: .authorId)
        self.authorName = try container.decode(String.self, forKey: .authorName)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id.uuidString, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(promptText, forKey: .promptText)
        try container.encode(tags, forKey: .tags)
        try container.encode(sampleImageUrl, forKey: .sampleImageUrl)
        try container.encode(fullImageUrl, forKey: .fullImageUrl)
        try container.encode(modelType, forKey: .modelType)
        try container.encode(aspectRatio, forKey: .aspectRatio)
        try container.encode(likeCount, forKey: .likeCount)
        try container.encode(useCount, forKey: .useCount)
        try container.encode(Timestamp(date: createdAt), forKey: .createdAt)
        try container.encode(authorId, forKey: .authorId)
        try container.encode(authorName, forKey: .authorName)
    }

    func toFirestoreData() -> [String: Any] {
        return [
            "id": id.uuidString,
            "title": title,
            "promptText": promptText,
            "tags": tags,
            "sampleImageUrl": sampleImageUrl,
            "fullImageUrl": fullImageUrl,
            "modelType": modelType.rawValue,
            "aspectRatio": aspectRatio.rawValue,
            "likeCount": likeCount,
            "useCount": useCount,
            "createdAt": Timestamp(date: createdAt),
            "authorId": authorId,
            "authorName": authorName
        ]
    }

    static func fromFirestoreData(_ data: [String: Any]) -> ImagePromptTemplate? {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString),
              let title = data["title"] as? String,
              let promptText = data["promptText"] as? String,
              let tags = data["tags"] as? [String],
              let sampleImageUrl = data["sampleImageUrl"] as? String,
              let fullImageUrl = data["fullImageUrl"] as? String,
              let modelTypeString = data["modelType"] as? String,
              let modelType = ImageModelType(rawValue: modelTypeString),
              let aspectRatioString = data["aspectRatio"] as? String,
              let aspectRatio = AspectRatio(rawValue: aspectRatioString),
              let likeCount = data["likeCount"] as? Int,
              let useCount = data["useCount"] as? Int,
              let createdAtTimestamp = data["createdAt"] as? Timestamp,
              let authorId = data["authorId"] as? String,
              let authorName = data["authorName"] as? String
        else {
            return nil
        }

        return ImagePromptTemplate(
            id: id,
            title: title,
            promptText: promptText,
            tags: tags,
            sampleImageUrl: sampleImageUrl,
            fullImageUrl: fullImageUrl,
            modelType: modelType,
            aspectRatio: aspectRatio,
            likeCount: likeCount,
            useCount: useCount,
            createdAt: createdAtTimestamp.dateValue(),
            authorId: authorId,
            authorName: authorName
        )
    }
}

// MARK: - Image Model Type
enum ImageModelType: String, Codable, CaseIterable {
    case midjourney = "Midjourney"
    case dalle = "DALL-E"
    case stableDiffusion = "Stable Diffusion"
    case firefly = "Adobe Firefly"
    case gemini = "Gemini"
    case other = "その他"
}

// MARK: - Aspect Ratio
enum AspectRatio: String, Codable, CaseIterable {
    case square = "1:1"
    case portrait = "2:3"
    case landscape = "3:2"
    case wide = "16:9"
    case ultraWide = "21:9"

    var displayName: String {
        switch self {
        case .square: return "正方形 (1:1)"
        case .portrait: return "縦長 (2:3)"
        case .landscape: return "横長 (3:2)"
        case .wide: return "ワイド (16:9)"
        case .ultraWide: return "ウルトラワイド (21:9)"
        }
    }
}

// MARK: - Image Prompt Like
struct ImagePromptLike: Identifiable, Codable {
    let id: UUID
    let userId: String
    let templateId: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        userId: String,
        templateId: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.templateId = templateId
        self.createdAt = createdAt
    }

    // MARK: - Firestore Support

    enum CodingKeys: String, CodingKey {
        case id, userId, templateId, createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let idString = try? container.decode(String.self, forKey: .id) {
            self.id = UUID(uuidString: idString) ?? UUID()
        } else {
            self.id = try container.decode(UUID.self, forKey: .id)
        }

        self.userId = try container.decode(String.self, forKey: .userId)
        self.templateId = try container.decode(String.self, forKey: .templateId)

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
        try container.encode(templateId, forKey: .templateId)
        try container.encode(Timestamp(date: createdAt), forKey: .createdAt)
    }

    func toFirestoreData() -> [String: Any] {
        return [
            "id": id.uuidString,
            "userId": userId,
            "templateId": templateId,
            "createdAt": Timestamp(date: createdAt)
        ]
    }

    static func fromFirestoreData(_ data: [String: Any]) -> ImagePromptLike? {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString),
              let userId = data["userId"] as? String,
              let templateId = data["templateId"] as? String,
              let createdAtTimestamp = data["createdAt"] as? Timestamp
        else {
            return nil
        }

        return ImagePromptLike(
            id: id,
            userId: userId,
            templateId: templateId,
            createdAt: createdAtTimestamp.dateValue()
        )
    }
}

// MARK: - Image Tag
enum ImageTag: String, CaseIterable {
    case portrait = "人物"
    case landscape = "風景"
    case product = "プロダクト"
    case architecture = "建築"
    case fashion = "ファッション"
    case food = "フード"
    case technology = "テクノロジー"
    case fantasy = "ファンタジー"
    case animal = "動物"
    case nature = "自然"
    case travel = "トラベル"
    case uiux = "UIデザイン"
    case logo = "ロゴ"
    case abstract = "抽象"
    case anime = "アニメ"
    case game = "ゲーム"
    case space = "宇宙"
    case minimal = "ミニマル"
    case cyberpunk = "サイバーパンク"
}
