import Foundation
import GameKit

extension ViewModel: GKMatchDelegate {
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        guard let gameData = try? JSONDecoder().decode(GameState.self, from: data) else { return }
        print("Game data received: \(gameData)")
        gameState = gameData.gameState
        mastermindPlayerID = gameData.mastermindPlayerID
        targetWords = gameData.targetWords
        targetWordIndex = gameData.targetWordIndex
        hints = gameData.hints
        guesses = gameData.guesses
        rematchRequests = gameData.rematchRequests
        forfeitRequests = gameData.forfeitRequests
        playersLeft = gameData.playersLeft
        playersQuit = gameData.playersQuit
    }
    func sendGameState() {
        let gameState = GameState(viewModel: self)
        guard let data = try? JSONEncoder().encode(gameState) else {
            print("Error encoding data")
            return
        }
        print("Sending Data: \(gameState)")
        sendData(data)
    }
    func sendData(_ data: Data, mode: GKMatch.SendDataMode = .reliable) {
        guard let gkMatch else { return }
        do {
            try gkMatch.sendData(toAllPlayers: data, with: mode)
        } catch {
            print(error.localizedDescription)
        }
    }
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        switch state {
        case .connected:
            break
        default:
            print("Player disconnected: \(player.displayName)")
            playersLeft[player.gamePlayerID] = true
            gameState = .gameOver(win: false)
        }
    }
}
