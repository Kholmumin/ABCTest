
import Foundation

nonisolated struct Item: Hashable, Sendable {
    let image: URL?
    let title: String
    let description: String
}
