import SwiftUI
import SwiftData

struct MainView: View {
    @State private var userModel: UserModel?
    @State private var currentChallenge: ChallengeModel?
    @State private var challengeState: ChallengeState = .selection
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer?
    @State private var totalDuration: TimeInterval = 0
    @State private var showAchievements: Bool = false
    @State private var showStatistics: Bool = false
    @State private var timerStartDate: Date?
    @State private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    var isSE: Bool { UIScreen.isIphoneSEClassic }
    
    weak var delegate: TabDelegate?
    
    private let context = AppDataContainer.shared.container.mainContext
    
    enum ChallengeState {
        case selection
        case ready
        case inProgress
        case completed
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                if challengeState != .completed {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("24/7 Challenge")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.red)
                            
                            Text("Your life is a game")
                                .font(.system(size: 17))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Image(.appLogo)
                            .resizable().scaledToFit().frame(width: 40.fitW)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                }
                
                ScrollView {
                    switch challengeState {
                    case .selection:
                        if let challenge = currentChallenge, let user = userModel {
                            VStack(spacing: 20) {
                                ChallengeCardView(challenge: challenge, skipsRemaining: user.countSkipsToday)
                                
                                VStack(spacing: 12) {
                                    Button {
                                        acceptChallenge()
                                    } label: {
                                        Text("Accept Challenge")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 56)
                                            .background(Color.red)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                    }
                                    
                                    Button {
                                        skipChallenge()
                                    } label: {
                                        Text("Skip")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 56)
                                            .background(Color(hex: "E5E5E5"))
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .padding(.bottom, isSE ? 8.fitH : 0)
                                    }
                                    .disabled(user.countSkipsToday <= 0)
                                    .opacity(user.countSkipsToday <= 0 ? 0.5 : 1)
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                            }
                        } else {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        
                    case .ready, .inProgress:
                        if let challenge = currentChallenge {
                            ChallengeTimerView(
                                challenge: challenge,
                                timeRemaining: $timeRemaining,
                                totalDuration: totalDuration,
                                isRunning: challengeState == .inProgress,
                                onStart: {
                                    startTimer()
                                },
                                onComplete: {
                                    completeChallenge()
                                },
                                onGiveUp: {
                                    giveUpChallenge()
                                }
                            )
                        }
                        
                    case .completed:
                        CompletionView(
                            onBackToHome: {
                                resetToSelection()
                            },
                            onViewStats: {
                                delegate?.selectTab(.stats)
                            }
                        )
                    }
                    
                    Spacer(minLength: 120.fitH)
                }
            }
        }
        .bg()
        .fullScreenCover(isPresented: $showAchievements) {
            if let user = userModel {
                AchievementsView(user: user)
            }
        }
        .fullScreenCover(isPresented: $showStatistics) {
            if let user = userModel {
                StatisticsView(user: user)
            }
        }
        .onAppear {
            loadOrCreateUser()
            loadRandomChallenge()
            setupNotificationObservers()
        }
        .onDisappear {
            timer?.invalidate()
            removeNotificationObservers()
        }
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            handleAppBackground()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            handleAppForeground()
        }
    }
    
    private func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func handleAppBackground() {
        if challengeState == .inProgress, let startDate = timerStartDate {
            UserDefaults.standard.set(startDate.timeIntervalSince1970, forKey: "timerStartDate")
            UserDefaults.standard.set(totalDuration, forKey: "totalDuration")
            
            scheduleLocalNotification()
            
            backgroundTask = UIApplication.shared.beginBackgroundTask { [self] in
                endBackgroundTask()
            }
        }
    }
    
    private func handleAppForeground() {
        endBackgroundTask()
        
        if challengeState == .inProgress,
           let savedStartTime = UserDefaults.standard.object(forKey: "timerStartDate") as? TimeInterval,
           let savedTotalDuration = UserDefaults.standard.object(forKey: "totalDuration") as? TimeInterval {
            
            let startDate = Date(timeIntervalSince1970: savedStartTime)
            let elapsedTime = Date().timeIntervalSince(startDate)
            let newTimeRemaining = savedTotalDuration - elapsedTime
            
            if newTimeRemaining > 0 {
                timeRemaining = newTimeRemaining
            } else {
                timeRemaining = 0
                timer?.invalidate()
            }
            
            UserDefaults.standard.removeObject(forKey: "timerStartDate")
            UserDefaults.standard.removeObject(forKey: "totalDuration")
        }
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    private func scheduleLocalNotification() {
        guard timeRemaining > 0 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Challenge Complete!"
        content.body = "Your challenge timer has finished. Come back to complete it!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeRemaining, repeats: false)
        let request = UNNotificationRequest(identifier: "challengeComplete", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func loadOrCreateUser() {
        let descriptor = FetchDescriptor<UserModel>()
        let users = try? context.fetch(descriptor)
        
        if let existingUser = users?.first {
            userModel = existingUser
            checkAndResetSkips()
        } else {
            let newUser = UserModel()
            context.insert(newUser)
            try? context.save()
            userModel = newUser
        }
    }
    
    private func checkAndResetSkips() {
        guard let user = userModel else { return }
        
        let calendar = Calendar.current
        if !calendar.isDateInToday(user.currentDate) {
            user.countSkipsToday = 3
            user.currentDate = Date()
            user.consecutiveDaysWithoutSkip = 0
            try? context.save()
        }
    }
    
    private func loadRandomChallenge() {
        currentChallenge = ChallengeFactory.getRandomChallenge()
    }
    
    private func acceptChallenge() {
        guard let challenge = currentChallenge else { return }
        
        if challenge.isDeadline {
            timeRemaining = challenge.getRemainingTime()
        } else {
            timeRemaining = challenge.duration
        }
        
        totalDuration = timeRemaining
        challengeState = .ready
    }
    
    private func startTimer() {
        challengeState = .inProgress
        timerStartDate = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                if timeRemaining > 0 {
                    withAnimation {
                        timeRemaining -= 1
                    }
                } else {
                    timer?.invalidate()
                }
            }
        }
    }
    
    private func completeChallenge() {
        timer?.invalidate()
        timerStartDate = nil
        
        UserDefaults.standard.removeObject(forKey: "timerStartDate")
        UserDefaults.standard.removeObject(forKey: "totalDuration")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        guard let user = userModel, let challenge = currentChallenge else { return }
        
        user.points += 10
        user.completedChallendges.append(challenge)
        user.consecutiveDaysWithoutSkip += 1
        
        AchievementManager.updateStreak(user: user)
        AchievementManager.checkAndUpdateAchievements(user: user, completedChallenge: challenge)
        
        try? context.save()
        
        challengeState = .completed
    }
    
    private func giveUpChallenge() {
        timer?.invalidate()
        timerStartDate = nil
        
        UserDefaults.standard.removeObject(forKey: "timerStartDate")
        UserDefaults.standard.removeObject(forKey: "totalDuration")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        resetToSelection()
    }
    
    private func resetToSelection() {
        challengeState = .selection
        timeRemaining = 0
        totalDuration = 0
        loadRandomChallenge()
    }
    
    private func skipChallenge() {
        guard let user = userModel, user.countSkipsToday > 0 else { return }
        
        user.countSkipsToday -= 1
        user.consecutiveDaysWithoutSkip = 0
        try? context.save()
        
        loadRandomChallenge()
    }
}

