import Foundation

struct Guess: Identifiable, Codable {
    var id = UUID()
    var targetWord: String
    var guess: String
    var isCorrect: Bool {
        targetWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == guess.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
