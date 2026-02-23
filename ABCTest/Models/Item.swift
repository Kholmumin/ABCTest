import Foundation

nonisolated struct Item: Hashable, Sendable {
    let id: String = UUID().uuidString
    let image: URL?
    let title: String
    let description: String
}
