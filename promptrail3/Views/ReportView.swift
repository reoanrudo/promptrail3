//
//  ReportView.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import SwiftUI

struct ReportView: View {
    let templateId: UUID
    @EnvironmentObject var store: PromptStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedReason: ReportReason?
    @State private var detail = ""
    @State private var showSuccessAlert = false

    var body: some View {
        NavigationStack {
            Form {
                // 通報理由
                Section {
                    ForEach(ReportReason.allCases, id: \.self) { reason in
                        Button(action: { selectedReason = reason }) {
                            HStack {
                                Text(reason.rawValue)
                                    .foregroundColor(.prGray100)

                                Spacer()

                                if selectedReason == reason {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.prOrange)
                                }
                            }
                        }
                    }
                } header: {
                    Text("通報理由を選択")
                }

                // 詳細（任意）
                Section {
                    TextEditor(text: $detail)
                        .frame(minHeight: 100)
                } header: {
                    Text("詳細（任意）")
                } footer: {
                    Text("問題の内容を具体的に教えてください")
                }

                // 注意事項
                Section {
                    VStack(alignment: .leading, spacing: PRSpacing.sm) {
                        HStack(alignment: .top, spacing: PRSpacing.sm) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.prCategoryBlue)
                            Text("通報は匿名で処理されます")
                                .font(PRTypography.bodySmall)
                                .foregroundColor(.prGray60)
                        }

                        HStack(alignment: .top, spacing: PRSpacing.sm) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.prCategoryBlue)
                            Text("運営が確認し、24〜48時間以内に対応します")
                                .font(PRTypography.bodySmall)
                                .foregroundColor(.prGray60)
                        }

                        HStack(alignment: .top, spacing: PRSpacing.sm) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.prCoral)
                            Text("虚偽の通報は利用規約違反となります")
                                .font(PRTypography.bodySmall)
                                .foregroundColor(.prGray60)
                        }
                    }
                    .padding(.vertical, PRSpacing.xs)
                }
            }
            .navigationTitle("通報")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("送信") {
                        submitReport()
                    }
                    .disabled(selectedReason == nil)
                    .foregroundColor(selectedReason != nil ? .prOrange : .prGray40)
                }
            }
            .alert("通報を送信しました", isPresented: $showSuccessAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text("ご協力ありがとうございます。運営が内容を確認いたします。")
            }
        }
    }

    private func submitReport() {
        guard let reason = selectedReason else { return }

        // TODO: 実際のAPI呼び出しを実装
        // 現時点ではローカルで通報を記録するのみ
        let report = TemplateReport(
            templateId: templateId,
            reporterUserId: store.currentUserId,
            reason: reason,
            detail: detail.isEmpty ? nil : detail
        )

        // デバッグ用にコンソールに出力
        print("Report submitted: \(report)")

        showSuccessAlert = true
    }
}

#Preview {
    ReportView(templateId: UUID())
        .environmentObject(PromptStore())
}
