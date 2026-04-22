import SwiftUI
import SwiftData
import Observation

// MARK: - Tab Model

enum AppTab {
    case home
    case stats
    case achieve
    case profile

    var title: String {
        switch self {
        case .home: return "Home"
        case .stats: return "Stats"
        case .achieve: return "Achieve"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .stats: return "chart.bar.fill"
        case .achieve: return "trophy.fill"
        case .profile: return "person.fill"
        }
    }
}

protocol TabDelegate: AnyObject {
    func selectTab(_ tab: AppTab)
}

@Observable
@MainActor
class TabViewModel {
    var selectedTab: AppTab = .home
}

extension TabViewModel: TabDelegate {
    func selectTab(_ tab: AppTab) {
        selectedTab = tab
    }
}

struct TabBarView: View {
    @Bindable var viewModel = TabViewModel()
    
    private let activeColor = Color(red: 0.92, green: 0.3, blue: 0.1)
    private let inactiveIconBg = Color(red: 0.86, green: 0.84, blue: 0.93)
    private let inactiveIcon = Color(red: 0.68, green: 0.65, blue: 0.82)
    private let inactiveLabel = Color(red: 0.15, green: 0.15, blue: 0.2)
    private let barBg = Color(red: 0.93, green: 0.93, blue: 0.97)

    @State var userModel: UserModel?
    var context = AppDataContainer.shared.container.mainContext
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch viewModel.selectedTab {
                case .home:
                    MainView(delegate: viewModel)
                        .padding(.top, 55.fitH)
                case .stats:
                    StatisticsView(user: userModel!)
                        .padding(.top, 55.fitH)
                case .achieve:
                    AchievementsView(user: userModel!)
                        .padding(.top, 55.fitH)
                case .profile:
                    ProfileView()
                        .padding(.top, 55.fitH)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()

            // Tab bar
            HStack(spacing: 0) {
                ForEach([AppTab.home, .stats, .achieve, .profile], id: \.title) { tab in
                    tabButton(tab)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 16)
            .padding(.bottom, 28)
            .background(
                barBg
                    .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: -4)
            )
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            loadOrCreateUser()
        }
    }
    
    private func loadOrCreateUser() {
        let descriptor = FetchDescriptor<UserModel>()
        let users = try? context.fetch(descriptor)
        
        if let existingUser = users?.first {
            userModel = existingUser
        } else {
            let newUser = UserModel()
            context.insert(newUser)
            try? context.save()
            userModel = newUser
        }
    }

    @ViewBuilder
    private func tabButton(_ tab: AppTab) -> some View {
        let isSelected = viewModel.selectedTab == tab

        Button {
            viewModel.selectedTab = tab
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? activeColor : inactiveIconBg)
                        .frame(width: 42, height: 42)

                    Image(systemName: tab.icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(isSelected ? .white : inactiveIcon)
                }

                Text(tab.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(inactiveLabel)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Rounded Corner Helper

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
