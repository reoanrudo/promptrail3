//
//  PRCardButtonStyle.swift
//  promptrail3
//
//  Created by Codex on 2025/11/20.
//

import SwiftUI

/// Provides a subtle pressed state for tappable card rows.
struct PRCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
