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
        HStack(spacing: AppConstants.Layout.smallSpacing) {
            Image(systemName: AppConstants.SystemImage.magnifyingGlass)
                .foregroundStyle(.secondary)
                .font(.system(size: AppConstants.FontSize.searchIcon, weight: .medium))

            TextField(AppConstants.Text.searchPlaceholder, text: $searchText)
                .textFieldStyle(.automatic)
                .font(.system(size: AppConstants.FontSize.searchField))
                .frame(height: AppConstants.Layout.searchBarHeight)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .background(.clear)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: AppConstants.SystemImage.xMarkCircleFill)
                        .foregroundStyle(.secondary)
                        .font(.system(size: AppConstants.FontSize.clearButton))
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, AppConstants.Layout.defaultPadding)
        .padding(.vertical, AppConstants.Layout.smallSpacing)
        .background(
            RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius)
                .fill(Color(.systemGray6))
        )
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Layout.extraLargeCornerRadius))
    }
}

#Preview {
    SearchBar(searchText: .constant(""))
}
