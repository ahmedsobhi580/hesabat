import SwiftUI

struct AttendanceView: View {
    @EnvironmentObject var store: Store
    @State private var month = Date()
    @State private var selected = Date()
    private let cols = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    var body: some View {
        List {
            Section {
                HStack {
                    Text(monthTitle).font(.headline)
                    Spacer()
                    Button { changeMonth(-1) } label: { Image(systemName: "chevron.right") }
                    Button("اليوم") { selected = Date() }.font(.caption)
                    Button { changeMonth(1) } label: { Image(systemName: "chevron.left") }
                }
                LazyVGrid(columns: cols, spacing: 2) {
                    ForEach(["سبت","أحد","اثنين","ثلاثاء","أربعاء","خميس","جمعة"], id: \.self) { n in
                        Text(n).font(.system(size: 10)).foregroundColor(.secondary)
                    }
                    ForEach(Array(grid.enumerated()), id: \.offset) { _, item in
                        if let d = item {
                            DayCell(date: d, isSelected: Calendar.current.isDate(d, inSameDayAs: selected))
                                .onTapGesture { selected = d }
                        } else {
                            Color.clear.frame(height: 34)
                        }
                    }
                }
                Text("اضغط على أي يوم لتسجيله أو تعديله · علامة ؟ يعني يوم ناقص التسجيل")
                    .font(.caption2).foregroundColor(.secondary)
            }
            Section("تسجيل يوم \(arabicDay(selected))") {
                ForEach(store.workers) { w in
                    WorkerDayRow(worker: w, day: selected)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    var monthTitle: String {
        let f = DateFormatter(); f.locale = Locale(identifier: "ar"); f.dateFormat = "MMMM yyyy"
        return f.string(from: month)
    }
    func changeMonth(_ v: Int) {
        month = Calendar.current.date(byAdding: .month, value: v, to: month) ?? month
    }
    var grid: [Date?] {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 7 // الأسبوع يبدأ السبت
        let comp = cal.dateComponents([.year, .month], from: month)
        guard let first = cal.date(from: comp), let range = cal.range(of: .day, in: .month, for: month) else { return [] }
        let offset = (cal.component(.weekday, from: first) - cal.firstWeekday + 7) % 7
        var days: [Date?] = Array(repeating: nil, count: offset)
        for d in 0..<range.count { days.append(cal.date(byAdding: .day, value: d, to: first)) }
        return days
    }
}

struct DayCell: View {
    @EnvironmentObject var store: Store
    let date: Date
    let isSelected: Bool

    var body: some View {
        let p = store.records.filter { store.sameDay($0.day, date) }.count
        let a = store.absences.filter { store.sameDay($0.day, date) }.count
        let missing = store.workers.count - p - a
        VStack(spacing: 1) {
            Text("\(Calendar.current.component(.day, from: date))").font(.system(size: 11))
            HStack(spacing: 2) {
                if p > 0 { badge("\(p)", .green) }
                if a > 0 { badge("\(a)", .red) }
                if missing > 0 && date <= Date() { badge("؟", .orange) }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(isSelected ? Color.primary.opacity(0.12) : Color.clear)
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(isSelected ? Color.primary : Color.gray.opacity(0.3), lineWidth: 1))
    }
    func badge(_ t: String, _ c: Color) -> some View {
        Text(t).font(.system(size: 9)).padding(.horizontal, 3)
            .background(c.opacity(0.15)).cornerRadius(3).foregroundColor(c)
    }
}

struct WorkerDayRow: View {
    @EnvironmentObject var store: Store
    let worker: Worker
    let day: Date
    @State private var tIn: Double = ShiftRules.start
    @State private var tOut: Double = ShiftRules.end

    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            HStack {
                Text(worker.name).font(.headline)
                Text(worker.job).font(.caption).foregroundColor(.secondary)
                Spacer()
                switch store.status(worker: worker, on: day) {
                case .absent:
                    Text("غائب · خصم يوم كامل").font(.caption).foregroundColor(.red)
                    Button("تحويل لحاضر") { store.undoAbsent(worker: worker, on: day) }
                        .buttonStyle(.borderedProminent).controlSize(.small)
                case .none:
                    Button("حاضر") { store.markPresent(worker: worker, on: day, tIn: tIn, tOut: tOut) }
                        .buttonStyle(.borderedProminent).controlSize(.small)
                    Button("غائب") { store.markAbsent(worker: worker, on: day) }
                        .buttonStyle(.bordered).controlSize(.small)
                case .present:
                    Text("مسجّل").font(.caption).foregroundColor(.green)
                    Button("غائب") { store.markAbsent(worker: worker, on: day) }
                        .buttonStyle(.bordered).controlSize(.small)
                }
            }
            HStack(spacing: 8) {
                Picker("حضور", selection: $tIn) {
                    ForEach(inTimes, id: \.0) { t in Text(t.1).tag(t.0) }
                }.pickerStyle(.menu).frame(maxWidth: 120)
                Picker("انصراف", selection: $tOut) {
                    ForEach(outTimes, id: \.0) { t in Text(t.1).tag(t.0) }
                }.pickerStyle(.menu).frame(maxWidth: 120)
                Spacer()
            }
            if store.status(worker: worker, on: day) == .present {
                HStack(spacing: 8) {
                    let late = store.lateDeduction(w: worker, tIn: tIn)
                    let ot = store.overtimePay(w: worker, tOut: tOut)
                    if late > 0 {
                        Text("تأخير: خصم \(money(late))").font(.caption2).foregroundColor(.red)
                    } else {
                        Text("بدون تأخير").font(.caption2).foregroundColor(.green)
                    }
                    if ot > 0 { Text("إضافي +\(money(ot))").font(.caption2).foregroundColor(.green) }
                    Spacer()
                    Text("الصافي \(money(store.netDay(w: worker, tIn: tIn, tOut: tOut)))").font(.subheadline).bold()
                }
            }
        }
        .onAppear {
            if let r = store.records.first(where: { $0.workerId == worker.id && store.sameDay($0.day, day) }) {
                tIn = r.tIn; tOut = r.tOut
            } else {
                tIn = ShiftRules.start; tOut = ShiftRules.end
            }
        }
        .onChange(of: tIn) { _ in
            if store.status(worker: worker, on: day) == .present {
                store.markPresent(worker: worker, on: day, tIn: tIn, tOut: tOut)
            }
        }
        .onChange(of: tOut) { _ in
            if store.status(worker: worker, on: day) == .present {
                store.markPresent(worker: worker, on: day, tIn: tIn, tOut: tOut)
            }
        }
    }
}
