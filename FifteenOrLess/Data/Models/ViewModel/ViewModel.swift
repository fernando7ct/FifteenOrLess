import SwiftUI
import GameKit

@Observable
class ViewModel: NSObject {
    var playingGame: Bool = false
    var playerAuthState: PlayerAuthState = .authenticating
    
    var myAvater: Image = Image(systemName: "person.crop.circle")
    var myPlayerID: String = GKLocalPlayer.local.gamePlayerID
    
    // Reset for different player
    var gkMatch: GKMatch?
    var opponentPlayerID: String = ""
    var opponentUsername: String = ""
    // Reset always
    var gameState: GameStatus = .settingUp
    var mastermindPlayerID: String = ""
    var targetWords: [String] = []
    var targetWordIndex: Int = 0
    var hints: [Hint] = []
    var guesses: [Guess] = []
    var rematchRequests: [String: Bool] = [:]
    var forfeitRequests: [String: Bool] = [:]
    var playersLeft: [String: Bool] = [:]
    var playersQuit: [String: Bool] = [:]
    
    var hintsRemaining: Int {
        15 - hints.count
    }
    
    var wordsGuessedCorrectly: Int {
        guesses.filter({ $0.isCorrect }).count
    }
    
    var playerIsMastermind: Bool {
        myPlayerID == mastermindPlayerID
    }
    
    var currentTargetWord: String {
        targetWords.indices.contains(targetWordIndex) ? targetWords[targetWordIndex] : ""
    }
    
    var opponentLeft: Bool {
        playersLeft[opponentPlayerID] ?? false
    }
    
    var opponentQuit: Bool {
        playersQuit[opponentPlayerID] ?? false
    }
    
    var opponentRequestedRematch: Bool {
        rematchRequests[opponentPlayerID] ?? false
    }
    
    var opponentRequestedForfeit: Bool {
        forfeitRequests[opponentPlayerID] ?? false
    }
    
    var playerRequestedRematch: Bool {
        rematchRequests[myPlayerID] ?? false
    }
    
    var playerRequestedForfeit: Bool {
        forfeitRequests[myPlayerID] ?? false
    }
    
    var rootViewController: UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }
    
    override init() {
        super.init()
        authenticateUser()
    }
    
    private func authenticateUser() {
        GKLocalPlayer.local.authenticateHandler = { [self] viewController, error in
            if let viewController {
                rootViewController?.present(viewController, animated: true)
                return
            }
            if let error {
                playerAuthState = .error
                print("Error authenticating user: \(error.localizedDescription)")
                return
            }
            if GKLocalPlayer.local.isAuthenticated {
                if GKLocalPlayer.local.isMultiplayerGamingRestricted {
                    playerAuthState = .restricted
                } else {
                    playerAuthState = .authenticated
                }
                GKLocalPlayer.local.loadPhoto(for: .small) { image, error in
                    if let image {
                        self.myAvater = Image(uiImage: image)
                    }
                }
            } else {
                playerAuthState = .unauthenticated
            }
        }
        GKLocalPlayer.local.register(self)
    }
    
    func setUpAndSendSharedGameData() {
        print("Setting up and sending shared game data")
        mastermindPlayerID = Bool.random() ? myPlayerID : opponentPlayerID
        targetWords = ["Hello", "Bye", "How", "Yes", "No", "Swift", "Code", "Game"]
        gameState = .ongoing
        sendGameState()
    }
    
    func setUpGame(newOpponent: Bool) {
        print("Setting up game")
        myPlayerID = GKLocalPlayer.local.gamePlayerID
        gameState = .settingUp
        playingGame = true
        targetWordIndex = 0
        hints = []
        guesses = []
        if newOpponent {
            guard let opponent = gkMatch?.players.first(where: { $0.gamePlayerID != myPlayerID }) else { return }
            opponentPlayerID = opponent.gamePlayerID
            opponentUsername = opponent.displayName
        }
        rematchRequests = [myPlayerID: false, opponentPlayerID: false]
        forfeitRequests  = [myPlayerID: false, opponentPlayerID: false]
        playersLeft = [myPlayerID: false, opponentPlayerID: false]
        playersQuit = [myPlayerID: false, opponentPlayerID: false]
    }
    
    func sendGuess(_ guess: String) {
        print("Sending Guess")
        let cleanedGuess = guess.trimmingCharacters(in: .whitespacesAndNewlines)
        let newGuess = Guess(targetWord: targetWords[targetWordIndex], guess: cleanedGuess)
        guesses.append(newGuess)
        if wordsGuessedCorrectly == 8 {
            gameState = .gameOver(win: true)
        } else if newGuess.isCorrect {
            targetWordIndex += 1
        }
        sendGameState()
    }
    
    func sendHint(_ hint: String) {
        guard hintsRemaining != 0 else { return }
        print("Sending Hint")
        let cleanedHint = hint.trimmingCharacters(in: .whitespacesAndNewlines)
        let newHint = Hint(targetWord: targetWords[targetWordIndex], hint: cleanedHint)
        hints.append(newHint)
        sendGameState()
    }
    
    func resetGameData() {
        opponentPlayerID = ""
        opponentUsername = ""
        gkMatch = nil
        gameState = .settingUp
        targetWords = []
        targetWordIndex = 0
        hints = []
        guesses = []
        mastermindPlayerID = ""
        rematchRequests = [:]
        forfeitRequests  = [:]
        playersLeft = [:]
        playersQuit = [:]
    }
    
    func quitGame() {
        playersQuit[myPlayerID] = true
        playersLeft[myPlayerID] = true
        sendGameState()
        resetGameData()
        playingGame = false
    }
    
    func toggleRematchRequest() {
        if opponentRequestedRematch {
            setUpGame(newOpponent: false)
            setUpAndSendSharedGameData()
        } else {
            rematchRequests[myPlayerID] = !playerRequestedRematch
            sendGameState()
        }
    }
    
    func toggleForfeitRequest() {
        if opponentRequestedForfeit {
            forfeitRequests[myPlayerID] = true
            gameState = .gameOver(win: false)
        } else {
            forfeitRequests[myPlayerID] = !playerRequestedForfeit
        }
        sendGameState()
    }
}
