import SwiftUI

struct DemoUserSection: View {
    var body: some View {
        Section("Demo user") {
            LabeledContent("App User") {
                Text("Paid")
            }
            LabeledContent("MRR", value: "$9.99")
            LabeledContent("Custom ID", value: "demo-user")
        }
    }
}

#Preview {
    List {
        DemoUserSection()
    }
}
