import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Environment(\.dismiss) var dismiss
    let user: UserModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text("Statistics")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(Color.red)
                
                Spacer()
                
                Image(.appLogo)
                    .resizable().scaledToFit().frame(width: 40.fitW)
                
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
            
            if user.completedChallendges.isEmpty {
                Spacer()
                
                Image(.noStat)
                    .resizable().scaledToFit().padding()
                
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            StatCard(
                                title: "Total",
                                value: "\(user.completedChallendges.count)",
                                subtitle: "Challenges",
                                backgroundColor: Color(hex: "F3E5F5")
                            )
                            
                            StatCard(
                                title: "Streak",
                                value: "\(user.streak)",
                                subtitle: "Days",
                                backgroundColor: Color(hex: "E3F2FD")
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        HStack(spacing: 12) {
                            StatCard(
                                title: "Level",
                                value: getUserLevel(),
                                subtitle: "\(user.points) Points",
                                backgroundColor: Color(hex: "E8F5E9")
                            )
                            
                            StatCard(
                                title: "Success",
                                value: "\(getSuccessRate())%",
                                subtitle: "Rate",
                                backgroundColor: Color(hex: "FFF3E0")
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Monthly Progress")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                            
                            Chart {
                                ForEach(getMonthlyData(), id: \.month) { data in
                                    BarMark(
                                        x: .value("Month", data.month),
                                        y: .value("Count", data.count)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color(hex: "6B4FE8"), Color(hex: "5B7FFF")],
                                            startPoint: .bottom,
                                            endPoint: .top
                                        )
                                    )
                                    .cornerRadius(8)
                                }
                            }
                            .frame(height: 200)
                            .chartYAxis {
                                AxisMarks(position: .leading)
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 20)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Category Balance")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                            
                            Chart {
                                ForEach(getCategoryData(), id: \.category) { data in
                                    SectorMark(
                                        angle: .value("Count", data.count),
                                        innerRadius: .ratio(0.6),
                                        angularInset: 2
                                    )
                                    .foregroundStyle(data.color)
                                }
                            }
                            .frame(height: 200)
                            
                            VStack(spacing: 8) {
                                ForEach(getCategoryData(), id: \.category) { data in
                                    HStack {
                                        Circle()
                                            .fill(data.color)
                                            .frame(width: 12, height: 12)
                                        
                                        Text(data.category)
                                            .font(.system(size: 15))
                                            .foregroundColor(.black)
                                        
                                        Spacer()
                                        
                                        Text("\(data.count)")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .padding(.top, 8)
                }
                Spacer(minLength: 100.fitH)
            }
        }
        .bg()
    }
    
    private func getUserLevel() -> String {
        switch user.points {
        case 0..<100: return "Beginner"
        case 100..<500: return "Amateur"
        case 500..<2000: return "Pro"
        case 2000..<5000: return "Master"
        default: return "Legend"
        }
    }
    
    private func getSuccessRate() -> Int {
        let totalDays = user.activeDaysCount
        guard totalDays > 0 else { return 0 }
        let completedDays = user.completedChallendges.count
        return min(Int((Double(completedDays) / Double(totalDays)) * 100), 100)
    }
    
    private func getMonthlyData() -> [MonthData] {
        let calendar = Calendar.current
        let now = Date()
        
        var monthData: [MonthData] = []
        
        for i in 0..<6 {
            guard let monthDate = calendar.date(byAdding: .month, value: -5 + i, to: now) else { continue }
            let monthName = calendar.shortMonthSymbols[calendar.component(.month, from: monthDate) - 1]
            
            let count = user.completedChallendges.filter { challenge in
                calendar.isDate(challenge.date, equalTo: monthDate, toGranularity: .month)
            }.count
            
            monthData.append(MonthData(month: monthName, count: count))
        }
        
        return monthData
    }
    
    private func getCategoryData() -> [CategoryData] {
        let categories: [(ChallendgeType, Color)] = [
            (.sport, Color(hex: "FF6B6B")),
            (.relationships, Color(hex: "FFB6C1")),
            (.family, Color(hex: "FFD93D")),
            (.kids, Color(hex: "FFA07A")),
            (.study, Color(hex: "90EE90")),
            (.selfDev, Color(hex: "87CEEB")),
            (.health, Color(hex: "98D8C8")),
            (.social, Color(hex: "B19CD9"))
        ]
        
        return categories.map { type, color in
            let count = user.countCompletedChallengesByType(type)
            let categoryName: String
            switch type {
            case .sport: categoryName = "Sport"
            case .health: categoryName = "Health"
            case .kids: categoryName = "Kids"
            case .relationships: categoryName = "Relationships"
            case .family: categoryName = "Family"
            case .social: categoryName = "Social"
            case .study: categoryName = "Study"
            case .selfDev: categoryName = "Self-Dev"
            }
            return CategoryData(category: categoryName, count: count, color: color)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let backgroundColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(getValueColor())
            
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func getValueColor() -> Color {
        switch title {
        case "Level": return Color(hex: "4CAF50")
        case "Success": return Color(hex: "FF9800")
        case "Streak": return Color(hex: "2196F3")
        default: return Color(hex: "9C27B0")
        }
    }
}

struct MonthData {
    let month: String
    let count: Int
}

struct CategoryData {
    let category: String
    let count: Int
    let color: Color
}

#Preview {
    StatisticsView(user: UserModel())
}
