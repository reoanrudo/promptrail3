//
//  Category.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import Foundation

struct Category: Identifiable, Codable, Hashable {
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

// MARK: - Initial Categories
extension Category {
    static let initialCategories: [Category] = [
        Category(name: "ビジネス", icon: "briefcase.fill", sortOrder: 1),
        Category(name: "マーケティング", icon: "megaphone.fill", sortOrder: 2),
        Category(name: "ライティング", icon: "pencil.and.outline", sortOrder: 3),
        Category(name: "学習・教育", icon: "book.fill", sortOrder: 4),
        Category(name: "プログラミング", icon: "chevron.left.forwardslash.chevron.right", sortOrder: 5),
        Category(name: "日常・生活", icon: "house.fill", sortOrder: 6),
        Category(name: "クリエイティブ", icon: "paintbrush.fill", sortOrder: 7),
        Category(name: "分析・リサーチ", icon: "chart.bar.fill", sortOrder: 8),
        Category(name: "コミュニケーション", icon: "bubble.left.and.bubble.right.fill", sortOrder: 9),
        Category(name: "その他", icon: "ellipsis.circle.fill", sortOrder: 10)
    ]
}
