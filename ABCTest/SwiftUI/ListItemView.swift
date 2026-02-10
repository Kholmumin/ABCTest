//
//  ListItemView.swift
//  TestABC
//
//  Created by Kholmumin on 10/02/26.
//

import SwiftUI

struct ListItemView: View {
    let item: Item
    
    var body: some View {
        HStack {
            AsyncImage(url: item.image) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
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
        .frame(height: 120)
        .background(Color.gray.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding()
    }
}

#Preview {
    let item = Item(image: URL(string: "https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?w=800")!, title: "Welcome", description: "Lets, build something cool")
     ListItemView(item: item)
}
