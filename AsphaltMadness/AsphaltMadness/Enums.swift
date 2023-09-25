import Foundation

enum Constants {
    enum Offsets {
        static let small = 8.0
        static let medium = 16.0
        static let big = 32.0
        static let large = 64.0
        static let hyper = 128.0
    }
    
    static let dataFormat = "dd/MM/yyyy HH:mm"

    enum EndGameAlert {
        static let alertTitle = "Конец игры!"
        static let messageTitle = "Не отчаивайся, ты сможешь лучше"
        static let firstButtonTitle = "OK"
        static let secondButtonTitle = "Выйти"
    }
    
    enum Speed {
        static let checkCarIsBumpedInterval = 0.1
        static let defaultTimeInterval = 1.0
        static let easy = 5.5
        static let medium = 4.5
        static let hard = 3.5
        static let legend = 2.0
        static let goat = 1.5
    }
    
    enum Game {
        static let gameName = "AsphaltMadness"
        static let gameNameLabelWidth = 380
        static let gameNameLabelHeight = 100
        static let gameNameLabelRotationAngle = -0.7
        static let radius = 10.0
        static let leftEdge = 20.0
        static let text = "Some error found"
        static let spacingForCurbs = 40.0
        static let buttonHeight = 50.0
        static let buttonWidth = 70.0
        static let playButtonWidth = buttonWidth * 2
        static let settingsButtonWidth = buttonWidth * 1.75
        static let recordsButtonWidth = buttonWidth * 1.5
        static let pointLabelHeight = 40.0
        static let pointLabelWidht = 300.0
        static let curbsObjectsSide = 60.0
        static let avatarSide = 100.0
        static let menuHeight = 250.0
        static let menuWidth = 200
        static let maxAnimationDuration = 5.5
        static let increasingTimerCoef = 1.1
        static let snapDamping = 1.1
        enum MenuStrings {
            static let menu = "Menu"
            static let play = "Play"
            static let settings = "Settings"
            static let records = "Records"
        }
    }
    
    enum CarMetrics {
        static let carWidth = 50.0
        static let carHeight = 100.0
        static let settingsDangerObjectWidth = carWidth * 2
        static let settingsDangerObjectHeight = carHeight * 1.8
    }
    
    enum Settings {
        static let textFieldHeight = 50.0
        static let textFieldWidth = 150.0
        static let collectionViewHeight = 200.0
        static let defaultSpeedAnimation = 0.3
        static let slideInSpeedAnimation = 0.15
        
        enum Default {
            static let avatar = "person.crop.circle.fill"
            static let userName = "Avatar"
            static let carColorName = "blue"
            static let dangerCarImageName = "redDangerObject"
            static let gameDesign = true
            static let gameLevel = 2.0
        }
    }
    
    
    enum FontSizes {
        static let small = 10.0
        static let medium = 20.0
        static let large = 30.0
        static let hyper = 40.0
    }
    
    enum UserDefaultsKeys {
        static let appEntries = "AppEntries"
        static let userSettingsKey = "userSettingsKey"
        static let recordsKey = "RecordsKey"
    }
}
