import Foundation

enum PlayerAuthState: String {
    case authenticating = "Logging in to Game Center..."
    case unauthenticated = "You are not logged in to Game Center."
    case authenticated = ""
    
    case error = "An error occurred while authenticating."
    case restricted = "Multiplayer is not supported on this device."
}
