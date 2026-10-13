import SwiftUI

struct HealthCheckView: View {
    @ObservedObject var model: HealthModel

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Sideload Health")
                        .font(.largeTitle.weight(.bold))
                        .padding(.top, 20)

                    VStack(spacing: 14) {
                        StatusCard(metric: model.jitStatus)
                        StatusCard(metric: model.signingStatus)
                        StatusCard(metric: model.jailbreakStatus)
                    }
                    .padding(.horizontal)

                    Button(action: {
                        model.refresh()
                    }) {
                        Label("Re-check", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)

                    Text("Updated: \(formattedDate(model.updatedAt))")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()
                }
            }
            .navigationTitle("Health")
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}

struct StatusCard: View {
    let metric: HealthMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(metric.title)
                    .font(.headline)
                Spacer()
                Circle()
                    .fill(metric.isGood ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
            }

            Text(metric.value)
                .font(.title3.weight(.semibold))
                .foregroundStyle(metric.isGood ? .green : .red)

            if !metric.detail.isEmpty {
                Text(metric.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }
}

#Preview {
    HealthCheckView(model: HealthModel())
}
