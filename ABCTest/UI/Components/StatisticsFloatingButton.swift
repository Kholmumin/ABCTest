import SwiftUI

struct StatisticsFloatingButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: AppConstants.SystemImage.chartBarFill)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: AppConstants.Layout.floatingButtonSize, height: AppConstants.Layout.floatingButtonSize)
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(
                    color: .black.opacity(AppConstants.Animation.shadowOpacity),
                    radius: AppConstants.Animation.shadowRadius,
                    x: AppConstants.Animation.shadowOffsetX,
                    y: AppConstants.Animation.shadowOffsetY
                )
        }
        .padding(.trailing, AppConstants.Layout.largePadding)
        .padding(.bottom, AppConstants.Layout.largePadding)
    }
}
