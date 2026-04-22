import Foundation
import SwiftData

enum ChallendgeType: String, CaseIterable, Codable {
    case sport, health, kids, relationships, family, social, study, selfDev
}

@Model
class UserModel {
    var id = UUID()
    var name: String = "User"
    var photo: Data? = nil
    
    var completedChallendges: [ChallengeModel]
    var streak: Int
    var points: Int
    var countSkipsToday: Int = 3
    var currentDate: Date = Date()
    var lastChallengeDate: Date?
    var consecutiveDaysWithoutSkip: Int = 0
    var activeDaysCount: Int = 0
    var lastActiveDate: Date?
    
    var firstStep: Bool = false
    var weekStreak: Bool = false
    var monthDiscipline: Bool = false
    var quarterPower: Bool = false
    var yearEvolution: Bool = false
    
    var athlete: Bool = false
    var iron: Bool = false
    var loving: Bool = false
    var romantic: Bool = false
    var familyPerson: Bool = false
    var caring: Bool = false
    var parent: Bool = false
    var mentor: Bool = false
    var scholar: Bool = false
    var master: Bool = false
    var philosopher: Bool = false
    var sage: Bool = false
    var healthy: Bool = false
    var longLiver: Bool = false
    var friend: Bool = false
    var hero: Bool = false
    
    var balance: Bool = false
    
    var sprinter: Bool = false
    var earlyBird: Bool = false
    var nightOwl: Bool = false
    
    var marathon: Bool = false
    
    var collector: Bool = false
    var legend: Bool = false
    var noRefusals: Bool = false
    var twentyFourSeven: Bool = false
    
    init(completedChallendges: [ChallengeModel] = [], streak: Int = 0, points: Int = 0) {
        self.completedChallendges = completedChallendges
        self.streak = streak
        self.points = points
    }
    
    func countCompletedChallengesByType(_ type: ChallendgeType) -> Int {
        return completedChallendges.filter { $0.type == type }.count
    }
    
    func countChallengesUnderDuration(_ duration: TimeInterval) -> Int {
        return completedChallendges.filter { !$0.isDeadline && $0.duration < duration }.count
    }
    
    func countChallengesOverDuration(_ duration: TimeInterval) -> Int {
        return completedChallendges.filter { !$0.isDeadline && $0.duration > duration }.count
    }
    
    func countEarlyRiseChallenges() -> Int {
        return completedChallendges.filter { $0.name == "Early Rise" }.count
    }
    
    func countNightChallenges() -> Int {
        return completedChallendges.filter { challenge in
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: challenge.date)
            return hour >= 23 || hour < 4
        }.count
    }
    
    func hasBalanceAcrossCategories() -> Bool {
        let types = ChallendgeType.allCases
        return types.allSatisfy { countCompletedChallengesByType($0) >= 5 }
    }
    
    func countUnlockedAchievements() -> Int {
        var count = 0
        
        if firstStep { count += 1 }
        if weekStreak { count += 1 }
        if monthDiscipline { count += 1 }
        if quarterPower { count += 1 }
        if yearEvolution { count += 1 }
        
        if athlete { count += 1 }
        if iron { count += 1 }
        if loving { count += 1 }
        if romantic { count += 1 }
        if familyPerson { count += 1 }
        if caring { count += 1 }
        if parent { count += 1 }
        if mentor { count += 1 }
        if scholar { count += 1 }
        if master { count += 1 }
        if philosopher { count += 1 }
        if sage { count += 1 }
        if healthy { count += 1 }
        if longLiver { count += 1 }
        if friend { count += 1 }
        if hero { count += 1 }
        
        if balance { count += 1 }
        
        if sprinter { count += 1 }
        if earlyBird { count += 1 }
        if nightOwl { count += 1 }
        
        if marathon { count += 1 }
        
        if collector { count += 1 }
        if legend { count += 1 }
        if noRefusals { count += 1 }
        if twentyFourSeven { count += 1 }
        
        return count
    }
}

@Model
class ChallengeModel {
    var id: UUID
    var type: ChallendgeType
    var name: String
    var descriptionChallendge: String
    var duration: TimeInterval
    var wasComplete: Bool
    var date: Date
    var isDeadline: Bool
    var deadlineHour: Int?
    var deadlineMinute: Int?
    
    init(id: UUID = UUID(),
         type: ChallendgeType,
         name: String,
         descriptionChallendge: String,
         duration: TimeInterval,
         wasComplete: Bool = false,
         date: Date = Date(),
         isDeadline: Bool = false,
         deadlineHour: Int? = nil,
         deadlineMinute: Int? = nil) {
        self.id = id
        self.type = type
        self.name = name
        self.descriptionChallendge = descriptionChallendge
        self.duration = duration
        self.wasComplete = wasComplete
        self.date = date
        self.isDeadline = isDeadline
        self.deadlineHour = deadlineHour
        self.deadlineMinute = deadlineMinute
    }
    
