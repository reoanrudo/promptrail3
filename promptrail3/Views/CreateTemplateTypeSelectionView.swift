//
//  CreateTemplateTypeSelectionView.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import SwiftUI

enum CreateTemplateType: String, CaseIterable {
    case text = "Fast"
    case workflow = "Workflow"
    case image = "Picture"

    var icon: String {
        switch self {
        case .text: return "doc.text"
        case .workflow: return "chart.bar.doc.horizontal"
        case .image: return "photo"
        }
    }

    var description: String {
        switch self {
        case .text: return "ChatGPT・Claude向けの短いプロンプトを共有"
        case .workflow: return "複数ステップを順番に実行するワークフローを作成"
        case .image: return "MidjourneyやDALL-Eなど画像生成AIのプロンプトを共有"
        }
    }

    var color: Color {
        switch self {
        case .text: return .prOrange
        case .workflow: return .prCategoryTeal
        case .image: return .prCategoryBlue
        }
    }
}

struct CreateTemplateTypeSelectionView: View {
    @EnvironmentObject var store: PromptStore
    @Environment(\.dismiss) private var dismiss

    @State private var showTextCreate = false
    @State private var showImageCreate = false
    @State private var showWorkflowCreate = false

    var body: some View {
        NavigationStack {
            VStack(spacing: PRSpacing.lg) {
                Text("何を投稿しますか？")
                    .font(PRTypography.headlineMedium)
                    .foregroundColor(.prGray100)
                    .padding(.top, PRSpacing.xl)

                VStack(spacing: PRSpacing.md) {
                    ForEach(CreateTemplateType.allCases, id: \.self) { type in
                        Button(action: {
                            selectType(type)
                        }) {
                            HStack(spacing: PRSpacing.md) {
                                Image(systemName: type.icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(type.color)
                                    .frame(width: 48, height: 48)
                                    .background(type.color.opacity(0.1))
                                    .cornerRadius(PRRadius.md)

                                VStack(alignment: .leading, spacing: PRSpacing.xxs) {
                                    Text(type.rawValue)
                                        .font(PRTypography.bodyMedium)
                                        .foregroundColor(.prGray100)

                                    Text(type.description)
                                        .font(PRTypography.labelSmall)
                                        .foregroundColor(.prGray60)
                                        .multilineTextAlignment(.leading)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(.prGray40)
                            }
                            .padding(PRSpacing.md)
                            .background(Color.white)
                            .cornerRadius(PRRadius.md)
                        }
                    }
                }
                .padding(.horizontal, PRSpacing.md)

                Spacer()
            }
            .background(Color.prGray5)
            .navigationTitle("新規投稿")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showTextCreate, onDismiss: {
            dismiss()
        }) {
            TemplateShareView()
                .environmentObject(store)
        }
        .sheet(isPresented: $showImageCreate, onDismiss: {
            dismiss()
        }) {
            CreateImagePromptView()
                .environmentObject(store)
        }
        .sheet(isPresented: $showWorkflowCreate, onDismiss: {
            dismiss()
        }) {
            CreateWorkflowView()
                .environmentObject(store)
        }
    }

    private func selectType(_ type: CreateTemplateType) {
        switch type {
        case .text:
            showTextCreate = true
        case .image:
            showImageCreate = true
        case .workflow:
            showWorkflowCreate = true
        }
    }
}

#Preview {
    CreateTemplateTypeSelectionView()
        .environmentObject(PromptStore())
}
