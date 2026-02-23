import SwiftUI

struct StatisticsSheet: View {
    let itemCount: Int
    let topCharacters: [(Character, Int)]

    var body: some View {
        VStack(spacing: AppConstants.Layout.largeSpacing) {
            Text(AppConstants.Text.statisticsTitle)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, AppConstants.Layout.largeSpacing)
            
            VStack(alignment: .leading, spacing: AppConstants.Layout.mediumSpacing) {
                HStack {
                    Image(systemName: AppConstants.SystemImage.listBullet)
                        .foregroundStyle(.blue)
                        .font(.title2)
                    Text(AppConstants.Text.listTitle)
                        .font(.headline)
                    Spacer()
                    Text(String(format: AppConstants.Text.itemsFormat, itemCount))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius))
                
                makeBottomView()
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }

    func makeBottomView() -> some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.smallSpacing) {
            Text(AppConstants.Text.topCharactersTitle)
                .font(.headline)
                .padding(.bottom, 4)
            
            ForEach(Array(topCharacters.enumerated()), id: \.offset) { index, entry in
                HStack {
                    Text("\(index + 1).")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(width: 24)

                    Text(String(entry.0))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                        .frame(width: 40)

                    ProgressView(value: Double(entry.1), total: Double(topCharacters.first?.1 ?? 1))
                        .tint(progressColor(for: index))

                    Text("= \(entry.1)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(width: 50, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius))
    }
    
    private func progressColor(for index: Int) -> Color {
        switch index {
        case 0: return .blue
        case 1: return .green
        case 2: return .orange
        default: return .gray
        }
    }
}
