//
//  CreateWorkflowView.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import SwiftUI

struct CreateWorkflowView: View {
    @EnvironmentObject var store: PromptStore
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var authorName = ""
    @State private var tagInput = ""
    @State private var tags: [String] = []
    @State private var steps: [EditableWorkflowStep] = []
    @State private var showAddStep = false
    @State private var editingStepIndex: Int?

    var body: some View {
        NavigationStack {
            Form {
                // 基本情報
                Section("基本情報") {
                    TextField("ワークフロー名", text: $title)

                    VStack(alignment: .leading, spacing: PRSpacing.xs) {
                        Text("説明")
                            .font(PRTypography.labelSmall)
                            .foregroundColor(.prGray60)

                        TextEditor(text: $description)
                            .frame(minHeight: 80)
                            .font(PRTypography.bodySmall)
                    }

                    TextField("投稿者名", text: $authorName)
                }

                // タグ
                Section("タグ") {
                    HStack {
                        TextField("タグを追加", text: $tagInput)
                            .onSubmit {
                                addTag()
                            }

                        Button(action: addTag) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.prOrange)
                        }
                        .disabled(tagInput.isEmpty)
                    }

                    if !tags.isEmpty {
                        FlowLayout(spacing: PRSpacing.xs) {
                            ForEach(tags, id: \.self) { tag in
                                HStack(spacing: 4) {
                                    Text(tag)
                                        .font(PRTypography.labelSmall)

                                    Button(action: { removeTag(tag) }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 12))
                                    }
                                }
                                .foregroundColor(.prCategoryBlue)
                                .padding(.horizontal, PRSpacing.xs)
                                .padding(.vertical, 4)
                                .background(Color.prCategoryBlue.opacity(0.1))
                                .cornerRadius(PRRadius.xs)
                            }
                        }
                    }

                    // 推奨タグ
                    VStack(alignment: .leading, spacing: PRSpacing.xs) {
                        Text("推奨タグ")
                            .font(PRTypography.labelSmall)
                            .foregroundColor(.prGray40)

                        FlowLayout(spacing: PRSpacing.xs) {
                            ForEach(WorkflowTag.allCases, id: \.self) { tag in
                                Button(action: {
                                    if !tags.contains(tag.rawValue) {
                                        tags.append(tag.rawValue)
                                    }
                                }) {
                                    Text(tag.rawValue)
                                        .font(PRTypography.labelSmall)
                                        .foregroundColor(tags.contains(tag.rawValue) ? .white : .prGray60)
                                        .padding(.horizontal, PRSpacing.xs)
                                        .padding(.vertical, 4)
                                        .background(tags.contains(tag.rawValue) ? Color.prOrange : Color.prGray10)
                                        .cornerRadius(PRRadius.xs)
                                }
                            }
                        }
                    }
                }

                // プリセット選択
                if steps.isEmpty {
                    Section("クイックスタート") {
                        VStack(alignment: .leading, spacing: PRSpacing.sm) {
                            Text("テンプレートから始める")
                                .font(PRTypography.labelMedium)
                                .foregroundColor(Color.prTextPrimary)

                            HStack(spacing: PRSpacing.sm) {
                                PresetButton(stepCount: 3, action: { usePreset(stepCount: 3) })
                                PresetButton(stepCount: 4, action: { usePreset(stepCount: 4) })
                                PresetButton(stepCount: 5, action: { usePreset(stepCount: 5) })
                            }

                            Text("または手動でステップを追加")
                                .font(PRTypography.labelSmall)
                                .foregroundColor(Color.prTextSecondary)
                                .padding(.top, PRSpacing.xs)
                        }
                    }
                }

                // ステップ
                Section {
                    if !steps.isEmpty {
                        ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                            WorkflowStepRow(
                                step: step,
                                stepNumber: index + 1,
                                onEdit: { editingStepIndex = index },
                                onDelete: { deleteStep(at: index) }
                            )
                        }
                        .onMove { from, to in
                            steps.move(fromOffsets: from, toOffset: to)
                        }
                    }

                    Button(action: { showAddStep = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("ステップを追加")
                        }
                        .foregroundColor(.prOrange)
                    }
                } header: {
                    HStack {
                        Text("ステップ (\(steps.count))")
                        Spacer()
                        if !steps.isEmpty {
                            EditButton()
                        }
                    }
                }
            }
            .navigationTitle("ワークフローを投稿")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("投稿") {
                        publishWorkflow()
                    }
                    .disabled(!isValid)
                }
            }
            .sheet(isPresented: $showAddStep) {
                EditWorkflowStepView(
                    step: nil,
                    onSave: { newStep in
                        steps.append(newStep)
                    }
                )
            }
            .sheet(item: $editingStepIndex) { index in
                EditWorkflowStepView(
                    step: steps[index],
                    onSave: { updatedStep in
                        steps[index] = updatedStep
                    }
                )
            }
        }
    }

    private var isValid: Bool {
        !title.isEmpty && !authorName.isEmpty && !steps.isEmpty
    }

    private func addTag() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !tags.contains(trimmed) {
            tags.append(trimmed)
            tagInput = ""
        }
    }

    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }

    private func deleteStep(at index: Int) {
        steps.remove(at: index)
    }

    private func usePreset(stepCount: Int) {
        let presetSteps = WorkflowPreset.createPreset(stepCount: stepCount)
        steps = presetSteps
    }

    private func publishWorkflow() {
        // EditableWorkflowStepをWorkflowStepに変換
        var workflowSteps: [WorkflowStep] = []
        var stepIds: [UUID] = []

        // まずIDを生成
        for _ in steps {
            stepIds.append(UUID())
        }

        // ステップを変換（次のステップへの遷移を設定）
        for (index, editableStep) in steps.enumerated() {
            let nextStepId = index < steps.count - 1 ? stepIds[index + 1] : nil
            let transitions = nextStepId != nil ? [StepTransition(label: "次へ", nextStepId: nextStepId)] : []

            let workflowStep = WorkflowStep(
                id: stepIds[index],
                name: editableStep.name,
                description: editableStep.description,
                promptTemplate: editableStep.promptTemplate,
                inputsSchema: editableStep.inputFields.map { field in
                    WorkflowInputField(
                        label: field.label,
                        placeholder: field.placeholder,
                        required: field.required
                    )
                },
                requireUserPaste: editableStep.requireUserPaste,
                transitions: transitions
            )
            workflowSteps.append(workflowStep)
        }

        let workflow = Workflow(
            title: title,
            description: description,
            steps: workflowSteps,
            tags: tags,
            authorId: store.currentUserIdString,
            authorName: authorName.isEmpty ? "あなた" : authorName
        )

        store.workflows.insert(workflow, at: 0)
        dismiss()
    }
}

