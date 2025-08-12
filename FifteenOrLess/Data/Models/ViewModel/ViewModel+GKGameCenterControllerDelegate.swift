import Foundation
import GameKit

extension ViewModel: GKGameCenterControllerDelegate {
    func showGameCenterDashboard() {
        let gameCenterViewVC = GKGameCenterViewController(state: .dashboard)
        gameCenterViewVC.gameCenterDelegate = self
        rootViewController?.present(gameCenterViewVC, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
