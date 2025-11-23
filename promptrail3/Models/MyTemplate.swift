//
//  MyTemplate.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import Foundation
import FirebaseFirestore

// MARK: - My Template
struct MyTemplate: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var body: String
    var description: String
    var categoryId: UUID
    var taskId: UUID
    var tags: [String]
    var variables: [TemplateVariable]
    var isPublic: Bool
    var folderId: UUID?
    var originalTemplateId: UUID?  // 複製元のテンプレID
    var sampleImageUrl: String?
    var fullImageUrl: String?
    var sourceType: TemplateSourceType?
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        body: String,
        description: String = "",
        categoryId: UUID,
        taskId: UUID,
        tags: [String] = [],
        variables: [TemplateVariable] = [],
        isPublic: Bool = false,
        folderId: UUID? = nil,
        originalTemplateId: UUID? = nil,
        sampleImageUrl: String? = nil,
        fullImageUrl: String? = nil,
        sourceType: TemplateSourceType? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.description = description
        self.categoryId = categoryId
        self.taskId = taskId
        self.tags = tags
        self.variables = variables
        self.isPublic = isPublic
        self.folderId = folderId
        self.originalTemplateId = originalTemplateId
        self.sampleImageUrl = sampleImageUrl
        self.fullImageUrl = fullImageUrl
        self.sourceType = sourceType
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // 変数抽出
    var extractedVariables: [String] {
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

    // MARK: - Firestore Encoding/Decoding

    enum CodingKeys: String, CodingKey {
        case id, title, body, description, tags, variables, isPublic, createdAt, updatedAt
        case categoryId, taskId, folderId, originalTemplateId
        case sampleImageUrl, fullImageUrl, sourceType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // UUID fields - convert from String if needed
        if let idString = try? container.decode(String.self, forKey: .id),
           let uuid = UUID(uuidString: idString) {
            self.id = uuid
        } else {
            self.id = try container.decode(UUID.self, forKey: .id)
        }

        if let categoryIdString = try? container.decode(String.self, forKey: .categoryId),
           let uuid = UUID(uuidString: categoryIdString) {
            self.categoryId = uuid
        } else {
            self.categoryId = try container.decode(UUID.self, forKey: .categoryId)
        }

        if let taskIdString = try? container.decode(String.self, forKey: .taskId),
           let uuid = UUID(uuidString: taskIdString) {
            self.taskId = uuid
        } else {
            self.taskId = try container.decode(UUID.self, forKey: .taskId)
        }

        // Optional UUID fields
        self.folderId = (try? container.decodeIfPresent(String.self, forKey: .folderId))
            .flatMap { $0 }
            .flatMap { UUID(uuidString: $0) }
            ?? (try? container.decodeIfPresent(UUID.self, forKey: .folderId))

        self.originalTemplateId = (try? container.decodeIfPresent(String.self, forKey: .originalTemplateId))
            .flatMap { $0 }
            .flatMap { UUID(uuidString: $0) }
            ?? (try? container.decodeIfPresent(UUID.self, forKey: .originalTemplateId))

        // Regular fields
        self.title = try container.decode(String.self, forKey: .title)
        self.body = try container.decode(String.self, forKey: .body)
        self.description = try container.decode(String.self, forKey: .description)
        self.tags = try container.decode([String].self, forKey: .tags)
        self.variables = try container.decode([TemplateVariable].self, forKey: .variables)
        self.isPublic = try container.decode(Bool.self, forKey: .isPublic)
        self.sampleImageUrl = try container.decodeIfPresent(String.self, forKey: .sampleImageUrl)
        self.fullImageUrl = try container.decodeIfPresent(String.self, forKey: .fullImageUrl)
        self.sourceType = try container.decodeIfPresent(TemplateSourceType.self, forKey: .sourceType)

        // Date fields - handle Timestamp from Firestore
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
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // Convert UUIDs to Strings for Firestore
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(categoryId.uuidString, forKey: .categoryId)
        try container.encode(taskId.uuidString, forKey: .taskId)
        try container.encodeIfPresent(folderId?.uuidString, forKey: .folderId)
        try container.encodeIfPresent(originalTemplateId?.uuidString, forKey: .originalTemplateId)

        // Regular fields
        try container.encode(title, forKey: .title)
        try container.encode(body, forKey: .body)
        try container.encode(description, forKey: .description)
        try container.encode(tags, forKey: .tags)
        try container.encode(variables, forKey: .variables)
        try container.encode(isPublic, forKey: .isPublic)
        try container.encodeIfPresent(sampleImageUrl, forKey: .sampleImageUrl)
        try container.encodeIfPresent(fullImageUrl, forKey: .fullImageUrl)
        try container.encodeIfPresent(sourceType, forKey: .sourceType)

        // Convert Dates to Timestamps for Firestore
        try container.encode(Timestamp(date: createdAt), forKey: .createdAt)
        try container.encode(Timestamp(date: updatedAt), forKey: .updatedAt)
    }

    // MARK: - Firestore Dictionary Conversion

    /// FirestoreのDictionary形式に変換
    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "id": id.uuidString,
            "title": title,
            "body": body,
            "description": description,
            "categoryId": categoryId.uuidString,
            "taskId": taskId.uuidString,
            "tags": tags,
            "isPublic": isPublic,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt)
        ]

        // Optional fields
        if let folderId = folderId {
            data["folderId"] = folderId.uuidString
        }
        if let originalTemplateId = originalTemplateId {
            data["originalTemplateId"] = originalTemplateId.uuidString
        }
        if let sampleImageUrl = sampleImageUrl {
            data["sampleImageUrl"] = sampleImageUrl
        }
        if let fullImageUrl = fullImageUrl {
            data["fullImageUrl"] = fullImageUrl
        }
        if let sourceType = sourceType {
            data["sourceType"] = sourceType.rawValue
        }

        // Convert variables to dictionaries
        data["variables"] = variables.map { variable in
            var varData: [String: Any] = [
                "id": variable.id.uuidString,
                "variableName": variable.variableName,
                "label": variable.label,
                "type": variable.type.rawValue,
                "required": variable.required,
                "order": variable.order
            ]
            if let options = variable.options {
                varData["options"] = options
            }
            if let placeholder = variable.placeholder {
                varData["placeholder"] = placeholder
            }
            if let defaultValue = variable.defaultValue {
                varData["defaultValue"] = defaultValue
            }
            if let description = variable.description {
                varData["description"] = description
            }
            return varData
        }

        return data
    }

    /// FirestoreのDictionaryから初期化
    static func fromFirestoreData(_ data: [String: Any]) -> MyTemplate? {
        guard
            let idString = data["id"] as? String,
            let id = UUID(uuidString: idString),
            let title = data["title"] as? String,
            let body = data["body"] as? String,
            let description = data["description"] as? String,
            let categoryIdString = data["categoryId"] as? String,
            let categoryId = UUID(uuidString: categoryIdString),
            let taskIdString = data["taskId"] as? String,
            let taskId = UUID(uuidString: taskIdString),
            let tags = data["tags"] as? [String],
            let isPublic = data["isPublic"] as? Bool,
            let createdAtTimestamp = data["createdAt"] as? Timestamp,
            let updatedAtTimestamp = data["updatedAt"] as? Timestamp
        else {
            return nil
        }

        let folderId = (data["folderId"] as? String).flatMap { UUID(uuidString: $0) }

        let originalTemplateId = (data["originalTemplateId"] as? String).flatMap { UUID(uuidString: $0) }

        let sourceType: TemplateSourceType? = {
            guard let sourceTypeString = data["sourceType"] as? String else {
                return nil
            }
            return TemplateSourceType(rawValue: sourceTypeString)
        }()

        let variables: [TemplateVariable] = {
            guard let variablesData = data["variables"] as? [[String: Any]] else {
                return []
            }
            return variablesData.compactMap { varData in
                guard
                    let idString = varData["id"] as? String,
                    let id = UUID(uuidString: idString),
                    let variableName = varData["variableName"] as? String,
                    let label = varData["label"] as? String,
                    let typeString = varData["type"] as? String,
                    let type = VariableType(rawValue: typeString),
                    let required = varData["required"] as? Bool,
                    let order = varData["order"] as? Int
                else {
                    return nil
                }

                return TemplateVariable(
                    id: id,
                    variableName: variableName,
                    label: label,
                    type: type,
                    options: varData["options"] as? [String],
                    placeholder: varData["placeholder"] as? String,
                    required: required,
                    defaultValue: varData["defaultValue"] as? String,
                    description: varData["description"] as? String,
                    order: order
                )
            }
        }()

        return MyTemplate(
            id: id,
            title: title,
            body: body,
            description: description,
            categoryId: categoryId,
            taskId: taskId,
            tags: tags,
            variables: variables,
            isPublic: isPublic,
            folderId: folderId,
            originalTemplateId: originalTemplateId,
            sampleImageUrl: data["sampleImageUrl"] as? String,
            fullImageUrl: data["fullImageUrl"] as? String,
            sourceType: sourceType,
            createdAt: createdAtTimestamp.dateValue(),
            updatedAt: updatedAtTimestamp.dateValue()
        )
    }
}

// MARK: - Template Usage History
struct TemplateUsageHistory: Identifiable, Codable {
    let id: UUID
    let templateId: UUID
    let usedAt: Date
    var variableValues: [String: String]

    init(
        id: UUID = UUID(),
        templateId: UUID,
        usedAt: Date = Date(),
        variableValues: [String: String] = [:]
    ) {
        self.id = id
        self.templateId = templateId
        self.usedAt = usedAt
        self.variableValues = variableValues
    }
}