    func getRemainingTime() -> TimeInterval {
        if isDeadline {
            return calculateTimeUntilDeadline()
        } else {
            return duration
        }
    }
    
    private func calculateTimeUntilDeadline() -> TimeInterval {
        guard let hour = deadlineHour, let minute = deadlineMinute else {
            return duration
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = hour
        components.minute = minute
        components.second = 59
        
        guard let deadlineDate = calendar.date(from: components) else {
            return duration
        }
        
        if deadlineDate < now {
            return 0
        }
        
        return deadlineDate.timeIntervalSince(now)
    }
    
    func isDeadlineExpired() -> Bool {
        if !isDeadline { return false }
        return getRemainingTime() <= 0
    }
    
    func getFormattedRemainingTime() -> String {
        let remaining = getRemainingTime()
        
        if remaining <= 0 {
            return "Expired"
        }
        
        let hours = Int(remaining) / 3600
        let minutes = Int(remaining) / 60 % 60
        let seconds = Int(remaining) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

class AchievementManager {
    static func checkAndUpdateAchievements(user: UserModel, completedChallenge: ChallengeModel) {
        let totalChallenges = user.completedChallendges.count
        
        if totalChallenges >= 1 && !user.firstStep {
            user.firstStep = true
        }
        
        let sportCount = user.countCompletedChallengesByType(.sport)
        if sportCount >= 10 && !user.athlete {
            user.athlete = true
        }
        if sportCount >= 20 && !user.iron {
            user.iron = true
        }
        
        let relationshipCount = user.countCompletedChallengesByType(.relationships)
        if relationshipCount >= 5 && !user.loving {
            user.loving = true
        }
        if relationshipCount >= 20 && !user.romantic {
            user.romantic = true
        }
        
        let familyCount = user.countCompletedChallengesByType(.family)
        if familyCount >= 10 && !user.familyPerson {
            user.familyPerson = true
        }
        if familyCount >= 30 && !user.caring {
            user.caring = true
        }
        
        let kidsCount = user.countCompletedChallengesByType(.kids)
        if kidsCount >= 20 && !user.parent {
            user.parent = true
        }
        if kidsCount >= 50 && !user.mentor {
            user.mentor = true
        }
        
        let studyCount = user.countCompletedChallengesByType(.study)
        if studyCount >= 15 && !user.scholar {
            user.scholar = true
        }
        if studyCount >= 40 && !user.master {
            user.master = true
        }
        
        let selfDevCount = user.countCompletedChallengesByType(.selfDev)
        if selfDevCount >= 20 && !user.philosopher {
            user.philosopher = true
        }
        if selfDevCount >= 50 && !user.sage {
            user.sage = true
        }
        
        let healthCount = user.countCompletedChallengesByType(.health)
        if healthCount >= 20 && !user.healthy {
            user.healthy = true
        }
        if healthCount >= 60 && !user.longLiver {
            user.longLiver = true
        }
        
        let socialCount = user.countCompletedChallengesByType(.social)
        if socialCount >= 15 && !user.friend {
            user.friend = true
        }
        if socialCount >= 40 && !user.hero {
            user.hero = true
        }
        
        if user.hasBalanceAcrossCategories() && !user.balance {
            user.balance = true
        }
        
        let shortChallenges = user.countChallengesUnderDuration(300)
        if shortChallenges >= 10 && !user.sprinter {
            user.sprinter = true
        }
        
        let longChallenges = user.countChallengesOverDuration(1800)
        if longChallenges >= 100 && !user.marathon {
            user.marathon = true
        }
        
        let earlyRiseCount = user.countEarlyRiseChallenges()
        if earlyRiseCount >= 5 && !user.earlyBird {
            user.earlyBird = true
        }
        
        let nightCount = user.countNightChallenges()
        if nightCount >= 5 && !user.nightOwl {
            user.nightOwl = true
        }
        
        if user.streak >= 7 && !user.weekStreak {
            user.weekStreak = true
        }
        if user.activeDaysCount >= 30 && !user.monthDiscipline {
            user.monthDiscipline = true
        }
        if user.activeDaysCount >= 90 && !user.quarterPower {
            user.quarterPower = true
        }
        if user.activeDaysCount >= 365 && !user.yearEvolution {
            user.yearEvolution = true
        }
        
        if user.consecutiveDaysWithoutSkip >= 50 && !user.noRefusals {
            user.noRefusals = true
        }
        
        if user.streak >= 365 && !user.twentyFourSeven {
            user.twentyFourSeven = true
        }
        
        let achievementCount = user.countUnlockedAchievements()
        if achievementCount >= 15 && !user.collector {
            user.collector = true
        }
        if achievementCount >= 30 && !user.legend {
            user.legend = true
        }
    }
    
    static func updateStreak(user: UserModel) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = user.lastChallengeDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysDifference = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysDifference == 0 {
                
            } else if daysDifference == 1 {
                user.streak += 1
            } else {
                user.streak = 1
            }
        } else {
            user.streak = 1
        }
        
        user.lastChallengeDate = Date()
        
        if let lastActive = user.lastActiveDate {
            let lastActiveDay = calendar.startOfDay(for: lastActive)
            if !calendar.isDate(lastActiveDay, inSameDayAs: today) {
                user.activeDaysCount += 1
            }
        } else {
            user.activeDaysCount = 1
        }
        
        user.lastActiveDate = Date()
    }
}

class ChallengeFactory {
    
