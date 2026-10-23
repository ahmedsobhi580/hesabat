import SwiftUI

struct WorkersView: View {
    @EnvironmentObject var store: Store
    @State private var showAdd = false

    var body: some View {
        List(store.workers) { w in
            let adv = store.advances.filter { $0.workerId == w.id }.reduce(0) { $0 + $1.amount }
            HStack {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(w.name).font(.headline)
                    Text("\(w.job) · \(money(w.wage)) / يوم · سلف: \(money(adv))")
                        .font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                todayStatus(w)
            }
        }
        .navigationTitle("العمال")
        .toolbar { Button("+ عامل") { showAdd = true } }
        .sheet(isPresented: $showAdd) { AddWorkerSheet() }
    }

    @ViewBuilder func todayStatus(_ w: Worker) -> some View {
        switch store.status(worker: w, on: Date()) {
        case .present: Text("حاضر").font(.caption).foregroundColor(.green)
        case .absent: Text("غائب").font(.caption).foregroundColor(.red)
        case .none: Text("لم يُسجَّل").font(.caption).foregroundColor(.secondary)
        }
    }
}

struct AddWorkerSheet: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var job = ""
    @State private var wage = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("اسم العامل", text: $name)
                TextField("الوظيفة", text: $job)
                TextField("الأجر اليومي (ج.م)", text: $wage).keyboardType(.numberPad)
            }
            .navigationTitle("إضافة عامل")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("إلغاء") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("إضافة") {
                        store.addWorker(name: name, job: job.isEmpty ? "عامل" : job, wage: Double(wage) ?? 0)
                        dismiss()
                    }.disabled(name.isEmpty)
                }
            }
        }
    }
}
