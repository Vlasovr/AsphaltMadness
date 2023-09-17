import Foundation

final class Records: Codable {
    var userName: String
    var gameResult: Double
    var date: String
    init(userName: String, gameResult: Double, date: String) {
        self.userName = userName
        self.gameResult = gameResult
        self.date = date
    }
}
