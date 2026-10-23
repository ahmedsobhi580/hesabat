import SwiftUI

struct AbsencesView: View {
    @EnvironmentObject var store: Store
    @State private var day = Date()

    var body: some View {
        List {
            Section("تسجيل غياب يوم \(arabicDay(day))") {
                DatePicker("اليوم", selection: $day, displayedComponents: .date)
                ForEach(store.workers) { w in
                    HStack {
                        Text(w.name)
                        Spacer()
                        if store.absences.contains(where: { $0.workerId == w.id && store.sameDay($0.day, day) }) {
                            Text("غائب").font(.caption).foregroundColor(.red)
                        } else {
                            Button("تسجيل غياب") { store.markAbsent(worker: w, on: day) }
                                .buttonStyle(.bordered).controlSize(.small)
                        }
                    }
                }
            }
            Section("سجل الغيابات") {
                ForEach(store.absences.sorted { $0.day > $1.day }) { a in
                    if let w = store.workers.first(where: { $0.id == a.workerId }) {
                        HStack {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(w.name)
                                Text("\(arabicDay(a.day)) · \(a.note)").font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("− \(money(w.wage))").foregroundColor(.orange)
                        }
                        .swipeActions { Button("حذف", role: .destructive) { store.deleteAbsence(a) } }
                    }
                }
            }
        }
        .navigationTitle("الغياب")
    }
}
