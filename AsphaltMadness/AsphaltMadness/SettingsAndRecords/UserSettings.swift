import UIKit

final class UserSettings: Codable {
    var avatarImageName: String
    var userName: String
    var carColorName: String
    var dangerCarImageName: String
    var gameDesign: Bool
    var gameLevel: Double
    
    init(avatarImageName: String, userName: String, carColorName: String, dangerCarImageName: String, gameDesign: Bool, gameLevel: Double) {
        self.avatarImageName = avatarImageName
        self.userName = userName
        self.carColorName = carColorName
        self.dangerCarImageName = dangerCarImageName
        self.gameDesign = gameDesign
        self.gameLevel = gameLevel
    }
    
}
