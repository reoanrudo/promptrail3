//
//  CommunityDetailView.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import SwiftUI

struct CommunityDetailView: View {
    let template: CommunityTemplate
    @EnvironmentObject var store: PromptStore
    @State private var showCopiedAlert = false
    @State private var showReportSheet = false
    @State private var showSavedAlert = false
    @State private var isDescriptionExpanded = false
    @State private var variableValues: [String: String] = [:]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PRSpacing.md) {
                // タイトルセクション
                VStack(alignment: .leading, spacing: PRSpacing.sm) {
                    Text(template.title)
                        .font(PRTypography.displayMedium)
                        .foregroundColor(.prGray100)

                    // 投稿者・日付
                    HStack(spacing: PRSpacing.sm) {
                        Text("@\(template.authorName)")
                            .font(PRTypography.labelMedium)
                            .foregroundColor(.prGray60)

                        Text("•")
                            .foregroundColor(.prGray40)

                        if let category = store.category(for: template.categoryId) {
                            Text(category.name)
                                .font(PRTypography.labelSmall)
                                .foregroundColor(.prCategoryBlue)
                        }

                        Text("•")
                            .foregroundColor(.prGray40)

                        Text(formatDate(template.createdAt))
                            .font(PRTypography.labelSmall)
                            .foregroundColor(.prGray40)
                    }

                    // 統計
                    HStack(spacing: PRSpacing.md) {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.prCoral)
                            Text("\(template.likeCount)")
                                .font(PRTypography.labelSmall)
                                .foregroundColor(.prGray60)
                        }

                        HStack(spacing: 4) {
                            Image(systemName: "doc.on.doc.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.prCategoryBlue)
                            Text("\(template.useCount)")
                                .font(PRTypography.labelSmall)
                                .foregroundColor(.prGray60)
                        }
                    }
                }
                .padding(.horizontal, PRSpacing.md)

                // 1. 説明欄（アコーディオン）
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isDescriptionExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: "book.closed.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.prOrange)
                            Text("説明を見る")
                                .font(PRTypography.bodyMedium)
                                .foregroundColor(.prGray100)
                            Spacer()
                            Image(systemName: isDescriptionExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12))
                                .foregroundColor(.prGray40)
                        }
                        .padding(PRSpacing.md)
                        .background(Color.white)
                    }

                    if isDescriptionExpanded {
                        Text(template.description)
                            .font(PRTypography.bodySmall)
                            .foregroundColor(.prGray60)
                            .padding(.horizontal, PRSpacing.md)
                            .padding(.bottom, PRSpacing.md)
                            .background(Color.white)
                    }
                }
                .cornerRadius(PRRadius.md)
                .padding(.horizontal, PRSpacing.md)

                // 2. 変数入力セクション
                if !template.variables.isEmpty {
                    VStack(alignment: .leading, spacing: PRSpacing.sm) {
                        Text("変数入力")
                            .font(PRTypography.headlineSmall)
                            .foregroundColor(.prGray100)
                            .padding(.horizontal, PRSpacing.md)

                        VStack(spacing: PRSpacing.sm) {
                            ForEach(template.templateVariables.sorted(by: { $0.order < $1.order })) { variable in
                                CommunityVariableInputField(
                                    variable: variable,
                                    value: binding(for: variable.variableName)
                                )
                            }
                        }
                        .padding(PRSpacing.md)
                        .background(Color.white)
                        .cornerRadius(PRRadius.md)
                        .padding(.horizontal, PRSpacing.md)
                    }
                }

                // 3. プロンプト本文
                VStack(alignment: .leading, spacing: PRSpacing.sm) {
                    HStack {
                        Text("プロンプト本文")
                            .font(PRTypography.headlineSmall)
                            .foregroundColor(.prGray100)

                        Spacer()
                    }
                    .padding(.horizontal, PRSpacing.md)

                    Text(filledPromptBody)
                        .font(PRTypography.code)
                        .padding(PRSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.prGray5)
                        .cornerRadius(PRRadius.sm)
                        .padding(.horizontal, PRSpacing.md)
                }

                // タグ
                if !template.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: PRSpacing.xs) {
                            ForEach(template.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(PRTypography.labelSmall)
                                    .foregroundColor(.prGray60)
                                    .padding(.horizontal, PRSpacing.xs)
                                    .padding(.vertical, 4)
                                    .background(Color.prGray5)
                                    .cornerRadius(PRRadius.xs)
                            }
                        }
                        .padding(.horizontal, PRSpacing.md)
                    }
                }

                // アクションボタンバー
                HStack(spacing: PRSpacing.sm) {
                    // 使うボタン
                    Button(action: {
                        if validateRequiredVariables() {
                            copyPromptBody()
                            store.recordTemplateUsage(template.id)
                        }
                    }) {
                        Text("使う")
                    }
                    .buttonStyle(PRPrimaryButtonStyle())
                    .frame(maxWidth: .infinity)

                    // いいねボタン
                    Button(action: {
                        store.toggleTemplateLike(template.id)
                    }) {
                        Image(systemName: store.isTemplateLiked(template.id) ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundColor(store.isTemplateLiked(template.id) ? .prCoral : .prGray60)
                    }
                    .frame(width: 52, height: 52)
                    .background(Color.white)
                    .cornerRadius(PRRadius.md)

                    // 複製してマイページへボタン
                    Button(action: {
                        store.duplicateCommunityTemplate(template)
                        showSavedAlert = true
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 18))
                            .foregroundColor(.prGray60)
                    }
                    .frame(width: 52, height: 52)
                    .background(Color.white)
                    .cornerRadius(PRRadius.md)
                }
                .padding(.horizontal, PRSpacing.md)
            }
            .padding(.vertical, PRSpacing.md)
            .padding(.bottom, 80)
        }
        .background(Color.prGray5)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    ShareLink(item: template.body) {
                        Label("共有", systemImage: "square.and.arrow.up")
                    }

                    Button(action: { showReportSheet = true }) {
                        Label("通報", systemImage: "exclamationmark.triangle")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.prGray60)
                }
            }
        }
        .sheet(isPresented: $showReportSheet) {
            ReportView(templateId: template.id)
        }
        .alert("コピーしました", isPresented: $showCopiedAlert) {
            Button("OK", role: .cancel) {}
        }
        .alert("複製しました", isPresented: $showSavedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("マイページから編集して使えます")
        }
        .onAppear {
            initializeVariableValues()
        }
    }

    // MARK: - Helpers

    private func binding(for variableName: String) -> Binding<String> {
        Binding(
            get: { variableValues[variableName] ?? "" },
            set: { variableValues[variableName] = $0 }
        )
    }

    private func initializeVariableValues() {
        for variable in template.templateVariables {
            if let defaultValue = variable.defaultValue, !defaultValue.isEmpty {
                variableValues[variable.variableName] = defaultValue
            } else {
                variableValues[variable.variableName] = ""
            }
        }
    }

    private var filledPromptBody: AttributedString {
        var result = template.body

        // 変数を埋め込む
        for variable in template.templateVariables {
            let value = variableValues[variable.variableName] ?? ""
            if !value.isEmpty {
                result = result.replacingOccurrences(
                    of: "{\(variable.variableName)}",
                    with: value
                )
            }
        }

        // 残りの変数をハイライト
        var attributed = AttributedString(result)
        let pattern = "\\{([^}]+)\\}"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return attributed
        }

        let nsString = result as NSString
        let matches = regex.matches(in: result, range: NSRange(location: 0, length: nsString.length))

        for match in matches.reversed() {
            if let range = Range(match.range, in: attributed) {
                attributed[range].foregroundColor = .prOrange
                attributed[range].font = PRTypography.code.bold()
            }
        }

        return attributed
    }

    private func validateRequiredVariables() -> Bool {
        for variable in template.templateVariables where variable.required {
            let value = variableValues[variable.variableName] ?? ""
            if value.isEmpty {
                // TODO: エラー表示
                return false
            }
        }
        return true
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }

    private func copyPromptBody() {
        var result = template.body
        for variable in template.templateVariables {
            let value = variableValues[variable.variableName] ?? ""
            if !value.isEmpty {
                result = result.replacingOccurrences(
                    of: "{\(variable.variableName)}",
                    with: value
                )
            }
        }
        copyToClipboard(result)
        showCopiedAlert = true
    }

    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }
}

