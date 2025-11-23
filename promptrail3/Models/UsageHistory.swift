//
//  UsageHistory.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import Foundation

struct UsageHistory: Identifiable, Codable, Hashable {
    let id: UUID
    let promptId: UUID
    let variablesJson: [String: String]
    let usedAt: Date

    init(id: UUID = UUID(), promptId: UUID, variablesJson: [String: String] = [:], usedAt: Date = Date()) {
        self.id = id
        self.promptId = promptId
        self.variablesJson = variablesJson
        self.usedAt = usedAt
    }
}
