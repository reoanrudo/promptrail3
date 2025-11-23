//
//  WorkflowExecutionView.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import SwiftUI

struct WorkflowExecutionView: View {
    let workflow: Workflow
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: PromptStore

    @State private var currentStepIndex = 0
    @State private var inputValues: [UUID: String] = [:]
    @State private var pastedText = ""
    @State private var showCopiedToast = false
    @State private var generatedPrompt = ""
    @State private var showCompletionAlert = false

    private var currentStep: WorkflowStep? {
        guard currentStepIndex < workflow.steps.count else { return nil }
        return workflow.steps[currentStepIndex]
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // プログレスバー
                ProgressView(value: Double(currentStepIndex + 1), total: Double(workflow.steps.count))
                    .tint(.prOrange)
                    .padding(.horizontal, PRSpacing.md)
                    .padding(.top, PRSpacing.sm)

                // ステップ表示
                HStack {
                    Text("ステップ \(currentStepIndex + 1) / \(workflow.steps.count)")
                        .font(PRTypography.labelSmall)
                        .foregroundColor(.prGray60)
                    Spacer()
                }
                .padding(.horizontal, PRSpacing.md)
                .padding(.top, PRSpacing.xs)

                if let step = currentStep {
                    ScrollView {
                        VStack(alignment: .leading, spacing: PRSpacing.lg) {
                            // ステップ名
                            VStack(alignment: .leading, spacing: PRSpacing.xs) {
                                Text(step.name)
                                    .font(PRTypography.headlineMedium)
                                    .foregroundColor(.prGray100)

                                if !step.description.isEmpty {
                                    Text(step.description)
                                        .font(PRTypography.bodySmall)
                                        .foregroundColor(.prGray60)
                                }
                            }
                            .padding(.horizontal, PRSpacing.md)

                            // 入力フィールド
                            if !step.inputsSchema.isEmpty {
                                VStack(alignment: .leading, spacing: PRSpacing.sm) {
                                    Text("入力")
                                        .font(PRTypography.labelMedium)
                                        .foregroundColor(.prGray60)

                                    ForEach(step.inputsSchema) { field in
                                        VStack(alignment: .leading, spacing: PRSpacing.xxs) {
                                            HStack {
                                                Text(field.label)
                                                    .font(PRTypography.labelSmall)
                                                    .foregroundColor(.prGray80)
                                                if field.required {
                                                    Text("*")
                                                        .foregroundColor(.prCoral)
                                                }
                                            }

                                            TextField(field.placeholder, text: Binding(
                                                get: { inputValues[field.id] ?? "" },
                                                set: { inputValues[field.id] = $0 }
                                            ))
                                            .font(PRTypography.bodyMedium)
                                            .padding(PRSpacing.sm)
                                            .background(Color.white)
                                            .cornerRadius(PRRadius.sm)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: PRRadius.sm)
                                                    .stroke(Color.prGray20, lineWidth: 1)
                                            )
                                        }
                                    }
                            }
                            .padding(.horizontal, PRSpacing.md)
                        }

                        // ライブプレビュー
                        if let preview = previewPrompt, !preview.isEmpty {
                            VStack(alignment: .leading, spacing: PRSpacing.xs) {
                                HStack {
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 16))
                                        .foregroundColor(.prCategoryBlue)
                                    Text("ステップのプロンプト")
                                        .font(PRTypography.headlineSmall)
                                        .foregroundColor(.prGray100)
                                    Spacer()
                                }

                                Text(preview)
                                    .font(PRTypography.code)
                                    .foregroundColor(.prGray80)
                                    .padding(PRSpacing.md)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.prGray5)
                                    .cornerRadius(PRRadius.sm)
                            }
                            .padding(.horizontal, PRSpacing.md)
                        }

                        // ペースト入力
                        if step.requireUserPaste {
                            VStack(alignment: .leading, spacing: PRSpacing.sm) {
                                    Text("AIの回答をペースト")
                                        .font(PRTypography.labelMedium)
                                        .foregroundColor(.prGray60)

                                    TextEditor(text: $pastedText)
                                        .font(PRTypography.bodySmall)
                                        .frame(minHeight: 120)
                                        .padding(PRSpacing.sm)
                                        .background(Color.white)
                                        .cornerRadius(PRRadius.sm)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: PRRadius.sm)
                                                .stroke(Color.prGray20, lineWidth: 1)
                                        )

                                    if pastedText.isEmpty {
                                        Text("前のステップでコピーしたプロンプトをAIに送信し、その回答をここにペーストしてください")
                                            .font(PRTypography.labelSmall)
                                            .foregroundColor(.prGray40)
                                    }
                                }
                                .padding(.horizontal, PRSpacing.md)
                            }

                            // 生成されたプロンプト
                            if !generatedPrompt.isEmpty {
                                VStack(alignment: .leading, spacing: PRSpacing.sm) {
                                    HStack {
                                        Text("生成されたプロンプト")
                                            .font(PRTypography.labelMedium)
                                            .foregroundColor(.prGray60)

                                        Spacer()

                                        Button(action: copyPrompt) {
                                            HStack(spacing: PRSpacing.xxs) {
                                                Image(systemName: showCopiedToast ? "checkmark" : "doc.on.doc")
                                                    .font(.system(size: 12))
                                                Text(showCopiedToast ? "コピー済み" : "コピー")
                                                    .font(PRTypography.labelSmall)
                                            }
                                            .foregroundColor(.prOrange)
                                        }
                                    }

                                    Text(generatedPrompt)
                                        .font(PRTypography.bodySmall)
                                        .foregroundColor(.prGray80)
                                        .padding(PRSpacing.sm)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.prOrange.opacity(0.05))
                                        .cornerRadius(PRRadius.sm)
                                }
                                .padding(.horizontal, PRSpacing.md)
                            }

                            // 分岐選択（複数の遷移がある場合）
                            if step.transitions.count > 1 && !pastedText.isEmpty {
                                VStack(alignment: .leading, spacing: PRSpacing.sm) {
                                    Text("次のステップを選択")
                                        .font(PRTypography.labelMedium)
                                        .foregroundColor(.prGray60)

                                    ForEach(step.transitions) { transition in
                                        Button(action: { handleTransition(transition) }) {
                                            HStack {
                                                Text(transition.label)
                                                    .font(PRTypography.bodyMedium)
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .font(.system(size: 12))
                                            }
                                            .foregroundColor(.prGray100)
                                            .padding(PRSpacing.sm)
                                            .background(Color.white)
                                            .cornerRadius(PRRadius.sm)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: PRRadius.sm)
                                                    .stroke(Color.prGray20, lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, PRSpacing.md)
                            }

                            Spacer().frame(height: 100)
                        }
                        .padding(.top, PRSpacing.md)
                    }
                } else {
                    // ワークフロー完了
                    VStack(spacing: PRSpacing.lg) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.prOrange)

                        Text("ワークフロー完了！")
                            .font(PRTypography.headlineLarge)
                            .foregroundColor(.prGray100)

                        Text("すべてのステップが完了しました")
                            .font(PRTypography.bodyMedium)
                            .foregroundColor(.prGray60)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background(Color.prGray5)
            .navigationTitle(workflow.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(action: {
                        store.toggleWorkflowLike(workflow.id)
                    }) {
                        Image(systemName: store.isWorkflowLiked(workflow.id) ? "heart.fill" : "heart")
                            .foregroundColor(store.isWorkflowLiked(workflow.id) ? .prCoral : .prGray40)
                    }

                    Button(action: {
                        store.duplicateWorkflow(workflow)
                        store.shouldSwitchToMyPage = true
                    }) {
                        Image(systemName: "bookmark")
                            .foregroundColor(.prGray40)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if currentStep != nil {
                    VStack(spacing: PRSpacing.sm) {
                        if generatedPrompt.isEmpty {
                            // プロンプト生成ボタン
                            Button(action: generatePrompt) {
                                Text("プロンプトを生成")
                                    .font(PRTypography.labelMedium)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, PRSpacing.sm)
                                    .background(canGeneratePrompt ? Color.prOrange : Color.prGray40)
                                    .cornerRadius(PRRadius.md)
                            }
                            .disabled(!canGeneratePrompt)
                        } else {
                            // 次へボタン
                            Button(action: goToNextStep) {
                                HStack {
                                    if currentStepIndex == workflow.steps.count - 1 {
                                        Text("完了")
                                    } else {
                                        Text("次のステップへ")
                                        Image(systemName: "arrow.right")
                                    }
                                }
                                .font(PRTypography.labelMedium)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, PRSpacing.sm)
                                .background(canProceed ? Color.prOrange : Color.prGray40)
                                .cornerRadius(PRRadius.md)
                            }
                            .disabled(!canProceed)
                        }
                    }
                    .padding(PRSpacing.md)
                    .background(Color.white)
                } else {
                    // 完了時のボタン
                    Button(action: { dismiss() }) {
                        Text("閉じる")
                            .font(PRTypography.labelMedium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, PRSpacing.sm)
                            .background(Color.prOrange)
                            .cornerRadius(PRRadius.md)
                    }
                    .padding(PRSpacing.md)
                    .background(Color.white)
                }
            }
        }
    }

    private var canGeneratePrompt: Bool {
        guard let step = currentStep else { return false }

        // 必須フィールドがすべて入力されているか
        for field in step.inputsSchema where field.required {
            if (inputValues[field.id] ?? "").isEmpty {
                return false
            }
        }

        // ペーストが必要な場合、ペーストされているか
        if step.requireUserPaste && pastedText.isEmpty {
            return false
        }

        return true
    }

    private var canProceed: Bool {
        guard let step = currentStep else { return false }

        // プロンプトが生成されているか
        if generatedPrompt.isEmpty {
            return false
        }

        // 遷移条件の評価
        if step.transitions.count == 1 {
            return step.transitions[0].evaluate(pastedText: pastedText)
        }

        return true
    }

    private func generatePrompt() {
        guard let step = currentStep else { return }

        generatedPrompt = buildPrompt(for: step)
    }

    private func copyPrompt() {
        UIPasteboard.general.string = generatedPrompt
        showCopiedToast = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showCopiedToast = false
        }
    }

    private func goToNextStep() {
        guard let step = currentStep else { return }

        // 単一の遷移の場合
        if step.transitions.count == 1 {
            handleTransition(step.transitions[0])
        } else if step.transitions.isEmpty {
            // 遷移がない場合は次のステップへ
            moveToStep(currentStepIndex + 1)
        }
    }

    private func handleTransition(_ transition: StepTransition) {
        if let nextStepId = transition.nextStepId,
           let nextIndex = workflow.steps.firstIndex(where: { $0.id == nextStepId }) {
            moveToStep(nextIndex)
        } else {
            // nextStepIdがnilの場合は次のステップへ
            moveToStep(currentStepIndex + 1)
        }
    }

    private func moveToStep(_ index: Int) {
        withAnimation {
            currentStepIndex = index
            inputValues = [:]
            pastedText = ""
            generatedPrompt = ""
        }
    }

    private func buildPrompt(for step: WorkflowStep) -> String {
        var prompt = step.promptTemplate

        for (fieldId, value) in inputValues {
            if let field = step.inputsSchema.first(where: { $0.id == fieldId }) {
                prompt = prompt.replacingOccurrences(of: "{\(field.label)}", with: value)
            }
        }

        if step.requireUserPaste {
            prompt = prompt.replacingOccurrences(of: "{outline}", with: pastedText)
            prompt = prompt.replacingOccurrences(of: "{draft}", with: pastedText)
            prompt = prompt.replacingOccurrences(of: "{result}", with: pastedText)
            prompt = prompt.replacingOccurrences(of: "{previous}", with: pastedText)
        }

        return prompt
    }

    private var previewPrompt: String? {
        guard let step = currentStep else { return nil }
        let prompt = buildPrompt(for: step)
        return prompt.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#Preview {
    WorkflowExecutionView(workflow: Workflow(
        title: "ブログ記事作成",
        description: "記事を段階的に作成",
        steps: [
            WorkflowStep(
                name: "アウトライン作成",
                description: "トピックからアウトラインを生成",
                promptTemplate: "{トピック}について、アウトラインを作成してください",
                inputsSchema: [
                    WorkflowInputField(label: "トピック", placeholder: "記事のテーマ", required: true)
                ]
            ),
            WorkflowStep(
                name: "本文執筆",
                description: "アウトラインに基づいて執筆",
                promptTemplate: "以下のアウトラインに基づいて本文を執筆:\n\n{outline}",
                requireUserPaste: true
            )
        ],
        tags: ["ライティング"],
        authorName: "demo"
    ))
    .environmentObject(PromptStore())
}
