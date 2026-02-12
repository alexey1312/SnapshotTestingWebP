#if os(iOS) || os(tvOS)
    import SwiftUI

    @available(iOS 15.0, tvOS 15.0, *)
    struct SwiftUIView: View {
        var body: some View {
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        headerCard
                        metricsGrid
                        chartCard
                        recentActivityCard
                        itemsList
                        settingsCard
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle("WebP Dashboard")
                .navigationBarTitleDisplayMode(.large)
            }
            .navigationViewStyle(.stack)
        }

        private var headerCard: some View {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("WebP Processing")
                            .font(.title2.bold())
                            .foregroundColor(.primary)

                        Text("Advanced compression testing")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "photo.stack.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                }

                Divider()

                HStack(spacing: 30) {
                    StatisticView(title: "Files Processed", value: "1,247")
                    StatisticView(title: "Space Saved", value: "2.1 GB")
                    StatisticView(title: "Avg. Compression", value: "68%")
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }

        private var metricsGrid: some View {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                MetricCard(
                    title: "Processing Speed",
                    value: "2.3x",
                    subtitle: "faster than PNG",
                    color: .green,
                    icon: "speedometer"
                )

                MetricCard(
                    title: "Quality Retention",
                    value: "98.5%",
                    subtitle: "visual fidelity",
                    color: .blue,
                    icon: "star.fill"
                )

                MetricCard(
                    title: "File Size",
                    value: "-35%",
                    subtitle: "reduction",
                    color: .orange,
                    icon: "arrow.down.circle.fill"
                )

                MetricCard(
                    title: "Memory Usage",
                    value: "12.4 MB",
                    subtitle: "peak usage",
                    color: .purple,
                    icon: "memorychip"
                )
            }
        }

        private static let barHeights: [CGFloat] = [65, 85, 45, 95, 70, 55, 80]

        private var chartCard: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Performance Trends")
                    .font(.headline)

                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(0 ..< 7) { index in
                        VStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue.opacity(0.7))
                                .frame(width: 30, height: Self.barHeights[index])

                            Text("D\(index + 1)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: 120)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }

        private var recentActivityCard: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Recent Activity")
                    .font(.headline)

                VStack(spacing: 12) {
                    ActivityRow(
                        icon: "checkmark.circle.fill",
                        color: .green,
                        title: "WebP Compression Completed",
                        subtitle: "image_set_001.png -> 2.1MB saved"
                    )

                    ActivityRow(
                        icon: "gear.circle.fill",
                        color: .blue,
                        title: "Settings Updated",
                        subtitle: "Quality preset changed to 'Balanced'"
                    )

                    ActivityRow(
                        icon: "exclamationmark.triangle.fill",
                        color: .orange,
                        title: "Warning",
                        subtitle: "Large file detected: consider preprocessing"
                    )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }

        private var itemsList: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Test Items")
                    .font(.headline)

                ForEach(ListItem.sampleData) { item in
                    ListItemRow(item: item)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }

        private var settingsCard: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Configuration")
                    .font(.headline)

                VStack(spacing: 8) {
                    SettingRow(icon: "photo.on.rectangle", color: .blue, title: "Image Format", value: "WebP")
                    SettingRow(icon: "speedometer", color: .green, title: "Compression Speed", value: "Fast")
                    SettingRow(icon: "cpu", color: .orange, title: "Hardware Acceleration", value: "Enabled")
                    SettingRow(icon: "memorychip", color: .red, title: "Memory Usage", value: "12.4 MB")
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
    }

    // MARK: - Supporting Views

    @available(iOS 15.0, tvOS 15.0, *)
    struct StatisticView: View {
        let title: String
        let value: String

        var body: some View {
            VStack(spacing: 4) {
                Text(value)
                    .font(.title2.bold())
                    .foregroundColor(.primary)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    @available(iOS 15.0, tvOS 15.0, *)
    struct MetricCard: View {
        let title: String
        let value: String
        let subtitle: String
        let color: Color
        let icon: String

        var body: some View {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(.title2.bold())
                        .foregroundColor(.primary)

                    Text(title)
                        .font(.caption)
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
        }
    }

    struct ActivityRow: View {
        let icon: String
        let color: Color
        let title: String
        let subtitle: String

        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
        }
    }

    struct ListItemRow: View {
        let item: ListItem

        var body: some View {
            HStack {
                Image(systemName: item.status.icon)
                    .foregroundColor(item.status.color)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.subheadline)

                    Text(item.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(item.status.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(item.status.color.opacity(0.2))
                    )
                    .foregroundColor(item.status.color)
            }
            .padding(.vertical, 2)
        }
    }

    struct SettingRow: View {
        let icon: String
        let color: Color
        let title: String
        let value: String

        var body: some View {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)

                Text(title)
                    .font(.subheadline)

                Spacer()

                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }

    struct ListItem: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let status: Status

        enum Status: CaseIterable {
            case completed, processing, pending, failed

            var displayName: String {
                switch self {
                case .completed: return "Done"
                case .processing: return "Processing"
                case .pending: return "Pending"
                case .failed: return "Failed"
                }
            }

            var color: Color {
                switch self {
                case .completed: return .green
                case .processing: return .blue
                case .pending: return .orange
                case .failed: return .red
                }
            }

            var icon: String {
                switch self {
                case .completed: return "checkmark.circle.fill"
                case .processing: return "arrow.clockwise.circle.fill"
                case .pending: return "clock.circle.fill"
                case .failed: return "xmark.circle.fill"
                }
            }
        }

        static let sampleData: [ListItem] = [
            ListItem(title: "WebP Conversion Test 1", subtitle: "High quality compression", status: .completed),
            ListItem(title: "Batch Processing", subtitle: "100 images processed", status: .processing),
            ListItem(title: "Performance Benchmark", subtitle: "Speed vs quality analysis", status: .pending),
            ListItem(title: "Memory Optimization", subtitle: "Reduce memory footprint", status: .completed),
            ListItem(title: "Error Handling Test", subtitle: "Invalid format handling", status: .failed),
            ListItem(title: "Large File Processing", subtitle: "4K image compression", status: .pending),
        ]
    }

    @available(iOS 15.0, tvOS 15.0, *)
    struct SwiftUIView_Previews: PreviewProvider {
        static var previews: some View {
            SwiftUIView()
                .preferredColorScheme(.light)

            SwiftUIView()
                .preferredColorScheme(.dark)
        }
    }
#endif