    static func createPlankVictory() -> ChallengeModel {
        ChallengeModel(
            type: .sport,
            name: "Plank Victory",
            descriptionChallendge: "Hold the plank position",
            duration: 60,
            isDeadline: false
        )
    }
    
    static func createHundredSteps() -> ChallengeModel {
        ChallengeModel(
            type: .sport,
            name: "100 Steps",
            descriptionChallendge: "Walk on foot",
            duration: 300,
            isDeadline: false
        )
    }
    
    static func createSquatSet() -> ChallengeModel {
        ChallengeModel(
            type: .sport,
            name: "Squat Set",
            descriptionChallendge: "Do squats",
            duration: 120,
            isDeadline: false
        )
    }
    
    static func createMorningStretch() -> ChallengeModel {
        ChallengeModel(
            type: .sport,
            name: "Morning Stretch",
            descriptionChallendge: "Stretch your muscles",
            duration: 600,
            isDeadline: false
        )
    }
    
    static func createStairs() -> ChallengeModel {
        ChallengeModel(
            type: .sport,
            name: "Stairs",
            descriptionChallendge: "Climb the stairs",
            duration: 300,
            isDeadline: false
        )
    }
    
    static func createPushUps() -> ChallengeModel {
        ChallengeModel(
            type: .sport,
            name: "Push-Ups",
            descriptionChallendge: "Classic push-ups",
            duration: 120,
            isDeadline: false
        )
    }
    
    static func createWalk() -> ChallengeModel {
        ChallengeModel(
            type: .sport,
            name: "Walk",
            descriptionChallendge: "Fresh air",
            duration: 900,
            isDeadline: false
        )
    }
    
    static func createYogaMinutes() -> ChallengeModel {
        ChallengeModel(
            type: .sport,
            name: "Yoga Minutes",
            descriptionChallendge: "Any asana",
            duration: 300,
            isDeadline: false
        )
    }
    
    static func createBurpeeStorm() -> ChallengeModel {
        ChallengeModel(
            type: .sport,
            name: "Burpee Storm",
            descriptionChallendge: "Intensive workout",
            duration: 60,
            isDeadline: false
        )
    }
    
    static func createJumpRope() -> ChallengeModel {
        ChallengeModel(
            type: .sport,
            name: "Jump Rope",
            descriptionChallendge: "Jumping",
            duration: 180,
            isDeadline: false
        )
    }
    
    static func createAbsCorner() -> ChallengeModel {
        ChallengeModel(
            type: .sport,
            name: "Abs Corner",
            descriptionChallendge: "Abs exercise",
            duration: 120,
            isDeadline: false
        )
    }
    
    static func createColdShower() -> ChallengeModel {
        ChallengeModel(
            type: .sport,
            name: "Cold Shower",
            descriptionChallendge: "Hardening",
            duration: 30,
            isDeadline: false
        )
    }
    
    static func createCompliment() -> ChallengeModel {
        ChallengeModel(
            type: .relationships,
            name: "Compliment",
            descriptionChallendge: "Sincere word",
            duration: 0,
            isDeadline: true,
            deadlineHour: 23,
            deadlineMinute: 59
        )
    }
    
    static func createDinnerNoPhones() -> ChallengeModel {
        ChallengeModel(
            type: .relationships,
            name: "Dinner No Phones",
            descriptionChallendge: "Meal time",
            duration: 1800,
            isDeadline: false
        )
    }
    
    static func createHug() -> ChallengeModel {
        ChallengeModel(
            type: .relationships,
            name: "Hug",
            descriptionChallendge: "Long hug",
            duration: 20,
            isDeadline: false
        )
    }
    
