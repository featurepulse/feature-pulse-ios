import SwiftUI

struct FeaturePulseToolbarMenus: View {
    @Binding var selectedTab: FeaturePulseView.FeatureTab
    @Binding var sortOption: FeaturePulseView.SortOption?
    let configFetched: Bool

    var body: some View {
        tabMenu

        if selectedTab != .completed {
            sortMenu
        }
    }

    private var tabMenu: some View {
        Menu {
            ForEach(FeaturePulseView.FeatureTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Label {
                        Text(tab.label)
                    } icon: {
                        if selectedTab == tab {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(selectedTab.label)
                #if os(iOS)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8))
                        .opacity(0.5)
                #endif
            }
            .padding(.horizontal, 4)
        }
        .disabled(!configFetched)
    }

    private var sortMenu: some View {
        Menu {
            ForEach(FeaturePulseView.SortOption.allCases, id: \.self) { option in
                Button {
                    sortOption = option
                } label: {
                    Label(option.label, systemImage: sortOption == option ? "checkmark" : option.systemImage)
                }
            }

            if sortOption != nil {
                Divider()
                Button(L10n.sortReset, role: .destructive) {
                    sortOption = nil
                }
            }
        } label: {
            #if os(macOS)
                HStack(spacing: 4) {
                    Image(systemName: sortOption?.systemImage ?? "arrow.up.arrow.down")
                    Text(sortOption?.label ?? L10n.sort)
                }
                .padding(.horizontal, 4)
            #else
                Image(systemName: sortOption?.systemImage ?? "arrow.up.arrow.down")
            #endif
        }
        .disabled(!configFetched)
    }
}
