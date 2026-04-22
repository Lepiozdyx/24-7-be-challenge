import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Environment(\.dismiss) var dismiss
    let user: UserModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Achievements")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.red)
                    
                    Text("\(user.countUnlockedAchievements()) of 30 unlocked")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(.appLogo)
                    .resizable().scaledToFit().frame(width: 40.fitW)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(getAllAchievements(), id: \.name) { achievement in
                        AchievementCard(achievement: achievement, isUnlocked: achievement.isUnlocked)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                Spacer(minLength: 100.fitH)
            }
        }
        .bg()
    }
    
    private func getAllAchievements() -> [Achievement] {
        return [
            Achievement(name: "First Step", description: "Complete 1 challenge", icon: "i1", isUnlocked: user.firstStep),
            Achievement(name: "Week Streak", description: "7 days in a row", icon: "i2", isUnlocked: user.weekStreak),
            Achievement(name: "Month Discipline", description: "30 days active", icon: "i3", isUnlocked: user.monthDiscipline),
            Achievement(name: "Quarter Power", description: "90 days active", icon: "i4", isUnlocked: user.quarterPower),
            Achievement(name: "Year Evolution", description: "365 days active", icon: "i5", isUnlocked: user.yearEvolution),
            Achievement(name: "Athlete", description: "10 sport challenges", icon: "i6", isUnlocked: user.athlete),
            Achievement(name: "Iron", description: "20 sport challenges", icon: "i7", isUnlocked: user.iron),
            Achievement(name: "Loving", description: "10 relationship challenges", icon: "i8", isUnlocked: user.loving),
            Achievement(name: "Romantic", description: "20 relationship challenges", icon: "i9", isUnlocked: user.romantic),
            Achievement(name: "Family Person", description: "10 family challenges", icon: "i10", isUnlocked: user.familyPerson),
            Achievement(name: "Caring", description: "30 family challenges", icon: "i11", isUnlocked: user.caring),
            Achievement(name: "Parent", description: "20 kids challenges", icon: "i12", isUnlocked: user.parent),
            Achievement(name: "Mentor", description: "50 kids challenges", icon: "i13", isUnlocked: user.mentor),
            Achievement(name: "Scholar", description: "15 study challenges", icon: "i14", isUnlocked: user.scholar),
            Achievement(name: "Master", description: "40 study challenges", icon: "i15", isUnlocked: user.master),
            Achievement(name: "Philosopher", description: "20 self-dev challenges", icon: "i16", isUnlocked: user.philosopher),
            Achievement(name: "Sage", description: "50 self-dev challenges", icon: "i17", isUnlocked: user.sage),
            Achievement(name: "Healthy", description: "20 health challenges", icon: "i18", isUnlocked: user.healthy),
            Achievement(name: "Long-liver", description: "60 health challenges", icon: "i19", isUnlocked: user.longLiver),
            Achievement(name: "Friend", description: "15 social challenges", icon: "i20", isUnlocked: user.friend),
            Achievement(name: "Hero", description: "40 social challenges", icon: "i21", isUnlocked: user.hero),
            Achievement(name: "Balance", description: "5 in each category", icon: "i22", isUnlocked: user.balance),
            Achievement(name: "Sprinter", description: "10 challenges under 5 min", icon: "i23", isUnlocked: user.sprinter),
            Achievement(name: "Marathon", description: "100 challenges over 30 min", icon: "i24", isUnlocked: user.marathon),
            Achievement(name: "Early Bird", description: "5 early rise challenges", icon: "i25", isUnlocked: user.earlyBird),
            Achievement(name: "Night Wolf", description: "5 challenges after 23:00", icon: "i26", isUnlocked: user.nightOwl),
            Achievement(name: "Collector", description: "Open 15 achievements", icon: "i27", isUnlocked: user.collector),
            Achievement(name: "Legend", description: "Open 30 achievements", icon: "i28", isUnlocked: user.legend),
            Achievement(name: "No Refusals", description: "50 challenges without skip", icon: "i29", isUnlocked: user.noRefusals),
            Achievement(name: "24/7", description: "Active every day for a year", icon: "i30", isUnlocked: user.twentyFourSeven)
        ]
    }
}

struct Achievement {
    let name: String
    let description: String
    let icon: String
    let isUnlocked: Bool
}

struct AchievementCard: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 12) {
//            ZStack {
//                if isUnlocked {
//                    VStack {
//                        HStack {
//                            Spacer()
//                            Circle()
//                                .fill(Color(hex: "4CAF50"))
//                                .frame(width: 20, height: 20)
//                                .overlay(
//                                    Image(systemName: "checkmark")
//                                        .font(.system(size: 10, weight: .bold))
//                                        .foregroundColor(.white)
//                                )
//                                .offset(x: 8, y: -8)
//                        }
//                        Spacer()
//                    }
//                    .frame(width: 60, height: 60)
//                } else {
//                    Circle()
//                        .fill(Color.white.opacity(0.3))
//                        .frame(width: 60, height: 60)
//                    
//                    Image(systemName: "lock.fill")
//                        .font(.system(size: 20))
//                        .foregroundColor(Color(hex: "CCCCCC"))
//                }
//            }
            
            VStack(spacing: 4) {
                if isUnlocked {
                    Image(achievement.icon)
                        .resizable().scaledToFit().frame(height: 60.fitH)
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "lock.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color.gray)
                    }
                }
                
                Text(achievement.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isUnlocked ? .black : Color(hex: "AAAAAA"))
                    .multilineTextAlignment(.center)
                
                Text(achievement.description)
                    .font(.system(size: 12))
                    .foregroundColor(isUnlocked ? .gray : Color(hex: "CCCCCC"))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    AchievementsView(user: UserModel())
}
