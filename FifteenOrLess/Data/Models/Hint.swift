import Foundation

struct Hint: Identifiable, Codable {
    var id = UUID()
    var targetWord: String
    var hint: String
}
