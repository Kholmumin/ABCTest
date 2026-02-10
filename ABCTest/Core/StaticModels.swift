//
//  StaticModels.swift
//  ABCTest
//
//  Created by Kholmumin on 10/02/26.
//


import Foundation

final class StaticModels {
    static let shared = StaticModels()
    private init() {}

    let sampleItems: [Item] = [
        Item(
            image: URL(string: "https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?w=800"),
            title: "Mountain Sunrise",
            description: "A peaaaaaceful view of the sun rising over the mountains."
        ),
        Item(
            image: URL(string: "https://images.unsplash.com/photo-1511765224389-37f0e77cf0eb?w=800"),
            title: "Forest Trail",
            description: "A quiet paaaaath through green and dense forest."
        ),
        Item(
            image: URL(string: "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=800"),
            title: "City Lights",
            description: "Night skyline glooowing with city life."
        ),
        Item(
            image: URL(string: "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800"),
            title: "Desert Road",
            description: "An endless road through golden sand."
        ),
        Item(
            image: URL(string: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800"),
            title: "Calm Lake",
            description: "Mirror-like water reflecting the sky."
        ),
        Item(
            image: URL(string: "https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=800"),
            title: "Foggy Bridge",
            description: "A mysterious bridge disappearing into fog."
        ),
        Item(
            image: URL(string: "https://images.unsplash.com/photo-1493246507139-91e8fad9978e?w=800"),
            title: "Tropical Waterfall",
            description: "Crystal clear water falling into a blue pool."
        ),
        Item(
            image: URL(string: "https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=800"),
            title: "Countryside Field",
            description: "Golden wheat fields under a blue sky."
        )
    ]
}
