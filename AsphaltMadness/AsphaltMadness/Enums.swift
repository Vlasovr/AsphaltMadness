import Foundation

enum Constants {
    enum Offsets {
        static let small = 8.0
        static let medium = 16.0
        static let big = 32.0
        static let large = 64.0
        static let hyper = 128.0
    }
    
    enum Game {
        static let radius = 10.0
        static let leftEdge = 20.0
        static let text = "Some error found"
        static let spacingForCurbs = 40.0
        static let buttonHeight = 50.0
        static let buttonWidth = 70.0
        static let pointLabelHeight = 40.0
        static let pointLabelWidht = 300.0
        static let roadAnimationSpeed = 2.0
        static let curbsObjectsSide = 60.0
    }
    
    enum CarMetrics {
        static let carWidth = 50.0
        static let carHeight = 100.0
    }
    
    enum Settings {
        static let textFieldHeight = 50.0
        static let textFieldWidth = 150.0
        static let collectionViewHeight = 200.0
    }
    
    
    enum FontSizes {
        static let smallFont = 10.0
        static let mediumFont = 20.0
        static let largeFont = 40.0
    }
    
    enum UserDefaultsKeys {
        static let gamerName = "GamerName"
        static let carColorIndex = "CarColor"
        static let gameLevel = "GameLevel"
        static let dangerObjectIndex = "DangerObjectIndex"
        static let dangerObjectMinimalisticDesign = "DangerObjectMinimalisticDesign"
    }
}