// MARK: - Editable Workflow Step
struct EditableWorkflowStep: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var promptTemplate: String
    var inputFields: [EditableInputField]
    var requireUserPaste: Bool
}

struct EditableInputField: Identifiable {
    let id = UUID()
    var label: String
    var placeholder: String
    var required: Bool
}

// MARK: - Workflow Step Row
struct WorkflowStepRow: View {
    let step: EditableWorkflowStep
    let stepNumber: Int
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: PRSpacing.sm) {
            Text("\(stepNumber)")
                .font(PRTypography.labelMedium)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.prOrange)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(step.name)
                    .font(PRTypography.bodyMedium)
                    .foregroundColor(.prGray100)

                if !step.description.isEmpty {
                    Text(step.description)
                        .font(PRTypography.labelSmall)
                        .foregroundColor(.prGray60)
                        .lineLimit(1)
                }
            }

            Spacer()

            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.system(size: 14))
                    .foregroundColor(.prGray40)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit()
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Label("削除", systemImage: "trash")
            }
        }
    }
}

// MARK: - Edit Workflow Step View
struct EditWorkflowStepView: View {
    let step: EditableWorkflowStep?
    let onSave: (EditableWorkflowStep) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var description = ""
    @State private var promptTemplate = ""
    @State private var inputFields: [EditableInputField] = []
    @State private var requireUserPaste = false
    @State private var newFieldLabel = ""
    @State private var newFieldPlaceholder = ""
    @State private var newFieldRequired = false

