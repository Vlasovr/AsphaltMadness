import Foundation
import QuartzCore

enum Constants {
    enum Offsets {
        static let little = 5.0
        static let small = 8.0
        static let medium = 16.0
        static let big = 32.0
        static let large = 64.0
        static let hyper = 128.0
    }
    
    static let launchScreenImage = "LaunchScreenImage"
    static let buttonsScaleFactor = 0.5
    static let radiusOfRoundCorner = 10.0
    static let shadowOpasity: Float = 0.7
    static let dataFormat = "dd/MM/yy HH:mm"
    static let minimumAlphaValue = 0.1
    static let maxAlphaValue = 1.0
    static let compressionQuality = 1.0
    
    enum WobbleSettings {
        static let firstValue = 0.015
        static let secondValue = 0.02
        static let thirdValue = 0.0
        static let duration = 0.2
        static let animationsFrame =  "transform.rotation.z"
        static let key = "wobble"
    }
    
    enum ButtonNames {
        static let leftCircleButton = "chevron.backward.circle.fill"
        static let rightCircleButton =  "chevron.right.circle.fill"
        static let leftSquareButton = "chevron.backward.square.fill"
        static let rightSquareButton =  "chevron.right.square.fill"
    }
    
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
        static let bandsCount = 4.0
        static let spacingFactor = 0.5
        static let shadesWidth = 5.0
        static let numberOfStripes = 10.0
        static let timeCoefficient = 1.0
        static let buttonContainerViewWidth = Constants.Game.buttonWidth * 3
        static let defaultPoints = 0.0
        static let gameName = "AsphaltMadness"
        static let gameNameLabelWidth = 380
        static let gameNameLabelHeight = 100
        static let gameNameLabelRotationAngle = -0.6
        static let radius = 10.0
        static let leftEdge = 20.0
        static let text = "Some error found"
        static let spacingForCurbs = 40.0
        static let buttonHeight = 50.0
        static let buttonWidth = 70.0
        static let playButtonWidth = buttonWidth * 2
        static let settingsButtonWidth = buttonWidth * 1.75
        static let recordsButtonWidth = buttonWidth * 1.5
        static let stripesSpacing = 4.0
        static let oneAndHalf = 1.5
        static let pointLabelHeight = 40.0
        static let pointLabelWidht = 300.0
        static let curbsObjectsSide = 60.0
        static let avatarSide = 100.0
        static let menuHeight = 300.0
        static let menuWidth = 200
        static let maxAnimationDuration = 5.5
        static let increasingTimerCoef = 1.1
        static let snapDamping = 1.1
        static let containerViewAlpha = 0.5
        
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
        static let halfCarWidth = Constants.CarMetrics.carWidth / 2
        static let settingsDangerObjectWidth = carWidth * 2
        static let settingsDangerObjectHeight = carHeight * 1.8
    }
    
    enum Settings {
        static let textFieldHeight = 50.0
        static let textFieldWidth = 150.0
        static let collectionViewHeight = 200.0
        static let fadeDurationOfAnimation = 3.0
        static let launchSreenDurationOfAnimation = 2.2
        static let defaultSpeedAnimation = 0.3
        static let layerSpeed: Float = 1.0
        static let slideInSpeedAnimation = 0.15
        static let cellIdentifier = "cell"
        static let levelSegmentControlItems = ["easy", "medium", "hard", "Legend", "GOAT"]
        static let designSegmentControlItems = ["2D", "Minimalistic"]
        static let defaultSettings = UserSettings(avatarImageName: "person.crop.circle.fill",
                                                  userName: "Avatar",
                                                  carColorName: "blue",
                                                  dangerCarImageName: "redDangerObject",
                                                  gameDesign: true,
                                                  gameLevel: 2.0)
        enum ConstantsInAlert {
            static let messageTitle = "ChoosePhoto"
            static let firstButtonTitle = "Library"
            static let secondButtonTitle = "Camera"
        }
    }
    
    enum RecordsScreen {
        static let recordsTitle = "Records"
        static let points = "Очки: "
        static let pointsFormat = "%.3f"
    }
    
    enum FontSizes {
        static let small = 10.0
        static let medium = 20.0
        static let large = 30.0
        static let hyper = 40.0
    }
    
    enum Font {
        static let juraBold = "Jura-Bold"
        static let blazed = "Blazed"
    }
    
    enum UserDefaultsKeys {
        static let userSettingsKey = "userSettingsKey"
        static let recordsKey = "RecordsKey"
    }
}
