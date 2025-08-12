import SwiftUI

struct GameScreen: View {
    @Environment(ViewModel.self) private var viewModel
    
    var body: some View {
        NavigationView {
            if viewModel.gameState == .settingUp {
                ProgressView("Setting Up Game...")
            } else {
                GameView()
            }
        }
    }
}

#Preview {
    GameScreen()
        .environment(ViewModel())
}