    var body: some View {
        NavigationStack {
            Form {
                Section("ステップ情報") {
                    TextField("ステップ名", text: $name)
                    TextField("説明（任意）", text: $description)
                }

                Section("プロンプトテンプレート") {
                    VStack(alignment: .leading, spacing: PRSpacing.xs) {
                        Text("変数は {変数名} の形式で記述してください")
                            .font(PRTypography.labelSmall)
                            .foregroundColor(.prGray40)

                        TextEditor(text: $promptTemplate)
                            .frame(minHeight: 120)
                            .font(PRTypography.bodySmall)
                    }
                }

                Section("入力フィールド") {
                    ForEach(inputFields) { field in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(field.label)
                                    .font(PRTypography.bodySmall)
                                if field.required {
                                    Text("必須")
                                        .font(PRTypography.labelSmall)
                                        .foregroundColor(.prCoral)
                                }
                            }

                            Spacer()

                            Button(action: { removeInputField(field.id) }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.prGray40)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: PRSpacing.xs) {
                        TextField("ラベル", text: $newFieldLabel)
                        TextField("プレースホルダー", text: $newFieldPlaceholder)
                        Toggle("必須", isOn: $newFieldRequired)

                        Button(action: addInputField) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("フィールドを追加")
                            }
                            .foregroundColor(.prOrange)
                        }
                        .disabled(newFieldLabel.isEmpty)
                    }
                }

                Section("AIの回答ペースト") {
                    Toggle("前のステップの結果をペーストさせる", isOn: $requireUserPaste)

                    if requireUserPaste {
                        Text("ユーザーはAIの回答をコピーして、このステップでペーストします")
                            .font(PRTypography.labelSmall)
                            .foregroundColor(.prGray40)
                    }
                }
            }
            .navigationTitle(step == nil ? "ステップを追加" : "ステップを編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveStep()
                    }
                    .disabled(name.isEmpty || promptTemplate.isEmpty)
                }
            }
            .onAppear {
                if let step = step {
                    name = step.name
                    description = step.description
                    promptTemplate = step.promptTemplate
                    inputFields = step.inputFields
                    requireUserPaste = step.requireUserPaste
                }
            }
        }
    }

    private func addInputField() {
        let field = EditableInputField(
            label: newFieldLabel,
            placeholder: newFieldPlaceholder,
            required: newFieldRequired
        )
        inputFields.append(field)
        newFieldLabel = ""
        newFieldPlaceholder = ""
        newFieldRequired = false
    }

    private func removeInputField(_ id: UUID) {
        inputFields.removeAll { $0.id == id }
    }

    private func saveStep() {
        let editableStep = EditableWorkflowStep(
            name: name,
            description: description,
            promptTemplate: promptTemplate,
            inputFields: inputFields,
            requireUserPaste: requireUserPaste
        )
        onSave(editableStep)
        dismiss()
    }
}

// MARK: - Preset Button
struct PresetButton: View {
    let stepCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: PRSpacing.xs) {
                Text("\(stepCount)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.prOrange)

                Text("ステップ")
                    .font(PRTypography.labelSmall)
                    .foregroundColor(Color.prTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, PRSpacing.md)
            .background(Color.prSurfaceElevated)
            .cornerRadius(PRRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: PRRadius.md)
                    .stroke(Color.prOrange.opacity(0.3), lineWidth: 1.5)
            )
        }
    }
}

