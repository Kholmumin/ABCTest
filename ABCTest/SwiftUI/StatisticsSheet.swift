//
//  StatisticsSheet.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//

import SwiftUI

struct StatisticsSheet: View {
    let itemCount: Int
    let topCharacters: [(Character, Int)]

    var body: some View {
        VStack(spacing: 20) {
            Text("Statistics")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 20)
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "list.bullet")
                        .foregroundStyle(.blue)
                        .font(.title2)
                    Text("List 1")
                        .font(.headline)
                    Spacer()
                    Text("\(itemCount) items")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                makeBottomUI()
            }
            .padding(.horizontal)
            Spacer()
        }
    }

    func makeBottomUI() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top 3 Characters")
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
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
