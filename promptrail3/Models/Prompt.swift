//
//  Prompt.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import Foundation

struct Prompt: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var body: String
    var description: String?
    var categoryId: UUID
    var taskId: UUID
    var authorName: String
    var isPublic: Bool
    var forkedFromId: UUID?
    var likeCount: Int
    var favoriteCount: Int
    var useCount: Int
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        body: String,
        description: String? = nil,
        categoryId: UUID,
        taskId: UUID,
        authorName: String = "公式",
        isPublic: Bool = true,
        forkedFromId: UUID? = nil,
        likeCount: Int = 0,
        favoriteCount: Int = 0,
        useCount: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.description = description
        self.categoryId = categoryId
        self.taskId = taskId
        self.authorName = authorName
        self.isPublic = isPublic
        self.forkedFromId = forkedFromId
        self.likeCount = likeCount
        self.favoriteCount = favoriteCount
        self.useCount = useCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Variable Extraction

    /// プロンプト本文から{変数}を抽出する
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

    /// 変数を値で置換した完成プロンプトを生成
    func filledBody(with values: [String: String]) -> String {
        var result = body
        for (key, value) in values {
            result = result.replacingOccurrences(of: "{\(key)}", with: value)
        }
        return result
    }
}
