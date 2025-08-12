import SwiftUI

struct HomeScreen: View {
    @Environment(ViewModel.self) private var viewModel
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("15 Words or Less")
                        .font(.largeTitle)
                        .bold()
                    Text(viewModel.playerAuthState.rawValue)
                        .foregroundStyle(.secondary)
                        .font(.caption2)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                Button {
                    viewModel.showGameCenterDashboard()
                } label: {
                    viewModel.myAvater
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(.circle)
                }
            }
            
            Spacer()
            
            if #available(iOS 26.0, *) {
                playButton
                    .buttonStyle(.glassProminent)
            } else {
                playButton
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var playButton: some View {
        Button {
            viewModel.startMatchmaking()
        } label: {
            Label("Play Game", systemImage: "gamecontroller.fill")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .disabled(viewModel.playerAuthState != .authenticated)
    }
}

#Preview {
    HomeScreen()
        .environment(ViewModel())
}
