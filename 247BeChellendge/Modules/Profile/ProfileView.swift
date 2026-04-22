import SwiftUI
import SwiftData
import PhotosUI
import UserNotifications

struct ProfileView: View {
    var context = AppDataContainer.shared.container.mainContext
    
    @State private var user: UserModel? = nil
    
    @State private var editingName = false
    @State private var nameInput: String = ""
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var notifications: Bool = false
    @State private var showNewGameAlert = false
    @State private var showNotifDeniedAlert = false
    
    private var levelProgress: Double {
        guard let user else { return 0 }
        let maxPoints = 1000.0
        return min(Double(user.points) / maxPoints, 1.0)
    }
    
    private var levelPercent: Int { Int(levelProgress * 100) }
    private let totalAchievements = 30
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Text("Profile")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.red)
                Spacer()
                Image(.appLogo)
                    .resizable().scaledToFit().frame(width: 40.fitW)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
            
            if let user {
                VStack(spacing: 0) {
                    
                    // Avatar
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        ZStack(alignment: .bottomTrailing) {
                            if let data = user.photo, let img = UIImage(data: data) {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(
                                        LinearGradient(colors: [.red, .purple],
                                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                                        lineWidth: 3))
                            } else {
                                Circle()
                                    .fill(
                                        LinearGradient(colors: [.purple, Color(red: 0.45, green: 0.3, blue: 0.9)],
                                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 44))
                                            .foregroundColor(.white)
                                    )
                                    .overlay(Circle().stroke(
                                        LinearGradient(colors: [.red, .purple],
                                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                                        lineWidth: 3))
                            }
                            
                            Circle()
                                .fill(Color.white)
                                .frame(width: 26, height: 26)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                )
                                .shadow(radius: 2)
                        }
                    }
                    .onChange(of: photoItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                user.photo = data
                                try? context.save()
                                self.user = user
                            }
                        }
                    }
                    .padding(.top, 24)
                    
                    // Name
                    HStack(spacing: 6) {
                        if editingName {
                            TextField("Name", text: $nameInput)
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(Color(red: 0.9, green: 0.3, blue: 0.1))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 200)
                                .onSubmit { commitName(user) }
                        } else {
                            Text(user.name)
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(Color(red: 0.9, green: 0.3, blue: 0.1))
                        }
                        
                        Button {
                            if editingName {
                                commitName(user)
                            } else {
                                nameInput = user.name
                                editingName = true
                            }
                        } label: {
                            Image(systemName: editingName ? "checkmark" : "pencil")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 0.9, green: 0.3, blue: 0.1))
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    
                    Divider().padding(.horizontal, 20)
                    
                    // Level Progress
                    VStack(spacing: 8) {
                        HStack {
                            Text("Level Progress")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            Spacer()
                            Text("\(levelPercent)%")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(UIColor.systemGray5))
                                    .frame(height: 12)
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(red: 0.45, green: 0.2, blue: 0.9), Color(red: 0.25, green: 0.5, blue: 0.95)],
                                            startPoint: .leading, endPoint: .trailing
                                        )
                                    )
                                    .frame(width: max(geo.size.width * levelProgress, 12), height: 12)
                            }
                        }
                        .frame(height: 12)
                        
                        HStack {
                            Text("Beginner").font(.caption).foregroundColor(.gray)
                            Spacer()
                            Text("Legend").font(.caption).foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    
                    Divider().padding(.horizontal, 20)
                    
                    // Achievements
                    HStack {
                        Text("Achievements")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.9, green: 0.3, blue: 0.1))
                        Spacer()
                        Text("\(user.countUnlockedAchievements())/\(totalAchievements)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.45, green: 0.2, blue: 0.9))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    
                    Divider().padding(.horizontal, 20)
                    
                    // Notifications
                    HStack {
                        Text("Notifications")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.45, green: 0.2, blue: 0.9))
                        Spacer()
                        Toggle("", isOn: $notifications)
                            .labelsHidden()
                            .onChange(of: notifications) { _, newValue in
                                if newValue { handleNotificationToggle() }
                            }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .padding(.bottom, 8)
                }
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 4)
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            Button {
                showNewGameAlert = true
            } label: {
                Text("Start a new game")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(RoundedRectangle(cornerRadius: 18).fill(Color(red: 0.9, green: 0.3, blue: 0.1)))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 120)
        }
        .bg()
        .hideKeyboardOnTap()
        .onAppear {
            loadUser()
            checkNotificationStatus()
        }
        .alert("Are you sure?", isPresented: $showNewGameAlert) {
            Button("Delete All & Restart", role: .destructive) { startNewGame() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All data will be permanently deleted. This action cannot be undone.")
        }
        .alert("Notifications Disabled", isPresented: $showNotifDeniedAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { notifications = false }
        } message: {
            Text("Please enable notifications in Settings to use this feature.")
        }
    }
    
    // MARK: - Load / Save
    
    private func loadUser() {
        let descriptor = FetchDescriptor<UserModel>()
        if let found = try? context.fetch(descriptor), let existing = found.first {
            user = existing
        } else {
            let fresh = UserModel()
            context.insert(fresh)
            try? context.save()
            user = fresh
        }
    }
    
    private func commitName(_ user: UserModel) {
        let trimmed = nameInput.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            user.name = trimmed
            try? context.save()
            self.user = user
        }
        editingName = false
    }
    
    // MARK: - Notifications
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notifications = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func handleNotificationToggle() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                        DispatchQueue.main.async { notifications = granted }
                    }
                case .denied:
                    notifications = false
                    showNotifDeniedAlert = true
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - New Game
    
    private func startNewGame() {
        let challengeDescriptor = FetchDescriptor<ChallengeModel>()
        if let allChallenges = try? context.fetch(challengeDescriptor) {
            allChallenges.forEach { context.delete($0) }
        }
        let userDescriptor = FetchDescriptor<UserModel>()
        if let allUsers = try? context.fetch(userDescriptor) {
            allUsers.forEach { context.delete($0) }
        }
        try? context.save()
        
        let fresh = UserModel()
        context.insert(fresh)
        try? context.save()
        user = fresh
        notifications = false
    }
}