    static func createCoupleWalk() -> ChallengeModel {
        ChallengeModel(
            type: .relationships,
            name: "Couple Walk",
            descriptionChallendge: "Together outside",
            duration: 1200,
            isDeadline: false
        )
    }
    
    static func createLoveLetter() -> ChallengeModel {
        ChallengeModel(
            type: .relationships,
            name: "Love Letter",
            descriptionChallendge: "Message/Note",
            duration: 0,
            isDeadline: true,
            deadlineHour: 20,
            deadlineMinute: 0
        )
    }
    
    static func createMemory() -> ChallengeModel {
        ChallengeModel(
            type: .relationships,
            name: "Memory",
            descriptionChallendge: "Discuss how you met",
            duration: 600,
            isDeadline: false
        )
    }
    
    static func createSurprise() -> ChallengeModel {
        ChallengeModel(
            type: .relationships,
            name: "Surprise",
            descriptionChallendge: "Small gift",
            duration: 0,
            isDeadline: true,
            deadlineHour: 23,
            deadlineMinute: 59
        )
    }
    
    static func createListening() -> ChallengeModel {
        ChallengeModel(
            type: .relationships,
            name: "Listening",
            descriptionChallendge: "Without interruptions",
            duration: 300,
            isDeadline: false
        )
    }
    
    static func createFuturePlans() -> ChallengeModel {
        ChallengeModel(
            type: .relationships,
            name: "Future Plans",
            descriptionChallendge: "Discuss dreams",
            duration: 900,
            isDeadline: false
        )
    }
    
    static func createDance() -> ChallengeModel {
        ChallengeModel(
            type: .relationships,
            name: "Dance",
            descriptionChallendge: "Dance at home",
            duration: 180,
            isDeadline: false
        )
    }
    
    static func createMassage() -> ChallengeModel {
        ChallengeModel(
            type: .relationships,
            name: "Massage",
            descriptionChallendge: "Give massage to partner",
            duration: 300,
            isDeadline: false
        )
    }
    
    static func createGratitude() -> ChallengeModel {
        ChallengeModel(
            type: .relationships,
            name: "Gratitude",
            descriptionChallendge: "Say Thank You",
            duration: 0,
            isDeadline: true,
            deadlineHour: 23,
            deadlineMinute: 59
        )
    }
    
    static func createCallParents() -> ChallengeModel {
        ChallengeModel(
            type: .family,
            name: "Call Parents",
            descriptionChallendge: "Call mom/dad",
            duration: 300,
            isDeadline: false
        )
    }
    
    static func createHouseHelp() -> ChallengeModel {
        ChallengeModel(
            type: .family,
            name: "House Help",
            descriptionChallendge: "Cleaning/Washing",
            duration: 900,
            isDeadline: false
        )
    }
    
    static func createFamilyPhoto() -> ChallengeModel {
        ChallengeModel(
            type: .family,
            name: "Family Photo",
            descriptionChallendge: "Find an old photo",
            duration: 600,
            isDeadline: false
        )
    }
    
    static func createAncestorRecipe() -> ChallengeModel {
        ChallengeModel(
            type: .family,
            name: "Ancestor Recipe",
            descriptionChallendge: "Cook a dish",
            duration: 1800,
            isDeadline: false
        )
    }
    
    static func createVideoCall() -> ChallengeModel {
        ChallengeModel(
            type: .family,
            name: "Video Call",
            descriptionChallendge: "Connect with relatives",
            duration: 600,
            isDeadline: false
        )
    }
    
    static func createWiseAdvice() -> ChallengeModel {
        ChallengeModel(
            type: .family,
            name: "Wise Advice",
            descriptionChallendge: "Ask for advice",
            duration: 0,
            isDeadline: true,
            deadlineHour: 21,
            deadlineMinute: 0
        )
    }
    
    static func createGiftToRelatives() -> ChallengeModel {
        ChallengeModel(
            type: .family,
            name: "Gift to Relatives",
            descriptionChallendge: "Send/Buy",
            duration: 0,
            isDeadline: true,
            deadlineHour: 23,
            deadlineMinute: 59
        )
    }
    
    static func createFamilyHistory() -> ChallengeModel {
        ChallengeModel(
            type: .family,
            name: "Family History",
            descriptionChallendge: "Learn fact about ancestors",
            duration: 900,
            isDeadline: false
        )
    }
    
    static func createHandyHelp() -> ChallengeModel {
        ChallengeModel(
            type: .family,
            name: "Handy Help",
            descriptionChallendge: "Fix something",
            duration: 1200,
            isDeadline: false
        )
    }
    
