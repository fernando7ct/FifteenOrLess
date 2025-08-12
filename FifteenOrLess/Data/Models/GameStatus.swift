import Foundation

enum GameStatus: Codable, Equatable {
    case settingUp
    case ongoing
    case gameOver(win: Bool)
}
