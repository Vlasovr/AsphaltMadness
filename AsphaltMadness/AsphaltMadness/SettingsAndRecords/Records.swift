import Foundation

final class Records: Codable {
    var userName: String
    var gameResult: Double
    
    init(userName: String, gameResult: Double) {
        self.userName = userName
        self.gameResult = gameResult
    }
}
