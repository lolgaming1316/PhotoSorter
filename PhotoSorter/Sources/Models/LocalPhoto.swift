import Foundation
import SwiftData

@Model
final class LocalPhoto {
    var id: UUID
    var fileName: String
    var createdAt: Date
    var folder: LocalFolder?

    init(fileName: String, folder: LocalFolder?) {
        self.id = UUID()
        self.fileName = fileName
        self.createdAt = Date()
        self.folder = folder
    }
}
