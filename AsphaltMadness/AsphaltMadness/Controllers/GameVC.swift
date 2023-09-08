import UIKit

class GameVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Initialize two backgrounds to manage them in animations block
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
    
    //MARK: - Make! goodLooking points
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

    //MARK: - Some counter that I would use
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
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.layerremoveAllAnimations()
        self.view.subviews.forEach{ $0.removeFromSuperview() }
        print("removed")
    }
    
    private func setupGameSettings() {
        if let userSettings = UserDefaults.standard.object(UserSettings.self, forKey: Constants.UserDefaultsKeys.userSettingsKey) {
            let colorName = userSettings.heroCarColorName
            let gameLevel = userSettings.gameLevel
            carView.backgroundColor = listOfColors[colorName]
            
            self.animateRoad(backView: mainRoadView,
                            upperView: upperRoadView,
                            duration: gameLevel)
            setupTimers(dangerObjectsSpeed: gameLevel, isMinimalistic: userSettings.gameDesign, dangerCarImageName: userSettings.dangerCarImageName)
        }
    }
    // MARK: - Touch events control
    @objc func turnDidTapped(_ sender: UIButton) {
        countUserCarActions += 1
        
        if let snap = snap {
            dynamicAnimator.removeBehavior(snap)
        }
        
        let direction = sender == leftButton ? -1.0 : 1.0
        let xOffset = direction * (countUserCarActions < 2 ? carView.frame.width / 1.5 : mainRoadView.getSingleLineWidth())
        
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
    
    private func setupTimers(dangerObjectsSpeed: Double, isMinimalistic: Bool, dangerCarImageName: String) {
        var timeCoefficient = 1.0
        let pointsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.points += (Double.random(in: (0.0...3.0) ) * timeCoefficient)
            timeCoefficient *= 1.1
        }
        timersList.append(pointsTimer)
        
        let leftLineDangerTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            
            self.addDangerCars(x: Constants.Game.spacingForCurbs + Constants.Offsets.small,
                               isMinimalistic: isMinimalistic,
                               dangerObjectsSpeed: dangerObjectsSpeed,
                               dangerCarImageName: dangerCarImageName)
        }
        timersList.append(leftLineDangerTimer)
        
        let leftCenteredDangerTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            
            self.addDangerCars(x: self.mainRoadView.getSingleLineWidth() * 2 - Constants.CarMetrics.carWidth / 2,
                               isMinimalistic: isMinimalistic,
                               dangerObjectsSpeed: dangerObjectsSpeed,
                               dangerCarImageName: dangerCarImageName)
        }
        timersList.append(leftCenteredDangerTimer)
        
        let rightCenteredLineDangerTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            self.addDangerCars(x: self.mainRoadView.getSingleLineWidth() * 3 - Constants.CarMetrics.carWidth / 2,
                               isMinimalistic: isMinimalistic,
                               dangerObjectsSpeed: dangerObjectsSpeed,
                               dangerCarImageName: dangerCarImageName)
        }
        timersList.append(rightCenteredLineDangerTimer)
        let rightLineDangerTimer = Timer.scheduledTimer(withTimeInterval: 5.5, repeats: true) { _ in
            self.addDangerCars(x: self.mainRoadView.getSingleLineWidth() * 4 - Constants.CarMetrics.carWidth / 2,
                               isMinimalistic: isMinimalistic,
                               dangerObjectsSpeed: dangerObjectsSpeed,
                               dangerCarImageName: dangerCarImageName)
        }
        timersList.append(rightLineDangerTimer)
    }
    
    
    //MARK: - Realisation of danger objects with timer
    private func addDangerCars(x: CGFloat, isMinimalistic: Bool, dangerObjectsSpeed: Double, dangerCarImageName: String) {
        isMinimalistic ? createDangerImageView(x: x, dangerCarImageName: dangerCarImageName, dangerObjectsSpeed: dangerObjectsSpeed) : createDangerView(x: x, dangerObjectsSpeed: dangerObjectsSpeed)
    }
    
    private func createDangerImageView(x: CGFloat, dangerCarImageName: String, dangerObjectsSpeed: Double) {
        let dangerView = UIImageView()
        if let image = UIImage(named: dangerCarImageName) {
            dangerView.image = image
        } else {
            dangerView.randomiseColor()
        }
        
        dangerView.wobble()
        dangerView.backgroundColor = .clear
        view.addSubview(dangerView)
        setPosition(to: dangerView, x: x,
                    y: -Constants.CarMetrics.carHeight - view.safeAreaInsets.top,
                    width: Constants.CarMetrics.carWidth,
                    height: Constants.CarMetrics.carHeight)
        
        listOfСars.append(dangerView)
        animateDangerObject(object: dangerView, dangerObjectsSpeed: dangerObjectsSpeed)
    }
    
    private func createDangerView(x: CGFloat, dangerObjectsSpeed: Double) {
        let car = UIView()
        
        view.addSubview(car)
        setPosition(to: car, x: x,
                    y: -Constants.CarMetrics.carHeight - view.safeAreaInsets.top,
                    width: Constants.CarMetrics.carWidth,
                    height: Constants.CarMetrics.carHeight)
        car.randomiseColor()
        car.roundCorners()
        car.dropShadow()
        listOfСars.append(car)
        animateDangerObject(object: car, dangerObjectsSpeed: dangerObjectsSpeed)
        
    }
    private func setPosition(to object: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        object.frame = CGRect(x: x, y: y, width: width, height: height)
    }
    
    private func checkCarIsBumped(object: UIView) {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [self] _ in
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
    
    private func isCurbesIntersect(with object: UIView) -> Bool {
        let curbFrames = mainRoadView.getCurbsFrames()
        return object.frame.intersects(curbFrames.0) || object.frame.intersects(curbFrames.1) ? (true) : (false)
    }
    
    private func countGamePoints () {
        
    }
    
    //MARK: - Animations Block
    
    private func animateDangerObject(object: UIView, dangerObjectsSpeed: Double) {
        UIView.animate(withDuration: dangerObjectsSpeed, delay: .zero, options: .curveLinear) {
            object.frame.origin.y = self.view.frame.height
            self.checkCarIsBumped(object: object)
        } completion: { _ in
            object.removeFromSuperview()
            if let index = self.listOfСars.firstIndex(of: object) {
                self.listOfСars.remove(at: index)
            }
        }
    }
    
    private func stopGame() {
        countUserCarActions = 0
        pauseLayer(layer: mainRoadView.layer)
        pauseLayer(layer: upperRoadView.layer)
        timersList.forEach { $0.invalidate() }
        timersList.removeAll()
        
        let okAction = {
            if let userSettings = UserDefaults.standard.object(UserSettings.self, forKey: Constants.UserDefaultsKeys.userSettingsKey) {
                self.setupTimers(dangerObjectsSpeed: userSettings.gameLevel, isMinimalistic: userSettings.gameDesign, dangerCarImageName: userSettings.dangerCarImageName)
            } else {
                print("Causes some error")
            }
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
}

// MARK: - Setupping frames and constraintes

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
        carView.frame = CGRect(x: view.center.x - Constants.CarMetrics.carWidth / 2,
                               y: view.frame.height - Constants.Offsets.hyper - Constants.CarMetrics.carHeight,
                               width: Constants.CarMetrics.carWidth,
                               height: Constants.CarMetrics.carHeight)
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

