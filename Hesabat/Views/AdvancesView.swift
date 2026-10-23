import SwiftUI

struct AdvancesView: View {
    @EnvironmentObject var store: Store
    @State private var showAdd = false

    var body: some View {
        List {
            Section {
                HStack { Text("إجمالي السلف"); Spacer(); Text(money(total)).bold() }
                Button("+ إضافة سلفة") { showAdd = true }
            }
            Section("السلف المسجلة") {
                ForEach(store.advances.sorted { $0.day > $1.day }) { a in
                    if let w = store.workers.first(where: { $0.id == a.workerId }) {
                        HStack {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(w.name)
                                Text(arabicDay(a.day)).font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(a.method.label).font(.caption).foregroundColor(.secondary)
                            Text(money(a.amount))
                        }
                        .swipeActions { Button("حذف", role: .destructive) { store.deleteAdvance(a) } }
                    }
                }
            }
        }
        .navigationTitle("السلف")
        .sheet(isPresented: $showAdd) { AddAdvanceSheet() }
    }
    var total: Double { store.advances.reduce(0) { $0 + $1.amount } }
}

struct AddAdvanceSheet: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    @State private var workerId: UUID?
    @State private var day = Date()
    @State private var amount = ""
    @State private var method: PayMethod = .cash

    var body: some View {
        NavigationStack {
            Form {
                Picker("العامل", selection: $workerId) {
                    ForEach(store.workers) { w in Text(w.name).tag(Optional(w.id)) }
                }
                DatePicker("تاريخ السلفة", selection: $day, displayedComponents: .date)
                TextField("المبلغ (ج.م)", text: $amount).keyboardType(.numberPad)
                Picker("طريقة الدفع", selection: $method) {
                    ForEach(PayMethod.allCases, id: \.self) { m in Text(m.label).tag(m) }
                }
            }
            .navigationTitle("إضافة سلفة")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("إلغاء") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("حفظ") {
                        if let w = store.workers.first(where: { $0.id == workerId }), let v = Double(amount), v > 0 {
                            store.addAdvance(worker: w, day: day, amount: v, method: method)
                            dismiss()
                        }
                    }.disabled(workerId == nil || amount.isEmpty)
                }
            }
        }
        .onAppear { if workerId == nil { workerId = store.workers.first?.id } }
    }
}
