import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Environment(\.dismiss) var dismiss
    let user: UserModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: "6B4FE8"))
                        .frame(width: 40, height: 40)
                        .background(Color(hex: "F5F3FF"))
                        .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Achievements")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("\(user.countUnlockedAchievements()) of 30 unlocked")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
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
            }
        }
        .background(Color.white)
    }
    
    private func getAllAchievements() -> [Achievement] {
        return [
            Achievement(name: "First Step", description: "Complete 1 challenge", icon: "figure.walk", isUnlocked: user.firstStep),
            Achievement(name: "Week Streak", description: "7 days in a row", icon: "flame.fill", isUnlocked: user.weekStreak),
            Achievement(name: "Month Discipline", description: "30 days active", icon: "flame.fill", isUnlocked: user.monthDiscipline),
            Achievement(name: "Quarter Power", description: "90 days active", icon: "heart.fill", isUnlocked: user.quarterPower),
            Achievement(name: "Year Evolution", description: "365 days active", icon: "figure.arms.open", isUnlocked: user.yearEvolution),
            Achievement(name: "Athlete", description: "10 sport challenges", icon: "figure.run", isUnlocked: user.athlete),
            Achievement(name: "Iron", description: "20 sport challenges", icon: "flame.fill", isUnlocked: user.iron),
            Achievement(name: "Loving", description: "10 relationship challenges", icon: "heart.fill", isUnlocked: user.loving),
            Achievement(name: "Romantic", description: "20 relationship challenges", icon: "heart.fill", isUnlocked: user.romantic),
            Achievement(name: "Family Person", description: "10 family challenges", icon: "figure.2.and.child.holdinghands", isUnlocked: user.familyPerson),
            Achievement(name: "Caring", description: "30 family challenges", icon: "heart.fill", isUnlocked: user.caring),
            Achievement(name: "Parent", description: "20 kids challenges", icon: "figure.and.child.holdinghands", isUnlocked: user.parent),
            Achievement(name: "Mentor", description: "50 kids challenges", icon: "figure.2.and.child.holdinghands", isUnlocked: user.mentor),
            Achievement(name: "Scholar", description: "15 study challenges", icon: "book.fill", isUnlocked: user.scholar),
            Achievement(name: "Master", description: "40 study challenges", icon: "graduationcap.fill", isUnlocked: user.master),
            Achievement(name: "Philosopher", description: "20 self-dev challenges", icon: "brain.head.profile", isUnlocked: user.philosopher),
            Achievement(name: "Sage", description: "50 self-dev challenges", icon: "sparkles", isUnlocked: user.sage),
            Achievement(name: "Healthy", description: "20 health challenges", icon: "leaf.fill", isUnlocked: user.healthy),
            Achievement(name: "Long-liver", description: "60 health challenges", icon: "figure.walk", isUnlocked: user.longLiver),
            Achievement(name: "Friend", description: "15 social challenges", icon: "person.2.fill", isUnlocked: user.friend),
            Achievement(name: "Hero", description: "40 social challenges", icon: "star.fill", isUnlocked: user.hero),
            Achievement(name: "Balance", description: "5 in each category", icon: "circle.hexagongrid.fill", isUnlocked: user.balance),
            Achievement(name: "Sprinter", description: "10 challenges under 5 min", icon: "hare.fill", isUnlocked: user.sprinter),
            Achievement(name: "Marathon", description: "100 challenges over 30 min", icon: "figure.run", isUnlocked: user.marathon),
            Achievement(name: "Early Bird", description: "5 early rise challenges", icon: "sunrise.fill", isUnlocked: user.earlyBird),
            Achievement(name: "Night Wolf", description: "5 challenges after 23:00", icon: "moon.stars.fill", isUnlocked: user.nightOwl),
            Achievement(name: "Collector", description: "Open 15 achievements", icon: "star.fill", isUnlocked: user.collector),
            Achievement(name: "Legend", description: "Open 30 achievements", icon: "crown.fill", isUnlocked: user.legend),
            Achievement(name: "No Refusals", description: "50 challenges without skip", icon: "checkmark.seal.fill", isUnlocked: user.noRefusals),
            Achievement(name: "24/7", description: "Active every day for a year", icon: "clock.fill", isUnlocked: user.twentyFourSeven)
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
            ZStack {
                Circle()
                    .fill(isUnlocked ? LinearGradient(
                        colors: [Color(hex: "6B4FE8"), Color(hex: "5B7FFF")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) : LinearGradient(
                        colors: [Color(hex: "E5E5E5"), Color(hex: "E5E5E5")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isUnlocked ? .white : Color(hex: "CCCCCC"))
                
                if isUnlocked {
                    VStack {
                        HStack {
                            Spacer()
                            Circle()
                                .fill(Color(hex: "4CAF50"))
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .offset(x: 8, y: -8)
                        }
                        Spacer()
                    }
                    .frame(width: 60, height: 60)
                }
                
                if !isUnlocked {
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "CCCCCC"))
                }
            }
            
            VStack(spacing: 4) {
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