// MARK: - Workflow Preset
struct WorkflowPreset {
    static func createPreset(stepCount: Int) -> [EditableWorkflowStep] {
        switch stepCount {
        case 3:
            return [
                EditableWorkflowStep(
                    name: "ステップ1: 情報収集",
                    description: "必要な情報を収集する",
                    promptTemplate: "{topic}について、以下の観点で情報を整理してください：\n1. 基本的な定義\n2. 主要な特徴\n3. 関連する概念",
                    inputFields: [
                        EditableInputField(label: "topic", placeholder: "トピック", required: true)
                    ],
                    requireUserPaste: false
                ),
                EditableWorkflowStep(
                    name: "ステップ2: 分析",
                    description: "収集した情報を分析する",
                    promptTemplate: "前のステップで整理した情報を基に、以下の観点で分析してください：\n1. 強みと弱み\n2. 機会と脅威\n3. 今後の展望\n\n{previous_result}",
                    inputFields: [
                        EditableInputField(label: "previous_result", placeholder: "前ステップの結果", required: true)
                    ],
                    requireUserPaste: true
                ),
                EditableWorkflowStep(
                    name: "ステップ3: まとめ",
                    description: "分析結果をまとめる",
                    promptTemplate: "以下の分析結果を基に、簡潔なまとめを作成してください：\n\n{analysis_result}\n\n要約は3つの重要ポイントに絞ってください。",
                    inputFields: [
                        EditableInputField(label: "analysis_result", placeholder: "分析結果", required: true)
                    ],
                    requireUserPaste: true
                )
            ]
        case 4:
            return [
                EditableWorkflowStep(
                    name: "ステップ1: 課題設定",
                    description: "解決したい課題を明確にする",
                    promptTemplate: "{problem}について、以下の項目を整理してください：\n1. 現状の問題点\n2. 理想的な状態\n3. 達成したい目標",
                    inputFields: [
                        EditableInputField(label: "problem", placeholder: "課題", required: true)
                    ],
                    requireUserPaste: false
                ),
                EditableWorkflowStep(
                    name: "ステップ2: アイデア発想",
                    description: "解決策のアイデアを出す",
                    promptTemplate: "以下の課題に対して、5つの異なるアプローチで解決策を提案してください：\n\n{problem_definition}",
                    inputFields: [
                        EditableInputField(label: "problem_definition", placeholder: "課題定義", required: true)
                    ],
                    requireUserPaste: true
                ),
                EditableWorkflowStep(
                    name: "ステップ3: 評価",
                    description: "各アイデアを評価する",
                    promptTemplate: "以下のアイデアを、実現可能性・効果・コストの観点で評価してください：\n\n{ideas}",
                    inputFields: [
                        EditableInputField(label: "ideas", placeholder: "アイデア一覧", required: true)
                    ],
                    requireUserPaste: true
                ),
                EditableWorkflowStep(
                    name: "ステップ4: 実行計画",
                    description: "最良のアイデアの実行計画を立てる",
                    promptTemplate: "以下の評価結果を基に、最も優れたアイデアの具体的な実行計画を作成してください：\n\n{evaluation}\n\nタイムライン、必要リソース、マイルストーンを含めてください。",
                    inputFields: [
                        EditableInputField(label: "evaluation", placeholder: "評価結果", required: true)
                    ],
                    requireUserPaste: true
                )
            ]
        case 5:
            return [
                EditableWorkflowStep(
                    name: "ステップ1: リサーチ",
                    description: "テーマについて調査する",
                    promptTemplate: "{theme}について、以下の観点でリサーチしてください：\n1. 背景と歴史\n2. 現在のトレンド\n3. 主要なプレイヤー\n4. 課題と機会",
                    inputFields: [
                        EditableInputField(label: "theme", placeholder: "テーマ", required: true)
                    ],
                    requireUserPaste: false
                ),
                EditableWorkflowStep(
                    name: "ステップ2: インサイト抽出",
                    description: "重要な洞察を抽出する",
                    promptTemplate: "以下のリサーチ結果から、重要なインサイトを5つ抽出してください：\n\n{research}",
                    inputFields: [
                        EditableInputField(label: "research", placeholder: "リサーチ結果", required: true)
                    ],
                    requireUserPaste: true
                ),
                EditableWorkflowStep(
                    name: "ステップ3: 戦略立案",
                    description: "戦略を策定する",
                    promptTemplate: "以下のインサイトを基に、{target}のための戦略を立案してください：\n\n{insights}",
                    inputFields: [
                        EditableInputField(label: "target", placeholder: "ターゲット", required: true),
                        EditableInputField(label: "insights", placeholder: "インサイト", required: true)
                    ],
                    requireUserPaste: true
                ),
                EditableWorkflowStep(
                    name: "ステップ4: アクションプラン",
                    description: "具体的な行動計画を作る",
                    promptTemplate: "以下の戦略を実行するための、具体的なアクションプランを作成してください：\n\n{strategy}\n\n3ヶ月、6ヶ月、12ヶ月のマイルストーンを含めてください。",
                    inputFields: [
                        EditableInputField(label: "strategy", placeholder: "戦略", required: true)
                    ],
                    requireUserPaste: true
                ),
                EditableWorkflowStep(
                    name: "ステップ5: リスク分析",
                    description: "リスクと対策を検討する",
                    promptTemplate: "以下のアクションプランに対して、考えられるリスクとその対策を分析してください：\n\n{action_plan}\n\n各リスクに対して、発生確率と影響度も評価してください。",
                    inputFields: [
                        EditableInputField(label: "action_plan", placeholder: "アクションプラン", required: true)
                    ],
                    requireUserPaste: true
                )
            ]
        default:
            return []
        }
    }
}

// Extension for sheet with item binding
extension Int: @retroactive Identifiable {
    public var id: Int { self }
}

#Preview {
    CreateWorkflowView()
        .environmentObject(PromptStore())
}
