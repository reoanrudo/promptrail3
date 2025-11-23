//
//  Workflow.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import Foundation
import FirebaseFirestore

// MARK: - Workflow
struct Workflow: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var description: String
    var steps: [WorkflowStep]
    var tags: [String]
    var likeCount: Int
    var useCount: Int
    let createdAt: Date
    var authorId: String
    var authorName: String

    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        steps: [WorkflowStep] = [],
        tags: [String] = [],
        likeCount: Int = 0,
        useCount: Int = 0,
        createdAt: Date = Date(),
        authorId: String = "",
        authorName: String = ""
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.steps = steps
        self.tags = tags
        self.likeCount = likeCount
        self.useCount = useCount
        self.createdAt = createdAt
        self.authorId = authorId
        self.authorName = authorName
    }

    static func == (lhs: Workflow, rhs: Workflow) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // 最初のステップを取得
    var firstStep: WorkflowStep? {
        steps.first
    }

    // ステップIDからステップを取得
    func step(for id: UUID) -> WorkflowStep? {
        steps.first { $0.id == id }
    }

    // MARK: - Firestore Support

    enum CodingKeys: String, CodingKey {
        case id, title, description, steps, tags, likeCount, useCount, createdAt, authorId, authorName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let idString = try? container.decode(String.self, forKey: .id) {
            self.id = UUID(uuidString: idString) ?? UUID()
        } else {
            self.id = try container.decode(UUID.self, forKey: .id)
        }

        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.steps = try container.decode([WorkflowStep].self, forKey: .steps)
        self.tags = try container.decode([String].self, forKey: .tags)
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
        try container.encode(description, forKey: .description)
        try container.encode(steps, forKey: .steps)
        try container.encode(tags, forKey: .tags)
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
            "description": description,
            "steps": steps.map { $0.toFirestoreData() },
            "tags": tags,
            "likeCount": likeCount,
            "useCount": useCount,
            "createdAt": Timestamp(date: createdAt),
            "authorId": authorId,
            "authorName": authorName
        ]
    }

    static func fromFirestoreData(_ data: [String: Any]) -> Workflow? {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString),
              let title = data["title"] as? String,
              let description = data["description"] as? String,
              let stepsData = data["steps"] as? [[String: Any]],
              let tags = data["tags"] as? [String],
              let likeCount = data["likeCount"] as? Int,
              let useCount = data["useCount"] as? Int,
              let createdAtTimestamp = data["createdAt"] as? Timestamp,
              let authorId = data["authorId"] as? String,
              let authorName = data["authorName"] as? String
        else {
            return nil
        }

        let steps = stepsData.compactMap { WorkflowStep.fromFirestoreData($0) }

        return Workflow(
            id: id,
            title: title,
            description: description,
            steps: steps,
            tags: tags,
            likeCount: likeCount,
            useCount: useCount,
            createdAt: createdAtTimestamp.dateValue(),
            authorId: authorId,
            authorName: authorName
        )
    }
}

// MARK: - Workflow Step
struct WorkflowStep: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var promptTemplate: String
    var inputsSchema: [WorkflowInputField]
    var requireUserPaste: Bool
    var transitions: [StepTransition]

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        promptTemplate: String = "",
        inputsSchema: [WorkflowInputField] = [],
        requireUserPaste: Bool = false,
        transitions: [StepTransition] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.promptTemplate = promptTemplate
        self.inputsSchema = inputsSchema
        self.requireUserPaste = requireUserPaste
        self.transitions = transitions
    }

    // MARK: - Firestore Support

    enum CodingKeys: String, CodingKey {
        case id, name, description, promptTemplate, inputsSchema, requireUserPaste, transitions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let idString = try? container.decode(String.self, forKey: .id) {
            self.id = UUID(uuidString: idString) ?? UUID()
        } else {
            self.id = try container.decode(UUID.self, forKey: .id)
        }

        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.promptTemplate = try container.decode(String.self, forKey: .promptTemplate)
        self.inputsSchema = try container.decode([WorkflowInputField].self, forKey: .inputsSchema)
        self.requireUserPaste = try container.decode(Bool.self, forKey: .requireUserPaste)
        self.transitions = try container.decode([StepTransition].self, forKey: .transitions)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id.uuidString, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(promptTemplate, forKey: .promptTemplate)
        try container.encode(inputsSchema, forKey: .inputsSchema)
        try container.encode(requireUserPaste, forKey: .requireUserPaste)
        try container.encode(transitions, forKey: .transitions)
    }

    func toFirestoreData() -> [String: Any] {
        return [
            "id": id.uuidString,
            "name": name,
            "description": description,
            "promptTemplate": promptTemplate,
            "inputsSchema": inputsSchema.map { $0.toFirestoreData() },
            "requireUserPaste": requireUserPaste,
            "transitions": transitions.map { $0.toFirestoreData() }
        ]
    }

    static func fromFirestoreData(_ data: [String: Any]) -> WorkflowStep? {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString),
              let name = data["name"] as? String,
              let description = data["description"] as? String,
              let promptTemplate = data["promptTemplate"] as? String,
              let inputsSchemaData = data["inputsSchema"] as? [[String: Any]],
              let requireUserPaste = data["requireUserPaste"] as? Bool,
              let transitionsData = data["transitions"] as? [[String: Any]]
        else {
            return nil
        }

        let inputsSchema = inputsSchemaData.compactMap { WorkflowInputField.fromFirestoreData($0) }
        let transitions = transitionsData.compactMap { StepTransition.fromFirestoreData($0) }

        return WorkflowStep(
            id: id,
            name: name,
            description: description,
            promptTemplate: promptTemplate,
            inputsSchema: inputsSchema,
            requireUserPaste: requireUserPaste,
            transitions: transitions
        )
    }
}

