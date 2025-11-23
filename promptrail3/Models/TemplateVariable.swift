//
//  TemplateVariable.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import Foundation
import FirebaseFirestore

// MARK: - Template Variable
struct TemplateVariable: Identifiable, Codable, Hashable {
    let id: UUID
    var variableName: String       // 内部ID（英数字）
    var label: String              // 表示ラベル
    var type: VariableType         // 入力タイプ
    var options: [String]?         // 選択肢（typeがselectの場合）
    var placeholder: String?       // プレースホルダー
    var required: Bool             // 必須フラグ
    var defaultValue: String?      // デフォルト値
    var description: String?       // 説明文
    var order: Int                 // 表示順

    init(
        id: UUID = UUID(),
        variableName: String,
        label: String,
        type: VariableType = .text,
        options: [String]? = nil,
        placeholder: String? = nil,
        required: Bool = false,
        defaultValue: String? = nil,
        description: String? = nil,
        order: Int = 0
    ) {
        self.id = id
        self.variableName = variableName
        self.label = label
        self.type = type
        self.options = options
        self.placeholder = placeholder
        self.required = required
        self.defaultValue = defaultValue
        self.description = description
        self.order = order
    }

    // MARK: - Firestore Encoding/Decoding

    enum CodingKeys: String, CodingKey {
        case id, variableName, label, type, options, placeholder, required, defaultValue, description, order
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // UUID field - convert from String if needed
        if let idString = try? container.decode(String.self, forKey: .id),
           let uuid = UUID(uuidString: idString) {
            self.id = uuid
        } else {
            self.id = try container.decode(UUID.self, forKey: .id)
        }

        // Regular fields
        self.variableName = try container.decode(String.self, forKey: .variableName)
        self.label = try container.decode(String.self, forKey: .label)
        self.type = try container.decode(VariableType.self, forKey: .type)
        self.options = try container.decodeIfPresent([String].self, forKey: .options)
        self.placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        self.required = try container.decode(Bool.self, forKey: .required)
        self.defaultValue = try container.decodeIfPresent(String.self, forKey: .defaultValue)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.order = try container.decode(Int.self, forKey: .order)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // Convert UUID to String for Firestore
        try container.encode(id.uuidString, forKey: .id)

        // Regular fields
        try container.encode(variableName, forKey: .variableName)
        try container.encode(label, forKey: .label)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(options, forKey: .options)
        try container.encodeIfPresent(placeholder, forKey: .placeholder)
        try container.encode(required, forKey: .required)
        try container.encodeIfPresent(defaultValue, forKey: .defaultValue)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(order, forKey: .order)
    }
}

extension TemplateVariable {
    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "id": id.uuidString,
            "variableName": variableName,
            "label": label,
            "type": type.rawValue,
            "required": required,
            "order": order
        ]

        if let options = options {
            data["options"] = options
        }
        if let placeholder = placeholder {
            data["placeholder"] = placeholder
        }
        if let defaultValue = defaultValue {
            data["defaultValue"] = defaultValue
        }
        if let description = description {
            data["description"] = description
        }

        return data
    }
}

// MARK: - Variable Type
enum VariableType: String, Codable, CaseIterable {
    case text = "テキスト"
    case number = "数値"
    case select = "選択肢"
    case textarea = "複数行テキスト"
}

// MARK: - Variable Value (入力値を保持)
struct VariableValue: Identifiable, Codable {
    let id: UUID
    let variableName: String
    var value: String

    init(id: UUID = UUID(), variableName: String, value: String = "") {
        self.id = id
        self.variableName = variableName
        self.value = value
    }

    // MARK: - Firestore Encoding/Decoding

    enum CodingKeys: String, CodingKey {
        case id, variableName, value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // UUID field - convert from String if needed
        if let idString = try? container.decode(String.self, forKey: .id),
           let uuid = UUID(uuidString: idString) {
            self.id = uuid
        } else {
            self.id = try container.decode(UUID.self, forKey: .id)
        }

        self.variableName = try container.decode(String.self, forKey: .variableName)
        self.value = try container.decode(String.self, forKey: .value)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // Convert UUID to String for Firestore
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(variableName, forKey: .variableName)
        try container.encode(value, forKey: .value)
    }
}
