//
//  Favorite.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import Foundation

struct Favorite: Identifiable, Codable, Hashable {
    let id: UUID
    let promptId: UUID
    var folderId: UUID?
    let createdAt: Date

    init(id: UUID = UUID(), promptId: UUID, folderId: UUID? = nil, createdAt: Date = Date()) {
        self.id = id
        self.promptId = promptId
        self.folderId = folderId
        self.createdAt = createdAt
    }
}