    static func createFamilyLunch() -> ChallengeModel {
        ChallengeModel(
            type: .family,
            name: "Family Lunch",
            descriptionChallendge: "With family",
            duration: 1800,
            isDeadline: false
        )
    }
    
    static func createTechSupport() -> ChallengeModel {
        ChallengeModel(
            type: .family,
            name: "Tech Support",
            descriptionChallendge: "Help with gadget",
            duration: 600,
            isDeadline: false
        )
    }
    
    static func createWarmWord() -> ChallengeModel {
        ChallengeModel(
            type: .family,
            name: "Warm Word",
            descriptionChallendge: "Say 'I Love You'",
            duration: 0,
            isDeadline: true,
            deadlineHour: 23,
            deadlineMinute: 59
        )
    }
    
    static func createFloorPlay() -> ChallengeModel {
        ChallengeModel(
            type: .kids,
            name: "Floor Play",
            descriptionChallendge: "Full engagement",
            duration: 900,
            isDeadline: false
        )
    }
    
    static func createFairyTaleReading() -> ChallengeModel {
        ChallengeModel(
            type: .kids,
            name: "Fairy Tale Reading",
            descriptionChallendge: "Book aloud",
            duration: 600,
            isDeadline: false
        )
    }
    
    static func createKindnessLesson() -> ChallengeModel {
        ChallengeModel(
            type: .kids,
            name: "Kindness Lesson",
            descriptionChallendge: "Explain value",
            duration: 300,
            isDeadline: false
        )
    }
    
    static func createParkWalk() -> ChallengeModel {
        ChallengeModel(
            type: .kids,
            name: "Park Walk",
            descriptionChallendge: "Activity",
            duration: 1800,
            isDeadline: false
        )
    }
    
    static func createHomeworkHelp() -> ChallengeModel {
        ChallengeModel(
            type: .kids,
            name: "Homework Help",
            descriptionChallendge: "Control/Help",
            duration: 1200,
            isDeadline: false
        )
    }
    
    static func createCookTogether() -> ChallengeModel {
        ChallengeModel(
            type: .kids,
            name: "Cook Together",
            descriptionChallendge: "Cooking",
            duration: 1800,
            isDeadline: false
        )
    }
    
    static func createBedtimeHug() -> ChallengeModel {
        ChallengeModel(
            type: .kids,
            name: "Bedtime Hug",
            descriptionChallendge: "Ritual",
            duration: 60,
            isDeadline: false
        )
    }
    
    static func createListenToKid() -> ChallengeModel {
        ChallengeModel(
            type: .kids,
            name: "Listen to Kid",
            descriptionChallendge: "Without distractions",
            duration: 600,
            isDeadline: false
        )
    }
    
    static func createCreativity() -> ChallengeModel {
        ChallengeModel(
            type: .kids,
            name: "Creativity",
            descriptionChallendge: "Drawing/Sculpting",
            duration: 1200,
            isDeadline: false
        )
    }
    
    static func createSportsWithKids() -> ChallengeModel {
        ChallengeModel(
            type: .kids,
            name: "Sports with Kids",
            descriptionChallendge: "Ball/Running",
            duration: 900,
            isDeadline: false
        )
    }
    
    static func createPraise() -> ChallengeModel {
        ChallengeModel(
            type: .kids,
            name: "Praise",
            descriptionChallendge: "For specific deed",
            duration: 0,
            isDeadline: true,
            deadlineHour: 20,
            deadlineMinute: 0
        )
    }
    
    static func createNoGadgetsTime() -> ChallengeModel {
        ChallengeModel(
            type: .kids,
            name: "No Gadgets Time",
            descriptionChallendge: "Only communication",
            duration: 1800,
            isDeadline: false
        )
    }
    
    static func createTenPages() -> ChallengeModel {
        ChallengeModel(
            type: .study,
            name: "10 Pages",
            descriptionChallendge: "Book reading",
            duration: 1200,
            isDeadline: false
        )
    }
    
    static func createNewWord() -> ChallengeModel {
        ChallengeModel(
            type: .study,
            name: "New Word",
            descriptionChallendge: "Foreign language",
            duration: 300,
            isDeadline: false
        )
    }
    
    static func createVideoLesson() -> ChallengeModel {
        ChallengeModel(
            type: .study,
            name: "Video Lesson",
            descriptionChallendge: "Online learning",
            duration: 900,
            isDeadline: false
        )
    }
    
    static func createNotes() -> ChallengeModel {
        ChallengeModel(
            type: .study,
            name: "Notes",
            descriptionChallendge: "Write down ideas",
            duration: 600,
            isDeadline: false
        )
    }
    