// MARK: - Workflow Input Field
struct WorkflowInputField: Identifiable, Codable, Hashable {
    let id: UUID
    var label: String
    var placeholder: String
    var required: Bool

    init(
        id: UUID = UUID(),
        label: String,
        placeholder: String = "",
        required: Bool = false
    ) {
        self.id = id
        self.label = label
        self.placeholder = placeholder
        self.required = required
    }

    // MARK: - Firestore Support

    enum CodingKeys: String, CodingKey {
        case id, label, placeholder, required
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let idString = try? container.decode(String.self, forKey: .id) {
            self.id = UUID(uuidString: idString) ?? UUID()
        } else {
            self.id = try container.decode(UUID.self, forKey: .id)
        }

        self.label = try container.decode(String.self, forKey: .label)
        self.placeholder = try container.decode(String.self, forKey: .placeholder)
        self.required = try container.decode(Bool.self, forKey: .required)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id.uuidString, forKey: .id)
        try container.encode(label, forKey: .label)
        try container.encode(placeholder, forKey: .placeholder)
        try container.encode(required, forKey: .required)
    }

    func toFirestoreData() -> [String: Any] {
        return [
            "id": id.uuidString,
            "label": label,
            "placeholder": placeholder,
            "required": required
        ]
    }

    static func fromFirestoreData(_ data: [String: Any]) -> WorkflowInputField? {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString),
              let label = data["label"] as? String,
              let placeholder = data["placeholder"] as? String,
              let required = data["required"] as? Bool
        else {
            return nil
        }

        return WorkflowInputField(
            id: id,
            label: label,
            placeholder: placeholder,
            required: required
        )
    }
}

// MARK: - Step Transition
struct StepTransition: Identifiable, Codable, Hashable {
    let id: UUID
    var label: String
    var conditionType: TransitionConditionType
    var conditionParams: [String: String]
    var nextStepId: UUID?

    init(
        id: UUID = UUID(),
        label: String,
        conditionType: TransitionConditionType = .manual,
        conditionParams: [String: String] = [:],
        nextStepId: UUID? = nil
    ) {
        self.id = id
        self.label = label
        self.conditionType = conditionType
        self.conditionParams = conditionParams
        self.nextStepId = nextStepId
    }

    // 条件を評価
    func evaluate(pastedText: String) -> Bool {
        switch conditionType {
        case .manual:
            return true

        case .maxLength:
            guard let thresholdStr = conditionParams["threshold"],
                  let threshold = Int(thresholdStr) else {
                return true
            }
            return pastedText.count <= threshold

        case .containsKeyword:
            guard let keyword = conditionParams["keyword"] else {
                return true
            }
            return pastedText.contains(keyword)
        }
    }

    // MARK: - Firestore Support

    enum CodingKeys: String, CodingKey {
        case id, label, conditionType, conditionParams, nextStepId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let idString = try? container.decode(String.self, forKey: .id) {
            self.id = UUID(uuidString: idString) ?? UUID()
        } else {
            self.id = try container.decode(UUID.self, forKey: .id)
        }