struct ChallengeTimerView: View {
    let challenge: ChallengeModel
    @Binding var timeRemaining: TimeInterval
    let totalDuration: TimeInterval
    let isRunning: Bool
    let onStart: () -> Void
    let onComplete: () -> Void
    let onGiveUp: () -> Void
    var isSE: Bool { UIScreen.isIphoneSEClassic }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Spacer()
                        HStack(spacing: 6) {
                            Text(categoryEmoji)
                                .font(.system(size: 16))
                            Text(categoryName)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        Spacer()
                    }
                    
                    VStack(alignment: .center, spacing: 8) {
                        Text(challenge.name)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        
                        Text(challenge.descriptionChallendge)
                            .font(.system(size: 17))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 12)
                            .frame(width: 200, height: 200)
                        
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "5B7FFF"), Color(hex: "6B4FE8")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.5), value: progress)
                        
                        Text(formattedTime)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "6B4FE8"), Color(hex: "5B7FFF")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
                .padding(24)
                .background(categoryBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 20)
                
                VStack(spacing: 12) {
                    if !isRunning {
                        Button {
                            onStart()
                        } label: {
                            Text("Start Timer")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(hex: "6B4FE8"))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    } else {
                        Button {
                            onComplete()
                        } label: {
                            Text("Complete Challenge")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(timeRemaining == 0 ? Color(hex: "4CAF50") : Color(hex: "E5E5E5"))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(timeRemaining > 0)
                    }
                    
                    Button {
                        onGiveUp()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Give Up")
                                .font(.system(size: 18, weight: .medium))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "E5E5E5"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.bottom, isSE ? 8.fitH : 0)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 20)
        }
    }
    
    private var progress: CGFloat {
        guard totalDuration > 0 else { return 0 }
        return CGFloat(1 - (timeRemaining / totalDuration))
    }
    
    private var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var categoryEmoji: String {
        switch challenge.type {
        case .sport: return "⚽️"
        case .health: return "🍏"
        case .kids: return "🧸"
        case .relationships: return "❤️"
        case .family: return "🏠"
        case .social: return "🤝"
        case .study: return "📚"
        case .selfDev: return "🧠"
        }
    }
    
    private var categoryName: String {
        switch challenge.type {
        case .sport: return "Sport"
        case .health: return "Health"
        case .kids: return "Kids"
        case .relationships: return "Relationships"
        case .family: return "Family"
        case .social: return "Social"
        case .study: return "Study"
        case .selfDev: return "Self-Dev"
        }
    }
    
    private var categoryBackgroundColor: Color {
        switch challenge.type {
        case .sport: return Color(hex: "FFE5E5")
        case .health: return Color(hex: "E8F5E9")
        case .kids: return Color(hex: "FFF3E0")
        case .relationships: return Color(hex: "FCE4EC")
        case .family: return Color(hex: "F3E5F5")
        case .social: return Color(hex: "E1F5FE")
        case .study: return Color(hex: "FFF9C4")
        case .selfDev: return Color(hex: "F5F5F5")
        }
    }
}

