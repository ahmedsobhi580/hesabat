import Foundation

let moneyFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    f.maximumFractionDigits = 0
    return f
}()

func money(_ v: Double) -> String {
    (moneyFormatter.string(from: NSNumber(value: v)) ?? "0") + " ج.م"
}

let inTimes: [(Double, String)] = [
    (6.5, "6:30 ص"), (7, "7:00 ص"), (7.5, "7:30 ص"), (8, "8:00 ص"),
    (8.5, "8:30 ص"), (9, "9:00 ص"), (9.5, "9:30 ص"), (10, "10:00 ص")
]

let outTimes: [(Double, String)] = [
    (15, "3:00 م"), (16, "4:00 م"), (16.5, "4:30 م"), (17, "5:00 م"),
    (17.5, "5:30 م"), (18, "6:00 م"), (18.5, "6:30 م"), (19, "7:00 م"), (20, "8:00 م")
]

func timeLabel(_ list: [(Double, String)], _ v: Double) -> String {
    list.first(where: { abs($0.0 - v) < 0.001 })?.1 ?? "—"
}

func arabicDay(_ d: Date) -> String {
    let f = DateFormatter()
    f.locale = Locale(identifier: "ar")
    f.dateFormat = "EEEE d MMMM"
    return f.string(from: d)
}
