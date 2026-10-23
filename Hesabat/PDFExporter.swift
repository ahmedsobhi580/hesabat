import UIKit

struct PayrollPDF {
    static func make(worker: Worker, store: Store) -> URL? {
        let s = store.summary(worker: worker)
        let bounds = CGRect(x: 0, y: 0, width: 595, height: 842) // A4
        let renderer = UIGraphicsPDFRenderer(bounds: bounds)
        let data = renderer.pdfData { context in
            context.beginPage()
            var y: CGFloat = 40
            func line(_ text: String, size: CGFloat = 12, bold: Bool = false) {
                let style = NSMutableParagraphStyle()
                style.alignment = .right
                let font = bold ? UIFont.boldSystemFont(ofSize: size) : UIFont.systemFont(ofSize: size)
                let attrs: [NSAttributedString.Key: Any] = [.font: font, .paragraphStyle: style]
                text.draw(in: CGRect(x: 40, y: y, width: bounds.width - 80, height: size + 8), withAttributes: attrs)
                y += size + 10
            }
            line("كشف مرتب — \(worker.name)", size: 18, bold: true)
            line("\(worker.job)", size: 11)
            y += 8
            line("أيام الحضور: \(s.presentDays)    أيام الغياب: \(s.absentDays)")
            y += 4
            line("الأجر الأساسي: \(money(s.base))")
            line("إضافي (ساعة بساعة ونص): +\(money(s.ot))")
            line("خصم التأخير: −\(money(s.late))")
            line("خصم الغياب: −\(money(s.absenceDed))")
            line("السلف المسحوبة: −\(money(s.advancesTotal))")
            y += 4
            line("الصافي المستحق: \(money(s.net))", size: 15, bold: true)
            y += 12
            line("توقيع العامل: ..............        توقيع المحاسب: ..............", size: 10)
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("payroll-\(worker.id.uuidString).pdf")
        try? data.write(to: url)
        return url
    }
}
