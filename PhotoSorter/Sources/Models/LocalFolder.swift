import Foundation
import SwiftData

@Model
final class LocalFolder {
    var id: UUID
    var name: String
    var createdAt: Date
    var ownerUserId: String

    @Relationship(deleteRule: .cascade, inverse: \LocalPhoto.folder)
    var photos: [LocalPhoto] = []

    init(name: String, ownerUserId: String) {
        self.id = UUID()
        self.name = name
        self.ownerUserId = ownerUserId
        self.createdAt = Date()
    }
}
