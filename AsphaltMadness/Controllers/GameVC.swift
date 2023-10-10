import UIKit

final class GameVC: UIViewController {
    
    //MARK: - Initialize two backgrounds to manage them in infinite road animation
    private lazy var mainRoadView = BackgroundView()
    
    private lazy var upperRoadView = BackgroundView()
    
    private lazy var carView = UIView()
    
    //MARK: - Array of views pointers
    private var listOfСars = [UIView]()
    private var timersList = [Timer]()
    
    private lazy var leftButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: Constants.ButtonNames.leftSquareButton), for: .normal)
        button.addTarget(self, action: #selector(turnDidTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var rightButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: Constants.ButtonNames.rightSquareButton), for: .normal)
        button.addTarget(self, action: #selector(turnDidTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonsContainerView = UIView()
    
    //MARK: - Game points
    private lazy var points = Constants.Game.defaultPoints {
        didSet {
            let formattedPoints = String(format: Constants.RecordsScreen.pointsFormat, points)
            pointsLabel.text = Constants.RecordsScreen.points + formattedPoints
        }
    }
    
    private lazy var pointsLabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: Constants.Font.juraBold, size: Constants.FontSizes.medium)
        return label
    }()
    
    //MARK: - Count user actions for correct first movement of the hero car
    private lazy var countUserCarActions = 0 {
        didSet {
            print(countUserCarActions)
        }
    }
    
    //MARK: - Initialise real car object behaviour
    private lazy var dynamicAnimator = UIDynamicAnimator()
    private var snap: UISnapBehavior?
    
    // MARK: - VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        addSubviews()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupBackground()
        setupCarView(car: carView)
        setupGameSettings()
    }
    
    // MARK: - Touch events control
    @objc func turnDidTapped(_ sender: UIButton) {
        countUserCarActions += 1
        
        if let snap = snap {
            dynamicAnimator.removeBehavior(snap)
        }
        
        let direction = sender == leftButton ? -1.0 : 1.0
        
        let xOffset = direction * (countUserCarActions < 2 ?
                                   carView.frame.width / 1.5 :
                                    mainRoadView.getSingleLineWidth())
        
        snap = UISnapBehavior(item: carView,
                              snapTo: CGPoint(x: carView.center.x + xOffset,
                                              y: carView.center.y))
        snap?.damping = Constants.Game.snapDamping
        
        if let snap = snap {
            dynamicAnimator.addBehavior(snap)
        }
    }
    //MARK: - Load game settings
    private func setupGameSettings() {
        if let userSettings = UserDefaults.standard.object(UserSettings.self, forKey: Constants.UserDefaultsKeys.userSettingsKey) {
            let colorName = userSettings.carColorName
            let gameLevel = userSettings.gameLevel
            carView.backgroundColor = listOfColors[colorName]
            
            self.animateRoad(backView: mainRoadView,
                             upperView: upperRoadView,
                             duration: gameLevel)
            setupTimers(with: userSettings)
        }
    }
    
    //MARK: - Setup danger objects with timers, could be remade for better game experience
    private func setupTimers(with userSettings: UserSettings) {
        var timeCoefficient = Constants.Game.timeCoefficient
        let pointsTimer = Timer.scheduledTimer(withTimeInterval: Constants.Speed.defaultTimeInterval,
                                               repeats: true) { _ in
            self.points += (Double.random(in: (.zero...Constants.Speed.defaultTimeInterval) ) * timeCoefficient)
            timeCoefficient *= Constants.Game.increasingTimerCoef
        }
        timersList.append(pointsTimer)
        
        let leftLineDangerTimer = Timer.scheduledTimer(withTimeInterval: Constants.Speed.goat,
                                                       repeats: true) { _ in
            
            self.addDangerCars(x: Constants.Game.spacingForCurbs + Constants.Offsets.small,
                               setupWith: userSettings)
        }
        timersList.append(leftLineDangerTimer)
        
        let leftCenteredDangerTimer = Timer.scheduledTimer(withTimeInterval: Constants.Speed.medium,
                                                           repeats: true) { _ in
            
            self.addDangerCars(x: self.mainRoadView.getSingleLineWidth() * 2 - Constants.CarMetrics.halfCarWidth,
                               setupWith: userSettings)
        }
        timersList.append(leftCenteredDangerTimer)
        
        let rightCenteredLineDangerTimer = Timer.scheduledTimer(withTimeInterval: Constants.Speed.easy,
                                                                repeats: true) { _ in
            self.addDangerCars(x: self.mainRoadView.getSingleLineWidth() * 3 - Constants.CarMetrics.halfCarWidth,
                               setupWith: userSettings)
        }
        timersList.append(rightCenteredLineDangerTimer)
        
        let rightLineDangerTimer = Timer.scheduledTimer(withTimeInterval: Constants.Speed.hard,
                                                        repeats: true) { _ in
            self.addDangerCars(x: self.mainRoadView.getSingleLineWidth() * 4 - Constants.CarMetrics.halfCarWidth,
                               setupWith: userSettings)
        }
        timersList.append(rightLineDangerTimer)
    }
    
    //MARK: - Create danger objects with minimalistic design or image
    private func addDangerCars(x: CGFloat, setupWith userSettings: UserSettings) {
        userSettings.gameDesign ? createDangerImageView(x: x, userSettings: userSettings) : createDangerView(x: x, userSettings: userSettings)
    }
    
    private func createDangerImageView(x: CGFloat, userSettings: UserSettings) {
        let dangerView = UIImageView()
        
        if let image = UIImage(named: userSettings.dangerCarImageName) {
            dangerView.image = image
        } else {
            dangerView.randomiseColor()
        }
        
        dangerView.wobble()
         
        view.addSubview(dangerView)
        
        dangerView.frame = CGRect( x: x,
                                   y: -Constants.CarMetrics.carHeight - view.safeAreaInsets.top,
                                   width: Constants.CarMetrics.carWidth,
                                   height: Constants.CarMetrics.carHeight)
        
        listOfСars.append(dangerView)
        animateDangerObject(object: dangerView, userSettings: userSettings)
    }
    
    private func createDangerView(x: CGFloat, userSettings: UserSettings) {
        let car = UIView()
        
        view.addSubview(car)
        let carFrame = CGRect(x: x,
                              y: -Constants.CarMetrics.carHeight - view.safeAreaInsets.top,
                              width: Constants.CarMetrics.carWidth,
                              height: Constants.CarMetrics.carHeight)
        
        setupCarView(car: car, frame: carFrame)
        listOfСars.append(car)
        animateDangerObject(object: car, userSettings: userSettings)
        
    }
    //MARK: - Checking is car bumped with danger objects during all the game
    private func checkCarIsBumped(object: UIView) {
        let timer = Timer.scheduledTimer(withTimeInterval: Constants.Speed.checkCarIsBumpedInterval,
                                         repeats: true) { _ in
            if let objectFrame = object.layer.presentation()?.frame {
                if self.carView.frame.intersects(objectFrame) || self.isCurbesIntersect(with: self.carView) {
                    object.removeFromSuperview()
                    self.carView.removeFromSuperview()
                    self.manageCrushedCar()
                }
            }
        }
        timersList.append(timer)
    }
    //MARK: - Checking is car intersected one of the curb during all the game
    private func isCurbesIntersect(with object: UIView) -> Bool {
        let curbFrames = mainRoadView.getCurbsFrames()
        return object.frame.intersects(curbFrames.0) || object.frame.intersects(curbFrames.1) ? (true) : (false)
    }
    
    //MARK: - Animations block of danger objects
    private func animateDangerObject(object: UIView, userSettings: UserSettings) {
        let carSpeed = Constants.Game.maxAnimationDuration - userSettings.gameLevel
        UIView.animate(withDuration: carSpeed, delay: .zero, options: .curveLinear) {
            object.frame.origin.y = self.view.frame.height
            self.checkCarIsBumped(object: object)
        } completion: { _ in
            object.removeFromSuperview()
            if let index = self.listOfСars.firstIndex(of: object) {
                self.listOfСars.remove(at: index)
            }
        }
    }
    //MARK: - realisation of stopping the game if car is bumped or intersected
    private func manageCrushedCar() {
        
        stopGame()
        
        let userSettings: UserSettings
        
        if let savedUserSettings = UserDefaults.standard.object(UserSettings.self, forKey: Constants.UserDefaultsKeys.userSettingsKey) {
            userSettings = savedUserSettings
        } else {
            let defaultSettings = Constants.Settings.defaultSettings
            UserDefaults.standard.set(encodable: defaultSettings, forKey: Constants.UserDefaultsKeys.userSettingsKey)
            userSettings = defaultSettings
        }
        
        saveGamePoints(userSettings: userSettings)
        
        let okAction = { [weak self, userSettings] in
            self?.restartGame(with: userSettings)
            return
        }
        
        let cancelAction = { [weak self] in
            self?.fadeCurrentScreen(parrentView: self?.view) {
                self?.navigationController?.popViewController(animated: false)
            }
            return
        }
        
        showAlert(alertTitle: Constants.EndGameAlert.alertTitle,
                  messageTitle: Constants.EndGameAlert.messageTitle,
                  alertStyle: .alert,
                  firstButtonTitle: Constants.EndGameAlert.firstButtonTitle,
                  secondButtonTitle: Constants.EndGameAlert.secondButtonTitle,
                  firstAlertActionStyle: .default,
                  secondAlertActionStyle: .cancel,
                  firstHandler: okAction,
                  secondHandler: cancelAction)
    }
    
    private func stopGame() {
        countUserCarActions = .zero
        pauseLayer(layer: mainRoadView.layer)
        pauseLayer(layer: upperRoadView.layer)
        timersList.forEach { $0.invalidate() }
        timersList.removeAll()
    }
    
    private func restartGame(with userSettings: UserSettings) {
        self.setupTimers(with: userSettings)
        self.points = .zero
        self.view.addSubview(self.carView)
        self.setupCarView(car: self.carView)
        self.resumeLayer(layer: self.mainRoadView.layer)
        self.resumeLayer(layer: self.upperRoadView.layer)
    }
    
    //MARK: - saving game record for the records table
    private func saveGamePoints(userSettings: UserSettings) {
        guard var recordsHistory = UserDefaults.standard.object([Records].self,
                                                                forKey: Constants.UserDefaultsKeys.recordsKey) else {
            return
        }
        
        if let lastRecord = recordsHistory.last,
                lastRecord.gameResult >= points {
            return
        }
        
        let date = getDate()
        let record = Records(userName: userSettings.userName, avatarImageName: userSettings.avatarImageName, gameResult: points, date: date)
        
        recordsHistory.append(record)
        UserDefaults.standard.set(encodable: recordsHistory, forKey: Constants.UserDefaultsKeys.recordsKey)
        
    }
}

