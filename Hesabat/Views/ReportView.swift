import SwiftUI

struct ReportView: View {
    @EnvironmentObject var store: Store
    @State private var workerId = UUID()
    @State private var pdfURL: URL?

    var current: Worker? {
        store.workers.first(where: { $0.id == workerId }) ?? store.workers.first
    }

    var body: some View {
        List {
            if let w = current {
                let s = store.summary(worker: w)
                Section {
                    Picker("العامل", selection: $workerId) {
                        ForEach(store.workers) { w2 in Text(w2.name).tag(w2.id) }
                    }
                    HStack {
                        statCell("\(s.presentDays)", "أيام حضور")
                        statCell("\(s.absentDays)", "أيام غياب")
                        statCell(money(w.wage), "الأجر اليومي")
                    }
                }
                Section("الملخص") {
                    row("الأجر الأساسي", money(s.base), nil)
                    row("إضافي الليل ×1.5", "+ \(money(s.ot))", .green)
                    row("خصم التأخير ×1.5", "− \(money(s.late))", .red)
                    row("خصم الغياب", "− \(money(s.absenceDed))", .red)
                    row("السلف المسحوبة", "− \(money(s.advancesTotal))", .red)
                    HStack { Text("الصافي المستحق").bold(); Spacer(); Text(money(s.net)).bold() }
                }
                Section {
                    Button("تصدير كشف PDF للعامل") { pdfURL = PayrollPDF.make(worker: w, store: store) }
                    if let url = pdfURL {
                        ShareLink(item: url) { Label("مشاركة الكشف (واتساب / إيميل)", systemImage: "square.and.arrow.up") }
                    }
                }
                Section("تفاصيل الأيام") {
                    ForEach(store.records.filter { $0.workerId == w.id }.sorted { $0.day < $1.day }) { r in
                        VStack(alignment: .trailing, spacing: 2) {
                            HStack {
                                Text(arabicDay(r.day))
                                Spacer()
                                Text(money(store.netDay(w: w, tIn: r.tIn, tOut: r.tOut)))
                            }
                            HStack {
                                Text("\(timeLabel(inTimes, r.tIn)) → \(timeLabel(outTimes, r.tOut)) · \(String(format: "%.1f", r.tOut - r.tIn)) ساعة")
                                    .font(.caption).foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                    }
                    ForEach(store.absences.filter { $0.workerId == w.id }.sorted { $0.day < $1.day }) { a in
                        HStack {
                            Text(arabicDay(a.day))
                            Text(a.note).font(.caption).foregroundColor(.secondary)
                            Spacer()
                            Text("− \(money(w.wage))").foregroundColor(.orange)
                        }
                    }
                }
                if !store.advances.filter({ $0.workerId == w.id }).isEmpty {
                    Section("السلف وطريقة الدفع") {
                        ForEach(store.advances.filter { $0.workerId == w.id }.sorted { $0.day > $1.day }) { a in
                            HStack {
                                Text(arabicDay(a.day))
                                Spacer()
                                Text(a.method.label).font(.caption).foregroundColor(.secondary)
                                Text(money(a.amount))
                            }
                        }
                    }
                }
            } else {
                Text("أضف عاملًا من تبويب العمال أولًا")
            }
        }
        .navigationTitle("التقرير الشهري")
        .onAppear { if current == nil { workerId = store.workers.first?.id ?? UUID() } }
    }

    func statCell(_ v: String, _ l: String) -> some View {
        VStack {
            Text(v).font(.headline)
            Text(l).font(.caption2).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    func row(_ t: String, _ v: String, _ c: Color?) -> some View {
        HStack { Text(t); Spacer(); Text(v).foregroundColor(c ?? .primary) }
    }
}
