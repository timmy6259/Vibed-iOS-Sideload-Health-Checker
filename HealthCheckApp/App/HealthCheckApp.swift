import Foundation
import SwiftUI
import Security

@main
struct HealthCheckApp: App {
    @StateObject private var model = HealthModel()

    var body: some Scene {
        WindowGroup {
            HealthCheckView(model: model)
                .task {
                    model.refresh()
                }
        }
    }
}

@MainActor
final class HealthModel: ObservableObject {
    @Published var jitStatus: HealthMetric = .init(title: "JIT", value: "Checking...", isGood: false, detail: "")
    @Published var signingStatus: HealthMetric = .init(title: "Signing", value: "Checking...", isGood: false, detail: "")
    @Published var jailbreakStatus: HealthMetric = .init(title: "Jailbreak", value: "Checking...", isGood: false, detail: "")
    @Published var updatedAt: Date = Date()

    func refresh() {
        let jitResult = JITProbe.check()
        let signingResult = SigningInspector.check()
        let jailbreakResult = JailbreakInspector.check()

        jitStatus = jitResult
        signingStatus = signingResult
        jailbreakStatus = jailbreakResult
        updatedAt = Date()
    }
}

struct HealthMetric {
    var title: String
    var value: String
    var isGood: Bool
    var detail: String
}

struct HealthCheckApp_Previews: PreviewProvider {
    static var previews: some View {
        HealthCheckView(model: .init())
    }
}
