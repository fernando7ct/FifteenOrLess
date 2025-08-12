import Foundation
import GameKit

extension ViewModel: GKMatchmakerViewControllerDelegate {
    func startMatchmaking() {
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        request.defaultNumberOfPlayers = 2
        
        guard let matchmakingVC = GKMatchmakerViewController(matchRequest: request) else { return }
        matchmakingVC.matchmakerDelegate = self
        print("Requesting matchmaking")
        rootViewController?.present(matchmakingVC, animated: true)
    }
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        print("Match found")
        viewController.dismiss(animated: true)
        gkMatch = match
        gkMatch?.delegate = self
        setUpGame(newOpponent: true)
        
        if myPlayerID < opponentPlayerID {
            setUpAndSendSharedGameData()
        }
    }
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: any Error) {
        print(error.localizedDescription)
        viewController.dismiss(animated: true)
    }
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(animated: true)
    }
}
