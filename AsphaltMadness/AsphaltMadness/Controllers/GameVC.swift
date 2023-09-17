import UIKit

final class GameVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Initialize two backgrounds to manage them in infinite road animation
    private lazy var mainRoadView = BackgroundView()
    
    private lazy var upperRoadView = BackgroundView()
    
    private lazy var carView = UIView()
    
    //MARK: - Array of views pointers
    private var listOfСars = [UIView]()
    private var timersList = [Timer]()
    
    private lazy var leftButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "arrowshape.backward.fill"), for: .normal)
        button.addTarget(self, action: #selector(turnDidTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var rightButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "arrowshape.right.fill"), for: .normal)
        button.addTarget(self, action: #selector(turnDidTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonsContainerView = UIView()
    
    //MARK: - Game points
    private lazy var points = 0.0 {
        didSet {
            let formattedPoints = String(format: "%.3f", points)
            pointsLabel.text = "Points: " + formattedPoints
        }
    }
    
    private lazy var pointsLabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Jura-Bold", size: Constants.FontSizes.medium)
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
        snap?.damping = 1.1
        
        if let snap = snap {
            dynamicAnimator.addBehavior(snap)
        } else {
            print("error")
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
        var timeCoefficient = 1.0
        let pointsTimer = Timer.scheduledTimer(withTimeInterval: Constants.Speed.defaultTimeInterval,
                                               repeats: true) { _ in
            self.points += (Double.random(in: (.zero...Constants.Speed.defaultTimeInterval) ) * timeCoefficient)
            timeCoefficient *= 1.1
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
            
            self.addDangerCars(x: self.mainRoadView.getSingleLineWidth() * 2 - Constants.CarMetrics.carWidth / 2,
                               setupWith: userSettings)
        }
        timersList.append(leftCenteredDangerTimer)
        
        let rightCenteredLineDangerTimer = Timer.scheduledTimer(withTimeInterval: Constants.Speed.easy,
                                                                repeats: true) { _ in
            self.addDangerCars(x: self.mainRoadView.getSingleLineWidth() * 3 - Constants.CarMetrics.carWidth / 2,
                               setupWith: userSettings)
        }
        timersList.append(rightCenteredLineDangerTimer)
        
        let rightLineDangerTimer = Timer.scheduledTimer(withTimeInterval: Constants.Speed.hard,
                                                        repeats: true) { _ in
            self.addDangerCars(x: self.mainRoadView.getSingleLineWidth() * 4 - Constants.CarMetrics.carWidth / 2,
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
        dangerView.backgroundColor = .clear
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
                                         repeats: true) { [self] _ in
            if let objectFrame = object.layer.presentation()?.frame {
                if carView.frame.intersects(objectFrame) || isCurbesIntersect(with: carView) {
                    object.removeFromSuperview()
                    carView.removeFromSuperview()
                    stopGame()
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
    private func stopGame() {
        countUserCarActions = 0
        pauseLayer(layer: mainRoadView.layer)
        pauseLayer(layer: upperRoadView.layer)
        timersList.forEach { $0.invalidate() }
        timersList.removeAll()
        
        let userSettings: UserSettings
        
        if let savedUserSettings = UserDefaults.standard.object(UserSettings.self, forKey: Constants.UserDefaultsKeys.userSettingsKey) {
            userSettings = savedUserSettings
        } else {
            let defaultSettings = UserSettings(avatarImageName: "person.crop.circle.fill", userName: "Avatar", carColorName: "blue", dangerCarImageName: "redDangerObject", gameDesign: true, gameLevel: 2.0)
            UserDefaults.standard.set(encodable: defaultSettings, forKey: Constants.UserDefaultsKeys.userSettingsKey)
            userSettings = defaultSettings
        }
        
        saveGamePoints(userSettings: userSettings)
        
        let okAction = { [userSettings] in
            self.setupTimers(with: userSettings)

            self.points = 0
            self.view.addSubview(self.carView)
            self.setupCarView(car: self.carView)
            self.resumeLayer(layer: self.mainRoadView.layer)
            self.resumeLayer(layer: self.upperRoadView.layer)
        }
        
        let cancelAction = {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        showAlert(alertTitle: "Конец игры!", messageTitle: "Не отчаивайся, ты сможешь лучше", alertStyle: .alert, firstButtonTitle: "Ok", secondButtonTitle: "Выйти", firstAlertActionStyle: .default, secondAlertActionStyle: .cancel, firstHandler: okAction, secondHandler: cancelAction)
    }
    //MARK: - saving game record for the records table
    private func saveGamePoints(userSettings: UserSettings) {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let date = dateFormatter.string(from: currentDate)
        
        let records = Records(userName: userSettings.userName, gameResult: points, date: date)
        UserDefaults.standard.set(encodable: records, forKey: Constants.UserDefaultsKeys.recordsKey)
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
        car.frame = CGRect(x: view.center.x - Constants.CarMetrics.carWidth / 2,
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
            make.width.equalTo(Constants.Game.buttonWidth * 3)
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

