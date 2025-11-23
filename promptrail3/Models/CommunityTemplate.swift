//
//  CommunityTemplate.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import Foundation
import FirebaseFirestore

// MARK: - Community Template
struct CommunityTemplate: Identifiable, Codable, Hashable {
    static func == (lhs: CommunityTemplate, rhs: CommunityTemplate) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id: UUID
    let userId: UUID
    let originalPromptId: UUID?
    var title: String
    var body: String
    var description: String
    var categoryId: UUID
    var taskId: UUID
    var tags: [String]
    var templateVariables: [TemplateVariable]  // 変数定義
    var status: TemplateStatus
    var likeCount: Int
    var useCount: Int
    let createdAt: Date
    var updatedAt: Date
    var publishedAt: Date?

    // 投稿者情報（denormalized for display）
    var authorName: String

    init(
        id: UUID = UUID(),
        userId: UUID,
        originalPromptId: UUID? = nil,
        title: String,
        body: String,
        description: String,
        categoryId: UUID,
        taskId: UUID,
        tags: [String] = [],
        templateVariables: [TemplateVariable] = [],
        status: TemplateStatus = .published,
        likeCount: Int = 0,
        useCount: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        publishedAt: Date? = Date(),
        authorName: String
    ) {
        self.id = id
        self.userId = userId
        self.originalPromptId = originalPromptId
        self.title = title
        self.body = body
        self.description = description
        self.categoryId = categoryId
        self.taskId = taskId
        self.tags = tags
        self.templateVariables = templateVariables
        self.status = status
        self.likeCount = likeCount
        self.useCount = useCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.publishedAt = publishedAt
        self.authorName = authorName
    }

    // 変数抽出
    var variables: [String] {
        let pattern = "\\{([^}]+)\\}"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(body.startIndex..., in: body)
        let matches = regex.matches(in: body, range: range)

        var results: [String] = []
        for match in matches {
            if let range = Range(match.range(at: 1), in: body) {
                let variable = String(body[range])
                if !results.contains(variable) {
                    results.append(variable)
                }
            }
        }
        return results
    }

    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "id": id.uuidString,
            "userId": userId.uuidString,
            "title": title,
            "body": body,
            "description": description,
            "categoryId": categoryId.uuidString,
            "taskId": taskId.uuidString,
            "tags": tags,
            "templateVariables": templateVariables.map { $0.toFirestoreData() },
            "status": status.rawValue,
            "likeCount": likeCount,
            "useCount": useCount,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt),
            "authorName": authorName
        ]

        if let originalPromptId = originalPromptId {
            data["originalPromptId"] = originalPromptId.uuidString
        }
        if let publishedAt = publishedAt {
            data["publishedAt"] = Timestamp(date: publishedAt)
        }
        return data
    }
}

// MARK: - Template Status
enum TemplateStatus: String, Codable {
    case pending = "pending"
    case published = "published"
    case hidden = "hidden"
    case deleted = "deleted"
}

// MARK: - Template Like
struct TemplateLike: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let templateId: UUID
    let createdAt: Date

    init(id: UUID = UUID(), userId: UUID, templateId: UUID, createdAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.templateId = templateId
        self.createdAt = createdAt
    }
}

// MARK: - Template Usage
struct TemplateUsage: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let templateId: UUID
    let usedAt: Date

    init(id: UUID = UUID(), userId: UUID, templateId: UUID, usedAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.templateId = templateId
        self.usedAt = usedAt
    }
}

// MARK: - Template Report
struct TemplateReport: Identifiable, Codable {
    let id: UUID
    let templateId: UUID
    let reporterUserId: UUID
    let reason: ReportReason
    var detail: String?
    var status: ReportStatus
    let createdAt: Date
    var reviewedAt: Date?

    init(
        id: UUID = UUID(),
        templateId: UUID,
        reporterUserId: UUID,
        reason: ReportReason,
        detail: String? = nil,
        status: ReportStatus = .pending,
        createdAt: Date = Date(),
        reviewedAt: Date? = nil
    ) {
        self.id = id
        self.templateId = templateId
        self.reporterUserId = reporterUserId
        self.reason = reason
        self.detail = detail
        self.status = status
        self.createdAt = createdAt
        self.reviewedAt = reviewedAt
    }
}

// MARK: - Report Reason
enum ReportReason: String, Codable, CaseIterable {
    case spam = "スパム"
    case inappropriate = "不適切な内容"
    case copyright = "著作権侵害"
    case other = "その他"
}

// MARK: - Report Status
enum ReportStatus: String, Codable {
    case pending = "pending"
    case reviewed = "reviewed"
    case resolved = "resolved"
}

// MARK: - Tag
struct Tag: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    var useCount: Int
    let createdAt: Date

    init(id: UUID = UUID(), name: String, useCount: Int = 0, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.useCount = useCount
        self.createdAt = createdAt
    }
}

// MARK: - Community Sort Type
enum CommunitySortType: String, CaseIterable {
    case newest = "新着"
    case popular = "人気"
    case mostUsed = "使用数"
}
