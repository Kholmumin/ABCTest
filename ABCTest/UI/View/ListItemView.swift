import SwiftUI

struct ListItemView: View {
    let item: Item
    
    var body: some View {
        HStack {
            AsyncImage(url: item.image) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: AppConstants.Layout.imageSize, height: AppConstants.Layout.imageSize)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.Layout.largeCornerRadius))
            } placeholder: {
                ProgressView()
            }
            .padding(.leading)
            
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(item.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
            }
            .padding(.leading, 5)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: AppConstants.Layout.listItemHeight)
        .background(Color.gray.opacity(AppConstants.Animation.backgroundOpacity))
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Layout.largeCornerRadius))
        .padding()
    }
}

#Preview {
    let item = Item(
        image: URL(string: "https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?w=800"),
        title: "Welcome",
        description: "Lets, build something cool"
    )
    ListItemView(item: item)
}
