import Foundation

final class Records: Codable {
    var userName: String
    var avatarImageName: String
    var gameResult: Double
    var date: String
    
    
    init(userName: String, avatarImageName: String, gameResult: Double, date: String) {
        self.userName = userName
        self.avatarImageName = avatarImageName
        self.gameResult = gameResult
        self.date = date
    }
}