        self.label = try container.decode(String.self, forKey: .label)
        self.conditionType = try container.decode(TransitionConditionType.self, forKey: .conditionType)
        self.conditionParams = try container.decode([String: String].self, forKey: .conditionParams)

        if let nextStepIdString = try? container.decode(String.self, forKey: .nextStepId) {
            self.nextStepId = UUID(uuidString: nextStepIdString)
        } else {
            self.nextStepId = try? container.decode(UUID.self, forKey: .nextStepId)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id.uuidString, forKey: .id)
        try container.encode(label, forKey: .label)
        try container.encode(conditionType, forKey: .conditionType)
        try container.encode(conditionParams, forKey: .conditionParams)

        if let nextStepId = nextStepId {
            try container.encode(nextStepId.uuidString, forKey: .nextStepId)
        }
    }

    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "id": id.uuidString,
            "label": label,
            "conditionType": conditionType.rawValue,
            "conditionParams": conditionParams
        ]

        if let nextStepId = nextStepId {
            data["nextStepId"] = nextStepId.uuidString
        }

        return data
    }

    static func fromFirestoreData(_ data: [String: Any]) -> StepTransition? {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString),
              let label = data["label"] as? String,
              let conditionTypeString = data["conditionType"] as? String,
              let conditionType = TransitionConditionType(rawValue: conditionTypeString),
              let conditionParams = data["conditionParams"] as? [String: String]
        else {
            return nil
        }

        var nextStepId: UUID? = nil
        if let nextStepIdString = data["nextStepId"] as? String {
            nextStepId = UUID(uuidString: nextStepIdString)
        }

        return StepTransition(
            id: id,
            label: label,
            conditionType: conditionType,
            conditionParams: conditionParams,
            nextStepId: nextStepId
        )
    }
}

// MARK: - Transition Condition Type
enum TransitionConditionType: String, Codable, CaseIterable {
    case manual = "manual"
    case maxLength = "maxLength"
    case containsKeyword = "containsKeyword"

    var displayName: String {
        switch self {
        case .manual: return "手動"
        case .maxLength: return "文字数制限"
        case .containsKeyword: return "キーワード含有"
        }
    }
}

// MARK: - Workflow Execution State
struct WorkflowExecutionState: Codable {
    let workflowId: UUID
    var currentStepId: UUID
    var inputValues: [UUID: String]  // inputField.id -> value
    var pastedTexts: [UUID: String]  // step.id -> pasted text
    var startedAt: Date
    var completedAt: Date?

    init(
        workflowId: UUID,
        currentStepId: UUID,
        inputValues: [UUID: String] = [:],
        pastedTexts: [UUID: String] = [:],
        startedAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.workflowId = workflowId
        self.currentStepId = currentStepId
        self.inputValues = inputValues
        self.pastedTexts = pastedTexts
        self.startedAt = startedAt
        self.completedAt = completedAt
    }
}

// MARK: - Workflow Like
struct WorkflowLike: Identifiable, Codable {
    let id: UUID
    let userId: String
    let workflowId: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        userId: String,
        workflowId: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.workflowId = workflowId
        self.createdAt = createdAt
    }

    // MARK: - Firestore Support

    enum CodingKeys: String, CodingKey {
        case id, userId, workflowId, createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let idString = try? container.decode(String.self, forKey: .id) {
            self.id = UUID(uuidString: idString) ?? UUID()
        } else {
            self.id = try container.decode(UUID.self, forKey: .id)
        }

        self.userId = try container.decode(String.self, forKey: .userId)
        self.workflowId = try container.decode(String.self, forKey: .workflowId)

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
        try container.encode(workflowId, forKey: .workflowId)
        try container.encode(Timestamp(date: createdAt), forKey: .createdAt)
    }

    func toFirestoreData() -> [String: Any] {
        return [
            "id": id.uuidString,
            "userId": userId,
            "workflowId": workflowId,
            "createdAt": Timestamp(date: createdAt)
        ]
    }

    static func fromFirestoreData(_ data: [String: Any]) -> WorkflowLike? {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString),
              let userId = data["userId"] as? String,
              let workflowId = data["workflowId"] as? String,
              let createdAtTimestamp = data["createdAt"] as? Timestamp
        else {
            return nil
        }

        return WorkflowLike(
            id: id,
            userId: userId,
            workflowId: workflowId,
            createdAt: createdAtTimestamp.dateValue()
        )
    }
}
