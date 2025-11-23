//
//  CardDeleteButton.swift
//  promptrail3
//
//  Created by Codex on 2025/11/20.
//

import SwiftUI

struct CardDeleteButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "trash")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.prGray40)
                .padding(8)
                .background(Color.white.opacity(0.9))
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("削除")
    }
}