    static func createPodcast() -> ChallengeModel {
        ChallengeModel(
            type: .study,
            name: "Podcast",
            descriptionChallendge: "Educational audio",
            duration: 900,
            isDeadline: false
        )
    }
    
    static func createArticle() -> ChallengeModel {
        ChallengeModel(
            type: .study,
            name: "Article",
            descriptionChallendge: "Professional topic",
            duration: 600,
            isDeadline: false
        )
    }
    
    static func createSkillPractice() -> ChallengeModel {
        ChallengeModel(
            type: .study,
            name: "Skill Practice",
            descriptionChallendge: "Apply knowledge",
            duration: 1200,
            isDeadline: false
        )
    }
    
    static func createTestQuiz() -> ChallengeModel {
        ChallengeModel(
            type: .study,
            name: "Test/Quiz",
            descriptionChallendge: "Check knowledge",
            duration: 600,
            isDeadline: false
        )
    }
    
    static func createResearch() -> ChallengeModel {
        ChallengeModel(
            type: .study,
            name: "Research",
            descriptionChallendge: "Search for information",
            duration: 900,
            isDeadline: false
        )
    }
    
    static func createTeachOthers() -> ChallengeModel {
        ChallengeModel(
            type: .study,
            name: "Teach Others",
            descriptionChallendge: "Tell someone",
            duration: 300,
            isDeadline: false
        )
    }
    
    static func createLearningPlan() -> ChallengeModel {
        ChallengeModel(
            type: .study,
            name: "Learning Plan",
            descriptionChallendge: "Create plan",
            duration: 600,
            isDeadline: false
        )
    }
    
    static func createToolLearning() -> ChallengeModel {
        ChallengeModel(
            type: .study,
            name: "Tool Learning",
            descriptionChallendge: "Learn new software",
            duration: 1200,
            isDeadline: false
        )
    }
    
    static func createMeditation() -> ChallengeModel {
        ChallengeModel(
            type: .selfDev,
            name: "Meditation",
            descriptionChallendge: "Silence and breathing",
            duration: 600,
            isDeadline: false
        )
    }
    
    static func createDiary() -> ChallengeModel {
        ChallengeModel(
            type: .selfDev,
            name: "Diary",
            descriptionChallendge: "Write down thoughts",
            duration: 600,
            isDeadline: false
        )
    }
    
    static func createDigitalDetox() -> ChallengeModel {
        ChallengeModel(
            type: .selfDev,
            name: "Digital Detox",
            descriptionChallendge: "No social media",
            duration: 3600,
            isDeadline: false
        )
    }
    
    static func createEarlyRise() -> ChallengeModel {
        ChallengeModel(
            type: .selfDev,
            name: "Early Rise",
            descriptionChallendge: "Wake up before 7:00",
            duration: 0,
            isDeadline: true,
            deadlineHour: 7,
            deadlineMinute: 0
        )
    }
    
    static func createDayAnalysis() -> ChallengeModel {
        ChallengeModel(
            type: .selfDev,
            name: "Day Analysis",
            descriptionChallendge: "Evening summary",
            duration: 300,
            isDeadline: false
        )
    }
    
    static func createDecluttering() -> ChallengeModel {
        ChallengeModel(
            type: .selfDev,
            name: "Decluttering",
            descriptionChallendge: "Throw away 5 things",
            duration: 600,
            isDeadline: false
        )
    }
    
    static func createGratitudeList() -> ChallengeModel {
        ChallengeModel(
            type: .selfDev,
            name: "Gratitude List",
            descriptionChallendge: "3 items",
            duration: 300,
            isDeadline: false
        )
    }
    
    static func createVisualization() -> ChallengeModel {
        ChallengeModel(
            type: .selfDev,
            name: "Visualization",
            descriptionChallendge: "Goal for the year",
            duration: 300,
            isDeadline: false
        )
    }
    
    static func createAffirmations() -> ChallengeModel {
        ChallengeModel(
            type: .selfDev,
            name: "Affirmations",
            descriptionChallendge: "In front of mirror",
            duration: 120,
            isDeadline: false
        )
    }
    
    static func createBreathing478() -> ChallengeModel {
        ChallengeModel(
            type: .selfDev,
            name: "Breathing 4-7-8",
            descriptionChallendge: "Relaxation technique",
            duration: 300,
            isDeadline: false
        )
    }
    
    static func createTomorrowPlan() -> ChallengeModel {
        ChallengeModel(
            type: .selfDev,
            name: "Tomorrow Plan",
            descriptionChallendge: "To-Do list",
            duration: 600,
            isDeadline: false
        )
    }
    
    static func createSolitude() -> ChallengeModel {
        ChallengeModel(
            type: .selfDev,
            name: "Solitude",
            descriptionChallendge: "Time alone",
            duration: 900,
            isDeadline: false
        )
    }
    
