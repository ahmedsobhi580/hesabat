import Foundation

struct Worker: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var job: String
    var wage: Double
}

enum PayMethod: String, Codable, CaseIterable {
    case cash, insta, vodafone
    var label: String {
        switch self {
        case .cash: return "نقدي"
        case .insta: return "انستا باي"
        case .vodafone: return "فودافون كاش"
        }
    }
}

struct DayRecord: Identifiable, Codable, Equatable {
    var id = UUID()
    var workerId: UUID
    var day: Date
    var tIn: Double
    var tOut: Double
}

struct AbsenceRecord: Identifiable, Codable, Equatable {
    var id = UUID()
    var workerId: UUID
    var day: Date
    var note: String = "بدون إذن"
}

struct AdvanceRecord: Identifiable, Codable, Equatable {
    var id = UUID()
    var workerId: UUID
    var day: Date
    var amount: Double
    var method: PayMethod
}

// قواعد الوردية: 8 صباحاً - 5 مساءً، والساعة بساعة ونص
struct ShiftRules {
    static let start = 8.0
    static let end = 17.0
    static let hours = 9.0
    static let rate = 1.5
}
