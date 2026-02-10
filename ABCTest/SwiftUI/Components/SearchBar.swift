//
//  SearchBar.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String

    var body: some View {        
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .font(.system(size: 18, weight: .medium))

            TextField("Search", text: $searchText)
                .textFieldStyle(.automatic)
                .font(.system(size: 16))
                .frame(height: 25)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .background(.clear)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 16))
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
}

#Preview {
    SearchBar(searchText: .constant(""))
}
