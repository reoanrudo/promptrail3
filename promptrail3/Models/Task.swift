//
//  Task.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import Foundation

struct PromptTask: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let icon: String
    let sortOrder: Int

    init(id: UUID = UUID(), name: String, icon: String, sortOrder: Int) {
        self.id = id
        self.name = name
        self.icon = icon
        self.sortOrder = sortOrder
    }
}

// MARK: - Initial Tasks
extension PromptTask {
    static let initialTasks: [PromptTask] = [
        PromptTask(name: "文章生成", icon: "doc.text.fill", sortOrder: 1),
        PromptTask(name: "要約", icon: "text.justify.left", sortOrder: 2),
        PromptTask(name: "アイデア出し", icon: "lightbulb.fill", sortOrder: 3),
        PromptTask(name: "添削・校正", icon: "checkmark.circle.fill", sortOrder: 4),
        PromptTask(name: "翻訳", icon: "globe", sortOrder: 5),
        PromptTask(name: "分析", icon: "magnifyingglass", sortOrder: 6),
        PromptTask(name: "説明・解説", icon: "info.circle.fill", sortOrder: 7),
        PromptTask(name: "質問作成", icon: "questionmark.circle.fill", sortOrder: 8),
        PromptTask(name: "コード生成", icon: "terminal.fill", sortOrder: 9),
        PromptTask(name: "その他", icon: "ellipsis.circle.fill", sortOrder: 10)
    ]
}
