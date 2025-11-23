//
//  VariableInputView.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import SwiftUI

struct VariableInputView: View {
    let prompt: Prompt
    @EnvironmentObject var store: PromptStore
    @Environment(\.dismiss) private var dismiss

    @State private var variableValues: [String: String] = [:]
    @State private var showCopiedAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // プロンプトタイトル
                    Text(prompt.title)
                        .font(.headline)
                        .padding(.horizontal)

                    // 変数入力フォーム
                    VStack(spacing: 16) {
                        ForEach(prompt.variables, id: \.self) { variable in
                            VariableInputField(
                                variable: variable,
                                value: binding(for: variable)
                            )
                        }
                    }
                    .padding(.horizontal)

                    // プレビュー
                    PreviewSection(
                        title: "プレビュー",
                        content: filledPrompt
                    )
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("変数を入力")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(action: copyAndDismiss) {
                        Label("コピー", systemImage: "doc.on.doc")
                    }
                    .disabled(!allVariablesFilled)
                }
            }
            .safeAreaInset(edge: .bottom) {
                CopyButton(
                    isEnabled: allVariablesFilled,
                    action: copyAndDismiss
                )
            }
        }
        .alert("コピーしました", isPresented: $showCopiedAlert) {
            Button("OK", role: .cancel) { dismiss() }
        } message: {
            Text("ChatGPTなどに貼り付けて使用してください")
        }
        .onAppear {
            initializeVariables()
        }
    }

    // MARK: - Computed Properties
    private var filledPrompt: String {
        prompt.filledBody(with: variableValues)
    }

    private var allVariablesFilled: Bool {
        prompt.variables.allSatisfy { variable in
            guard let value = variableValues[variable] else { return false }
            return !value.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    // MARK: - Methods
    private func binding(for variable: String) -> Binding<String> {
        Binding(
            get: { variableValues[variable] ?? "" },
            set: { variableValues[variable] = $0 }
        )
    }

    private func initializeVariables() {
        for variable in prompt.variables {
            variableValues[variable] = ""
        }
    }

    private func copyAndDismiss() {
        UIPasteboard.general.string = filledPrompt
        store.recordUsage(promptId: prompt.id, variables: variableValues)
        showCopiedAlert = true
    }
}

// MARK: - Variable Input Field
struct VariableInputField: View {
    let variable: String
    @Binding var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(variable)
                .font(.subheadline)
                .fontWeight(.medium)

            TextField("\(variable)を入力", text: $value)
                .textFieldStyle(.plain)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }
}

// MARK: - Preview Section
struct PreviewSection: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)

            Text(content)
                .font(.system(.caption, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
        }
    }
}

// MARK: - Copy Button
struct CopyButton: View {
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("コピーして使う")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.borderedProminent)
        .disabled(!isEnabled)
        .padding()
        .background(.ultraThinMaterial)
    }
}

#Preview {
    VariableInputView(
        prompt: Prompt(
            title: "ビジネスメール作成",
            body: "以下の条件でビジネスメールを作成してください。\n\n【宛先】{宛先の会社名・部署・氏名}\n【目的】{メールの目的}\n【トーン】{丁寧/カジュアル/フォーマル}",
            categoryId: UUID(),
            taskId: UUID()
        )
    )
    .environmentObject(PromptStore())
}
