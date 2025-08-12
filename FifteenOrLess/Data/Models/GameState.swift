import Foundation

struct GameState: Codable {
    var gameState: GameStatus
    var mastermindPlayerID: String
    var targetWords: [String]
    var targetWordIndex: Int
    var hints: [Hint]
    var guesses: [Guess]
    var rematchRequests: [String: Bool]
    var forfeitRequests: [String: Bool]
    var playersLeft: [String: Bool]
    var playersQuit: [String: Bool]
    
    init(viewModel: ViewModel) {
        gameState = viewModel.gameState
        mastermindPlayerID = viewModel.mastermindPlayerID
        targetWords = viewModel.targetWords
        targetWordIndex = viewModel.targetWordIndex
        hints = viewModel.hints
        guesses = viewModel.guesses
        rematchRequests = viewModel.rematchRequests
        forfeitRequests = viewModel.forfeitRequests
        playersLeft = viewModel.playersLeft
        playersQuit = viewModel.playersQuit
    }
}
