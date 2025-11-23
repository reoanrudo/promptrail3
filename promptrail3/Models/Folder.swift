//
//  Folder.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import Foundation

struct Folder: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var sortOrder: Int
    let createdAt: Date

    init(id: UUID = UUID(), name: String, sortOrder: Int, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.sortOrder = sortOrder
        self.createdAt = createdAt
    }
}
