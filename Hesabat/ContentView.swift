import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack { WorkersView() }
                .tabItem { Label("العمال", systemImage: "person.3") }
            NavigationStack { AttendanceView() }
                .tabItem { Label("الحضور", systemImage: "clock") }
            NavigationStack { AdvancesView() }
                .tabItem { Label("السلف", systemImage: "banknote") }
            NavigationStack { AbsencesView() }
                .tabItem { Label("الغياب", systemImage: "xmark.person") }
            NavigationStack { ReportView() }
                .tabItem { Label("التقرير", systemImage: "doc.text") }
        }
    }
}