// MARK: - Community Variable Input Field
struct CommunityVariableInputField: View {
    let variable: TemplateVariable
    @Binding var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: PRSpacing.xs) {
            HStack {
                Text(variable.label)
                    .font(PRTypography.labelMedium)
                    .foregroundColor(.prGray80)

                if variable.required {
                    Text("*")
                        .font(PRTypography.labelMedium)
                        .foregroundColor(.prCoral)
                }
            }

            if let description = variable.description, !description.isEmpty {
                Text(description)
                    .font(PRTypography.labelSmall)
                    .foregroundColor(.prGray40)
            }

            switch variable.type {
            case .text:
                TextField(variable.placeholder ?? "", text: $value)
                    .textFieldStyle(.roundedBorder)

            case .number:
                TextField(variable.placeholder ?? "", text: $value)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)

            case .select:
                if let options = variable.options {
                    Picker(variable.label, selection: $value) {
                        Text("選択してください").tag("")
                        ForEach(options, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, PRSpacing.sm)
                    .padding(.vertical, PRSpacing.xs)
                    .background(Color.prGray5)
                    .cornerRadius(PRRadius.sm)
                }

            case .textarea:
                TextEditor(text: $value)
                    .frame(minHeight: 80)
                    .padding(PRSpacing.xs)
                    .background(Color.prGray5)
                    .cornerRadius(PRRadius.sm)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CommunityDetailView(
            template: CommunityTemplate(
                userId: UUID(),
                title: "効果的なレポート作成プロンプト",
                body: "あなたは経験豊富なビジネスライターです。\n\n## ゴール\n{theme}についてレポートを作成してください。\n\n## ターゲット\n{target}向けに書いてください。\n\n## トーン\n{tone}な文体で書いてください。\n\n## 文字数\n{length}文字程度で書いてください。",
                description: "このテンプレは、論理的で読みやすいレポートを作成するためのものです。\n\n【使い方のコツ】\n• テーマは具体的に書く\n• トーンは読者に合わせて選ぶ",
                categoryId: UUID(),
                taskId: UUID(),
                tags: ["ビジネス", "レポート", "ライティング"],
                templateVariables: [
                    TemplateVariable(variableName: "theme", label: "レポートのテーマ", placeholder: "例：効率的な会議の進め方", required: true, order: 1),
                    TemplateVariable(variableName: "target", label: "読んでほしい人", placeholder: "例：新入社員", order: 2),
                    TemplateVariable(variableName: "tone", label: "文章の雰囲気", type: .select, options: ["カジュアル", "フォーマル", "ビジネス"], order: 3),
                    TemplateVariable(variableName: "length", label: "文字数", type: .number, placeholder: "500", defaultValue: "500", order: 4)
                ],
                likeCount: 342,
                useCount: 1567,
                authorName: "ビジネスライター"
            )
        )
    }
    .environmentObject(PromptStore())
}