struct CompletionView: View {
    let onBackToHome: () -> Void
    let onViewStats: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "6B4FE8"), Color(hex: "5B7FFF")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "star.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Challenge")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.red)
                        
                        Text("Accepted!")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.red)
                        
                        Text("You became stronger")
                            .font(.system(size: 17))
                            .foregroundColor(.gray)
                    }
                    
                    VStack(spacing: 16) {
                        Text("Reward")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                        
                        Text("+10")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "6B4FE8"), Color(hex: "5B7FFF")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Power Points")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Level Progress")
                                    .font(.system(size: 13))
                                    .foregroundColor(.black)
                                Spacer()
                                Text("65%")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(hex: "E5E5E5"))
                                        .frame(height: 8)
                                    
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "6B4FE8"), Color(hex: "5B7FFF")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * 0.65, height: 8)
                                }
                            }
                            .frame(height: 8)
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button {
                        onBackToHome()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 18))
                            Text("Back to Home")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "6B4FE8"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    Button {
                        onViewStats()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 18))
                            Text("View Statistics")
                                .font(.system(size: 18, weight: .medium))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "E5E5E5"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

struct ChallengeCardView: View {
    let challenge: ChallengeModel
    let skipsRemaining: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                HStack(spacing: 6) {
                    Text(categoryEmoji)
                        .font(.system(size: 16))
                    Text(categoryName)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Spacer()
                
                Text("\(skipsRemaining)/3 skips")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(challenge.name)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                
                Text(challenge.descriptionChallendge)
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
            }
            
            HStack(spacing: 6) {
                Image(systemName: "timer")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "6B4FE8"))
                Text("Duration")
                    .font(.system(size: 15))
                    .foregroundColor(.black)
                Text(durationText)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "6B4FE8"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            HStack(spacing: 4) {
                Text("Reward:")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                Text("+10 Power Points")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "6B4FE8"))
            }
            
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(categoryBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var categoryEmoji: String {
        switch challenge.type {
        case .sport: return "⚽️"
        case .health: return "🍏"
        case .kids: return "🧸"
        case .relationships: return "❤️"
        case .family: return "🏠"
        case .social: return "🤝"
        case .study: return "📚"
        case .selfDev: return "🧠"
        }
    }
    
    private var categoryName: String {
        switch challenge.type {
        case .sport: return "Sport"
        case .health: return "Health"
        case .kids: return "Kids"
        case .relationships: return "Relationships"
        case .family: return "Family"
        case .social: return "Social"
        case .study: return "Study"
        case .selfDev: return "Self-Dev"
        }
    }
    
    private var categoryBackgroundColor: Color {
        switch challenge.type {
        case .sport: return Color(hex: "FFE5E5")
        case .health: return Color(hex: "E8F5E9")
        case .kids: return Color(hex: "FFF3E0")
        case .relationships: return Color(hex: "FCE4EC")
        case .family: return Color(hex: "F3E5F5")
        case .social: return Color(hex: "E1F5FE")
        case .study: return Color(hex: "FFF9C4")
        case .selfDev: return Color(hex: "F5F5F5")
        }
    }
    
    private var durationText: String {
        if challenge.isDeadline {
            return challenge.getFormattedRemainingTime()
        } else {
            let minutes = Int(challenge.duration) / 60
            let seconds = Int(challenge.duration) % 60
            
            if minutes > 0 && seconds > 0 {
                return "\(minutes) min \(seconds) sec"
            } else if minutes > 0 {
                return "\(minutes) min"
            } else {
                return "\(seconds) sec"
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    MainView()
}
