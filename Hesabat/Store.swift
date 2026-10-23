import Foundation

class Store: ObservableObject {
    @Published var workers: [Worker] = []
    @Published var records: [DayRecord] = []
    @Published var absences: [AbsenceRecord] = []
    @Published var advances: [AdvanceRecord] = []

    init() { load() }

    // MARK: - حسابات الوردية
    func hourRate(_ w: Worker) -> Double { w.wage / ShiftRules.hours }
    func lateHours(tIn: Double) -> Double { max(0, tIn - ShiftRules.start) }
    func otHours(tOut: Double) -> Double { max(0, tOut - ShiftRules.end) }
    func lateDeduction(w: Worker, tIn: Double) -> Double {
        lateHours(tIn: tIn) * ShiftRules.rate * hourRate(w)
    }
    func overtimePay(w: Worker, tOut: Double) -> Double {
        otHours(tOut: tOut) * ShiftRules.rate * hourRate(w)
    }
    func netDay(w: Worker, tIn: Double, tOut: Double) -> Double {
        w.wage + overtimePay(w: w, tOut: tOut) - lateDeduction(w: w, tIn: tIn)
    }

    // MARK: - حالة العامل في يوم معين
    enum Status { case none, present, absent }
    func sameDay(_ a: Date, _ b: Date) -> Bool {
        Calendar.current.isDate(a, inSameDayAs: b)
    }
    func status(worker: Worker, on day: Date) -> Status {
        if absences.contains(where: { $0.workerId == worker.id && sameDay($0.day, day) }) { return .absent }
        if records.contains(where: { $0.workerId == worker.id && sameDay($0.day, day) }) { return .present }
        return .none
    }

    func markPresent(worker: Worker, on day: Date, tIn: Double, tOut: Double) {
        records.removeAll { $0.workerId == worker.id && sameDay($0.day, day) }
        records.append(DayRecord(workerId: worker.id, day: day, tIn: tIn, tOut: tOut))
        save()
    }
    func markAbsent(worker: Worker, on day: Date) {
        records.removeAll { $0.workerId == worker.id && sameDay($0.day, day) }
        if !absences.contains(where: { $0.workerId == worker.id && sameDay($0.day, day) }) {
            absences.append(AbsenceRecord(workerId: worker.id, day: day))
        }
        save()
    }
    func undoAbsent(worker: Worker, on day: Date) {
        absences.removeAll { $0.workerId == worker.id && sameDay($0.day, day) }
        markPresent(worker: worker, on: day, tIn: ShiftRules.start, tOut: ShiftRules.end)
    }

    // MARK: - ملخص مرتب العامل
    struct Summary {
        var presentDays: Int
        var absentDays: Int
        var base: Double
        var ot: Double
        var late: Double
        var absenceDed: Double
        var advancesTotal: Double
        var net: Double
    }
    func summary(worker: Worker) -> Summary {
        let recs = records.filter { $0.workerId == worker.id }
        let abs = absences.filter { $0.workerId == worker.id }
        let adv = advances.filter { $0.workerId == worker.id }
        let base = Double(recs.count) * worker.wage
        let ot = recs.reduce(0) { $0 + overtimePay(w: worker, tOut: $1.tOut) }
        let late = recs.reduce(0) { $0 + lateDeduction(w: worker, tIn: $1.tIn) }
        let absDed = Double(abs.count) * worker.wage
        let advSum = adv.reduce(0) { $0 + $1.amount }
        return Summary(
            presentDays: recs.count, absentDays: abs.count,
            base: base, ot: ot, late: late, absenceDed: absDed,
            advancesTotal: advSum, net: base + ot - late - absDed - advSum
        )
    }

    // MARK: - إضافة وحذف
    func addWorker(name: String, job: String, wage: Double) {
        workers.append(Worker(name: name, job: job, wage: wage))
        save()
    }
    func addAdvance(worker: Worker, day: Date, amount: Double, method: PayMethod) {
        advances.append(AdvanceRecord(workerId: worker.id, day: day, amount: amount, method: method))
        save()
    }
    func deleteAdvance(_ a: AdvanceRecord) { advances.removeAll { $0.id == a.id }; save() }
    func deleteAbsence(_ a: AbsenceRecord) { absences.removeAll { $0.id == a.id }; save() }

    // MARK: - الحفظ على الجهاز (UserDefaults)
    private let kW = "workers", kR = "records", kA = "absences", kV = "advances"
    func save() {
        let enc = JSONEncoder()
        if let d = try? enc.encode(workers) { UserDefaults.standard.set(d, forKey: kW) }
        if let d = try? enc.encode(records) { UserDefaults.standard.set(d, forKey: kR) }
        if let d = try? enc.encode(absences) { UserDefaults.standard.set(d, forKey: kA) }
        if let d = try? enc.encode(advances) { UserDefaults.standard.set(d, forKey: kV) }
    }
    func load() {
        let dec = JSONDecoder()
        if let d = UserDefaults.standard.data(forKey: kW), let v = try? dec.decode([Worker].self, from: d) { workers = v }
        if let d = UserDefaults.standard.data(forKey: kR), let v = try? dec.decode([DayRecord].self, from: d) { records = v }
        if let d = UserDefaults.standard.data(forKey: kA), let v = try? dec.decode([AbsenceRecord].self, from: d) { absences = v }
        if let d = UserDefaults.standard.data(forKey: kV), let v = try? dec.decode([AdvanceRecord].self, from: d) { advances = v }
        if workers.isEmpty {
            workers = [
                Worker(name: "محمود عبد الله", job: "نجار", wage: 350),
                Worker(name: "أحمد سمير", job: "حداد", wage: 300),
                Worker(name: "كريم فتحي", job: "عامل بناء", wage: 250),
                Worker(name: "مصطفى إبراهيم", job: "سائق", wage: 400),
            ]
        }
    }
}
