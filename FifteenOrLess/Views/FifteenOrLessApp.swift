import SwiftUI

@main
struct FifteenOrLessApp: App {
    @State private var viewModel: ViewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            if viewModel.playingGame {
                GameScreen()
            } else {
                HomeScreen()
            }
        }
        .environment(viewModel)
    }
}
