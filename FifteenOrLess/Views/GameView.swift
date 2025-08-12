import SwiftUI

struct GameView: View {
    @Environment(ViewModel.self) private var viewModel
    @State private var input: String = ""
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                if viewModel.gameState == .gameOver(win: true) {
                    VStack(spacing: 8) {
                        Text("🎉 You both won!")
                            .font(.largeTitle)
                            .bold()
                        Text("All 8 words were solved.")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                } else if viewModel.gameState == .gameOver(win: false) {
                    VStack(spacing: 8) {
                        if viewModel.opponentLeft || viewModel.opponentQuit {
                            Text("Game ended")
                                .font(.largeTitle)
                                .bold()
                            Text(viewModel.opponentQuit ? "Opponent quit the match." : "Opponent disconnected.")
                                .foregroundStyle(.secondary)
                        } else if (viewModel.forfeitRequests[viewModel.myPlayerID] ?? false) && viewModel.opponentRequestedForfeit {
                            Text("Match forfeited by both players.")
                                .font(.title2)
                                .bold()
                        } else {
                            Text("Game over.")
                                .font(.title2)
                                .bold()
                        }
                    }
                    .padding(.vertical, 8)
                }
                HStack {
                    VStack(spacing: 10) {
                        Text("Hints")
                            .font(.title2)
                            .bold()
                        ScrollView(.vertical) {
                            if viewModel.hints.isEmpty {
                                Text("No hints yet.")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                            }
                            ForEach(viewModel.hints) { hint in
                                Text(hint.hint)
                                    .foregroundColor(
                                        hint.targetWord == viewModel.currentTargetWord ? .primary : .gray
                                    )
                                    .fontWeight(.semibold)
                            }
                        }
                        .scrollIndicators(.hidden)
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: geo.size.height / 3)
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
                    
                    VStack(spacing: 10) {
                        Text("Target Words")
                            .font(.title2)
                            .bold()
                        ScrollView(.vertical) {
                            ForEach(Array(viewModel.targetWords.enumerated()), id: \.offset) { index, word in
                                Group {
                                    if viewModel.playerIsMastermind || viewModel.gameState != .ongoing {
                                        Text(word)
                                            .foregroundColor(
                                                index == viewModel.targetWordIndex ? .blue : .gray
                                            )
                                    } else {
                                        if index < viewModel.targetWordIndex {
                                            Text(word)
                                        } else if index == viewModel.targetWordIndex {
                                            Text(String(repeating: "_ ", count: word.count).trimmingCharacters(in: .whitespaces))
                                        } else {
                                            Text("???")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .fontWeight(.semibold)
                                .padding(.bottom, 4)
                            }
                        }
                        .scrollIndicators(.hidden)
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: geo.size.height / 3)
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
                }
                ScrollView(.vertical) {
                    ForEach(viewModel.guesses) { guess in
                        HStack(alignment: .bottom, spacing: 0) {
                            Group {
                                if viewModel.playerIsMastermind {
                                    Text(viewModel.opponentUsername)
                                } else {
                                    Text("You")
                                }
                                Text(" guessed: ")
                            }
                            Text(guess.guess)
                        }
                        .fontWeight(.semibold)
                        .font(.title2)
                        .bold()
                        .foregroundStyle(guess.targetWord == guess.guess ? .green : .red)
                    }
                }
                .scrollIndicators(.hidden)
                .safeAreaPadding(.vertical)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .defaultScrollAnchor(.bottom)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
                .overlay {
                    if viewModel.guesses.isEmpty {
                        ContentUnavailableView("No Guesses Yet", systemImage: "pencil.and.scribble", description: Text(viewModel.playerIsMastermind ? "Wait for your opponent to make a guess." : "Enter your first guess below."))
                    }
                }
                if viewModel.gameState != .ongoing {
                    VStack(spacing: 10) {
                        if #available(iOS 26.0, *) {
                            rematchButtonView
                                .buttonStyle(.glassProminent)
                            goHomeButtonView
                                .buttonStyle(.glass)
                        } else {
                            rematchButtonView
                                .buttonBorderShape(.capsule)
                                .buttonStyle(.borderedProminent)
                            goHomeButtonView
                                .buttonBorderShape(.capsule)
                                .buttonStyle(.bordered)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .toolbar {
                if viewModel.gameState != .ongoing {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu("Game Settings", systemImage: "ellipsis") {
                            Button("Quit Game", systemImage: "door.right.hand.open") {
                                viewModel.quitGame()
                            }
                            Button("Forfeit Game", systemImage: "flag.slash") {
                                viewModel.toggleForfeitRequest()
                            }
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if viewModel.gameState == .ongoing {
                    if #available(iOS 26.0, *) {
                        textFieldButtonView
                            .glassEffect()
                            .padding(.horizontal)
                    } else {
                        textFieldButtonView
                            .background(.ultraThinMaterial, in: .capsule)
                            .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    var textFieldButtonView: some View {
        HStack {
            TextField(viewModel.playerIsMastermind ? "Hint for \(viewModel.opponentUsername)" : "Enter your guess", text: $input)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
            
            Spacer()
            
            Button("Send \(viewModel.playerIsMastermind ? "Hint" : "Guess")", systemImage: "arrow.up.circle.fill") {
                viewModel.playerIsMastermind ? viewModel.sendHint(input) : viewModel.sendGuess(input)
                input = ""
                hideKeyboard()
            }
            .labelStyle(.iconOnly)
            .font(.largeTitle)
            .disabled(input.isEmpty)
        }
        .disabled(viewModel.playerIsMastermind ? viewModel.hintsRemaining == 0 : false)
        .padding()
    }
    
    var rematchButtonView: some View {
        Button {
            viewModel.toggleRematchRequest()
        } label: {
            Group {
                if viewModel.opponentLeft || viewModel.opponentQuit {
                    Text("Opponent Left The Lobby")
                } else if viewModel.playerRequestedRematch {
                    Text("Waiting On Opponent (Undo)")
                } else if viewModel.opponentRequestedRematch {
                    Text("Opponent Requested Rematch. Rematch?")
                } else {
                    Text("Request Rematch")
                }
            }
            .font(.title2)
            .bold()
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .disabled(viewModel.opponentLeft || viewModel.opponentQuit)
    }
    
    var goHomeButtonView: some View {
        Button {
            viewModel.quitGame()
        } label: {
            Text("Go Home")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
    }
}

#Preview {
    NavigationView {
        GameView()
            .environment(ViewModel())
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