// MARK: - Setupping frames and constraintes and UI
extension GameVC {
    
    private func addSubviews() {
        view.addSubview(mainRoadView)
        view.addSubview(upperRoadView)
        view.addSubview(carView)
        view.addSubview(pointsLabel)
        view.addSubview(buttonsContainerView)
        buttonsContainerView.addSubview(leftButton)
        buttonsContainerView.addSubview(rightButton)
    }
    
    private func setupBackground() {
        setupRoadFrames(mainView: mainRoadView, upperView: upperRoadView)
    }
    
    private func setupCarView(car: UIView) {
        car.frame = CGRect(x: view.center.x - Constants.CarMetrics.halfCarWidth,
                           y: view.frame.height - Constants.Offsets.hyper - Constants.CarMetrics.carHeight,
                           width: Constants.CarMetrics.carWidth,
                           height: Constants.CarMetrics.carHeight)
        car.roundCorners()
        car.dropShadow()
        car.wobble()
    }
    
    private func setupCarView(car: UIView, frame: CGRect) {
        car.frame = frame
        car.randomiseColor()
        car.roundCorners()
        car.dropShadow()
        car.wobble()
    }
    
    func setupConstraints() {
        
        buttonsContainerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.snp.bottom).offset(-Constants.Offsets.large)
            make.height.equalTo(Constants.Game.buttonHeight)
            make.width.equalTo(Constants.Game.buttonContainerViewWidth)
        }
        
        leftButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(Constants.Game.buttonWidth)
            make.height.equalTo(Constants.Game.buttonHeight)
        }
        
        rightButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(Constants.Game.buttonWidth)
            make.height.equalTo(Constants.Game.buttonHeight)
        }
        
        pointsLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.Offsets.big)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(Constants.Game.pointLabelWidht)
            make.height.equalTo(Constants.Game.pointLabelHeight)
        }
    }
}

