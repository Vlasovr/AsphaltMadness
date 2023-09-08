import UIKit

final class UserSettings: Codable {
    var avatarImage: String
    var userName: String
    var heroCarColorName: String
    var dangerCarImageName: String
    var gameDesign: Bool
    var gameLevel: Double
    
    init(avatarImage: String, userName: String, heroCarColor: String, dangerCarImage: String, gameDesign: Bool, gameLevel: Double) {
        self.avatarImage = avatarImage
        self.userName = userName
        self.heroCarColorName = heroCarColor
        self.dangerCarImageName = dangerCarImage
        self.gameDesign = gameDesign
        self.gameLevel = gameLevel
    }
    
}