    static func createWater2Liters() -> ChallengeModel {
        ChallengeModel(
            type: .health,
            name: "Water 2 Liters",
            descriptionChallendge: "Drinking regime",
            duration: 0,
            isDeadline: true,
            deadlineHour: 23,
            deadlineMinute: 59
        )
    }
    
    static func createSleep8Hours() -> ChallengeModel {
        ChallengeModel(
            type: .health,
            name: "Sleep 8 Hours",
            descriptionChallendge: "Sleep mode",
            duration: 0,
            isDeadline: true,
            deadlineHour: 8,
            deadlineMinute: 0
        )
    }
    
    static func createNoSugar() -> ChallengeModel {
        ChallengeModel(
            type: .health,
            name: "No Sugar",
            descriptionChallendge: "Exclude sweets",
            duration: 0,
            isDeadline: true,
            deadlineHour: 23,
            deadlineMinute: 59
        )
    }
    
    static func createVegetables() -> ChallengeModel {
        ChallengeModel(
            type: .health,
            name: "Vegetables",
            descriptionChallendge: "Portion of vegetables",
            duration: 0,
            isDeadline: true,
            deadlineHour: 20,
            deadlineMinute: 0
        )
    }
    
    static func createVitamins() -> ChallengeModel {
        ChallengeModel(
            type: .health,
            name: "Vitamins",
            descriptionChallendge: "Take supplements",
            duration: 0,
            isDeadline: true,
            deadlineHour: 12,
            deadlineMinute: 0
        )
    }
    
    static func createTenThousandSteps() -> ChallengeModel {
        ChallengeModel(
            type: .health,
            name: "10,000 Steps",
            descriptionChallendge: "Activity",
            duration: 0,
            isDeadline: true,
            deadlineHour: 23,
            deadlineMinute: 59
        )
    }
    
    static func createMorningExercise() -> ChallengeModel {
        ChallengeModel(
            type: .health,
            name: "Morning Exercise",
            descriptionChallendge: "Joints",
            duration: 300,
            isDeadline: false
        )
    }
    
    static func createNoAlcohol() -> ChallengeModel {
        ChallengeModel(
            type: .health,
            name: "No Alcohol",
            descriptionChallendge: "Sober day",
            duration: 0,
            isDeadline: true,
            deadlineHour: 23,
            deadlineMinute: 59
        )
    }
    
    static func createChampionBreakfast() -> ChallengeModel {
        ChallengeModel(
            type: .health,
            name: "Champion Breakfast",
            descriptionChallendge: "Healthy breakfast",
            duration: 900,
            isDeadline: false
        )
    }
    
    static func createPosture() -> ChallengeModel {
        ChallengeModel(
            type: .health,
            name: "Posture",
            descriptionChallendge: "Back control",
            duration: 60,
            isDeadline: false
        )
    }
    
    static func createScreenBreak() -> ChallengeModel {
        ChallengeModel(
            type: .health,
            name: "Screen Break",
            descriptionChallendge: "Eye exercises",
            duration: 120,
            isDeadline: false
        )
    }
    
    static func createSleepHygiene() -> ChallengeModel {
        ChallengeModel(
            type: .health,
            name: "Sleep Hygiene",
            descriptionChallendge: "Ventilate room",
            duration: 600,
            isDeadline: false
        )
    }
    
    static func createSmileStranger() -> ChallengeModel {
        ChallengeModel(
            type: .social,
            name: "Smile Stranger",
            descriptionChallendge: "To a passerby",
            duration: 0,
            isDeadline: true,
            deadlineHour: 23,
            deadlineMinute: 59
        )
    }
    
    static func createHoldDoor() -> ChallengeModel {
        ChallengeModel(
            type: .social,
            name: "Hold Door",
            descriptionChallendge: "Politeness",
            duration: 0,
            isDeadline: true,
            deadlineHour: 23,
            deadlineMinute: 59
        )
    }
    
    static func createDonation() -> ChallengeModel {
        ChallengeModel(
            type: .social,
            name: "Donation",
            descriptionChallendge: "Charity",
            duration: 0,
            isDeadline: true,
            deadlineHour: 23,
            deadlineMinute: 59
        )
    }
    
    static func createComplimentStranger() -> ChallengeModel {
        ChallengeModel(
            type: .social,
            name: "Compliment Stranger",
            descriptionChallendge: "Sincerely",
            duration: 0,
            isDeadline: true,
            deadlineHour: 23,
            deadlineMinute: 59
        )
    }
    
