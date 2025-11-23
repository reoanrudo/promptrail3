//
//  CustomTabBar.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/20.
//

import SwiftUI

// MARK: - Tab Item
enum MainTab: Int, CaseIterable {
    case community = 0
    case post = 1  // ダミータブ（実際は中央ボタン）
    case myPage = 2

    var title: String {
        switch self {
        case .community: return "みんなのテンプレ"
        case .post: return ""
        case .myPage: return "マイページ"
        }
    }

    var icon: String {
        switch self {
        case .community: return "rectangle.stack"
        case .post: return "plus"
        case .myPage: return "person"
        }
    }

    var selectedIcon: String {
        switch self {
        case .community: return "rectangle.stack.fill"
        case .post: return "plus"
        case .myPage: return "person.fill"
        }
    }
}

// MARK: - Custom Tab Bar View
struct CustomTabBarView: View {
    @EnvironmentObject var store: PromptStore
    @State private var selectedTab: MainTab = .community
    @State private var showCreateSheet = false
    @State private var showSettings = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // メインコンテンツ
            Group {
                switch selectedTab {
                case .community:
                    CommunityTemplatesView()
                case .post:
                    EmptyView()
                case .myPage:
                    MyPromptsView()
                }
            }
            .onChange(of: store.shouldSwitchToMyPage) { oldValue, newValue in
                if newValue {
                    selectedTab = .myPage
                    store.shouldSwitchToMyPage = false
                }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear
                    .frame(height: 80)
            }

            // カスタムタブバー
            TabBarContent(
                selectedTab: $selectedTab,
                showCreateSheet: $showCreateSheet,
                showSettings: $showSettings
            )
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateTemplateTypeSelectionView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
            .environmentObject(store)
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let tab: MainTab
    @Binding var selectedTab: MainTab
    @Binding var showCreateSheet: Bool

    var body: some View {
        Button(action: {
            if tab == .post {
                showCreateSheet = true
            } else {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 22))
                    .foregroundColor(selectedTab == tab ? .prOrange : Color.prTextTertiary)

                if !tab.title.isEmpty {
                    Text(tab.title)
                        .font(PRTypography.labelSmall)
                        .foregroundColor(selectedTab == tab ? .prOrange : Color.prTextTertiary)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Tab Bar Container
private struct TabBarContent: View {
    @Binding var selectedTab: MainTab
    @Binding var showCreateSheet: Bool
    @Binding var showSettings: Bool

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 0) {
                TabBarButton(
                    tab: .community,
                    selectedTab: $selectedTab,
                    showCreateSheet: $showCreateSheet
                )

                Spacer()
                    .frame(width: 80)

                TabBarButton(
                    tab: .myPage,
                    selectedTab: $selectedTab,
                    showCreateSheet: $showCreateSheet
                )
            }
            .frame(height: 60)
            .padding(.horizontal)
            .background(Color.prCardBackground)
        }
        .background(
            Color.prCardBackground
                .shadow(color: .black.opacity(0.05), radius: 6, y: -2)
        )
        .overlay(
            Button(action: { showCreateSheet = true }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.prOrange, .prOrangeLight],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .prShadow(PRShadow.orange)

                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -20)
        )
        .overlay(alignment: .bottomTrailing) {
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.prGray80.opacity(0.9))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 60)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    CustomTabBarView()
        .environmentObject(PromptStore())
}
