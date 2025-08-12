import Foundation
import GameKit

extension ViewModel: GKLocalPlayerListener {
    func player(_ player: GKPlayer, didAccept invite: GKInvite) {
        guard let matchmakingVC = GKMatchmakerViewController(invite: invite) else { return }
        matchmakingVC.matchmakerDelegate = self
        
        rootViewController?.present(matchmakingVC, animated: true)
    }
}