    static func createReview() -> ChallengeModel {
        ChallengeModel(
            type: .social,
            name: "Review",
            descriptionChallendge: "Thank business",
            duration: 300,
            isDeadline: false
        )
    }
    
    static func createShareKnowledge() -> ChallengeModel {
        ChallengeModel(
            type: .social,
            name: "Share Knowledge",
            descriptionChallendge: "Advice to friend",
            duration: 300,
            isDeadline: false
        )
    }
    
    static func createListenFriend() -> ChallengeModel {
        ChallengeModel(
            type: .social,
            name: "Listen Friend",
            descriptionChallendge: "Support",
            duration: 600,
            isDeadline: false
        )
    }
    
    static func createElevator() -> ChallengeModel {
        ChallengeModel(
            type: .social,
            name: "Elevator",
            descriptionChallendge: "Let others pass",
            duration: 0,
            isDeadline: true,
            deadlineHour: 23,
            deadlineMinute: 59
        )
    }
    
    static func createThankService() -> ChallengeModel {
        ChallengeModel(
            type: .social,
            name: "Thank Service",
            descriptionChallendge: "Waiter/courier",
            duration: 0,
            isDeadline: true,
            deadlineHour: 23,
            deadlineMinute: 59
        )
    }
    
    static func createGiveUpSeat() -> ChallengeModel {
        ChallengeModel(
            type: .social,
            name: "Give Up Seat",
            descriptionChallendge: "In transport",
            duration: 0,
            isDeadline: true,
            deadlineHour: 23,
            deadlineMinute: 59
        )
    }
    
    static func createPositiveOnline() -> ChallengeModel {
        ChallengeModel(
            type: .social,
            name: "Positive Online",
            descriptionChallendge: "Comment",
            duration: 300,
            isDeadline: false
        )
    }
    
    static func createVolunteer() -> ChallengeModel {
        ChallengeModel(
            type: .social,
            name: "Volunteer",
            descriptionChallendge: "Help by deed",
            duration: 1800,
            isDeadline: false
        )
    }
    
    static func getAllChallenges() -> [ChallengeModel] {
        return [
            createPlankVictory(), createHundredSteps(), createSquatSet(), createMorningStretch(),
            createStairs(), createPushUps(), createWalk(), createYogaMinutes(),
            createBurpeeStorm(), createJumpRope(), createAbsCorner(), createColdShower(),
            
            createCompliment(), createDinnerNoPhones(), createHug(), createCoupleWalk(),
            createLoveLetter(), createMemory(), createSurprise(), createListening(),
            createFuturePlans(), createDance(), createMassage(), createGratitude(),
            
            createCallParents(), createHouseHelp(), createFamilyPhoto(), createAncestorRecipe(),
            createVideoCall(), createWiseAdvice(), createGiftToRelatives(), createFamilyHistory(),
            createHandyHelp(), createFamilyLunch(), createTechSupport(), createWarmWord(),
            
            createFloorPlay(), createFairyTaleReading(), createKindnessLesson(), createParkWalk(),
            createHomeworkHelp(), createCookTogether(), createBedtimeHug(), createListenToKid(),
            createCreativity(), createSportsWithKids(), createPraise(), createNoGadgetsTime(),
            
            createTenPages(), createNewWord(), createVideoLesson(), createNotes(),
            createPodcast(), createArticle(), createSkillPractice(), createTestQuiz(),
            createResearch(), createTeachOthers(), createLearningPlan(), createToolLearning(),
            
            createMeditation(), createDiary(), createDigitalDetox(), createEarlyRise(),
            createDayAnalysis(), createDecluttering(), createGratitudeList(), createVisualization(),
            createAffirmations(), createBreathing478(), createTomorrowPlan(), createSolitude(),
            
            createWater2Liters(), createSleep8Hours(), createNoSugar(), createVegetables(),
            createVitamins(), createTenThousandSteps(), createMorningExercise(), createNoAlcohol(),
            createChampionBreakfast(), createPosture(), createScreenBreak(), createSleepHygiene(),
            
            createSmileStranger(), createHoldDoor(), createDonation(), createComplimentStranger(),
            createReview(), createShareKnowledge(), createListenFriend(), createElevator(),
            createThankService(), createGiveUpSeat(), createPositiveOnline(), createVolunteer()
        ]
    }
    
    static func getChallengesByType(_ type: ChallendgeType) -> [ChallengeModel] {
        return getAllChallenges().filter { $0.type == type }
    }
    
    static func getRandomChallenge() -> ChallengeModel {
        return getAllChallenges().randomElement()!
    }
    
    static func getRandomChallenge(ofType type: ChallendgeType) -> ChallengeModel {
        return getChallengesByType(type).randomElement()!
    }
}
