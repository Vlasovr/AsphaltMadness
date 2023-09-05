import UIKit

class GameVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Initialize two backgrounds to manage them in animations block
    private lazy var backgroundView = BackgroundView()
    
    private lazy var upperBackgroundView = BackgroundView()
    
    private lazy var carView = {
        if let color = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.carColorIndex) as? Int {
            let car = self.createCar(color: listOfColors[color])
            return car
        }
        return self.createCar(color: UIColor.systemBlue)
    }()
    
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
        label.font = UIFont(name: "Jura-Bold", size: Constants.FontSizes.mediumFont)
        return label
    }()
    
    //MARK: - SPEED Coefficient
    private var timerCoefficient = 1.0 {
        didSet {
            animationSpeedUpCoef /= timerCoefficient
        }
    }
    
    private var animationSpeedUpCoef = 3.0
    
    
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
        setupTimers()
        addSubviews()
        setupConstraints()

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let colorIndex = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.carColorIndex) as? Int {
            carView.backgroundColor = listOfColors[colorIndex]
        }
        
        setupBackground()
        setupCarView(car: carView)
        
        self.animateWay(backView: backgroundView,
                        upperView: upperBackgroundView,
                        duration: animationSpeedUpCoef)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.layerremoveAllAnimations()
        self.view.subviews.forEach{ $0.removeFromSuperview() }
        print("removed")
    }
    
    // MARK: - Touch events control
    @objc func turnDidTapped(_ sender: UIButton) {
        countUserCarActions += 1
        
        if let snap = snap {
            dynamicAnimator.removeBehavior(snap)
        }
        
        let direction = sender == leftButton ? -1.0 : 1.0
        let xOffset = direction * (countUserCarActions < 2 ? carView.frame.width / 1.5 : backgroundView.getSingleLineWidth())
        
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
    
    private func setupTimers() {
        
        let pointsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.points += (Double.random(in: (0.0...3.0) ) * self.timerCoefficient)
            self.timerCoefficient *= 1.1
        }
        timersList.append(pointsTimer)
        
        let leftLineDangerTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            
            self.addDangerCars(x: Constants.Game.spacingForCurbs + Constants.Offsets.small)
        }
        timersList.append(leftLineDangerTimer)
        
        let leftCenteredDangerTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            
            self.addDangerCars(x: self.backgroundView.getSingleLineWidth() * 2 - Constants.CarMetrics.carWidth / 2)
        }
        timersList.append(leftCenteredDangerTimer)
        
        let rightCenteredLineDangerTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            self.addDangerCars(x: self.backgroundView.getSingleLineWidth() * 3 - Constants.CarMetrics.carWidth / 2)
        }
        timersList.append(rightCenteredLineDangerTimer)
        let rightLineDangerTimer = Timer.scheduledTimer(withTimeInterval: 5.5, repeats: true) { _ in
            self.addDangerCars(x: self.backgroundView.getSingleLineWidth() * 4 - Constants.CarMetrics.carWidth / 2)
        }
        timersList.append(rightLineDangerTimer)
    }
    
    
    //MARK: - Realisation of danger objects with timer
    private func addDangerCars(x: CGFloat) {
        
        if let isMinimalistic = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.minimalisticDesign) as? Bool, isMinimalistic {
            createDangerImageView(x: x)
        } else {
            createDangerView(x: x)
        }
    }
    
    private func createDangerImageView(x: CGFloat) {
        let dangerView = UIImageView()
        if let selectedDangerObjectIndex = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.dangerObjectIndex) as? Int {
            let image = dangerObjectsList[selectedDangerObjectIndex]
            dangerView.image = image
        }
        
        dangerView.wobble()
        dangerView.backgroundColor = .clear
        view.addSubview(dangerView)
        setPosition(to: dangerView, x: x,
                    y: -Constants.CarMetrics.carHeight - view.safeAreaInsets.top,
                    width: Constants.CarMetrics.carWidth,
                    height: Constants.CarMetrics.carHeight)
        
        listOfСars.append(dangerView)
        animateDangerObject(object: dangerView)
    }
    
    private func createDangerView(x: CGFloat) {
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
        animateDangerObject(object: car)
        
    }
    private func setPosition(to object: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        object.frame = CGRect(x: x, y: y, width: width, height: height)
    }
    
    private func checkCarIsBumped(object: UIView) {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] _ in
            if let objectFrame = object.layer.presentation()?.frame {
                if carView.frame.intersects(objectFrame) || isCurbesIntersect(with: carView) {
                    
                    carView.frame = CGRect(x: view.center.x - Constants.CarMetrics.carWidth / 2,
                                           y: view.frame.height - Constants.Offsets.hyper - Constants.CarMetrics.carHeight,
                                           width: Constants.CarMetrics.carWidth,
                                           height: Constants.CarMetrics.carHeight)
                    object.removeFromSuperview()
                    carView.removeFromSuperview()
                    stopGame()
                }
            }
        }
        timersList.append(timer)
    }
    
    private func isCurbesIntersect(with object: UIView) -> Bool {
        let curbFrames = backgroundView.getCurbsFrames()
        return object.frame.intersects(curbFrames.0) || object.frame.intersects(curbFrames.1) ? (true) : (false)
    }
    
    //MARK: - Animations Block
    
    private func animateDangerObject(object: UIView) {
        guard let speedLevel = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.gameLevel) as? Double else { return }
        UIView.animate(withDuration: 4 - speedLevel, delay: .zero, options: .curveLinear) {
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
        timerCoefficient = 1
        countUserCarActions = 0
        pauseLayer(layer: backgroundView.layer)
        pauseLayer(layer: upperBackgroundView.layer)
        timersList.forEach { $0.invalidate() }
        timersList.removeAll()
        
        let okAction = {
            self.setupTimers()
            self.points = 0
            self.view.addSubview(self.carView)
            self.setupCarView(car: self.carView)
            self.resumeLayer(layer: self.backgroundView.layer)
            self.resumeLayer(layer: self.upperBackgroundView.layer)
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
        view.addSubview(backgroundView)
        view.addSubview(upperBackgroundView)
        view.addSubview(carView)
        view.addSubview(pointsLabel)
        view.addSubview(buttonsContainerView)
        buttonsContainerView.addSubview(leftButton)
        buttonsContainerView.addSubview(rightButton)
    }
    
    private func setupBackground() {
        backgroundView.frame = CGRect(x: view.frame.origin.x,
                                      y: -view.frame.height,
                                      width: view.frame.width,
                                      height: view.frame.height)
        
        backgroundView.setupSubviews()
        backgroundView.bounds.origin.y -= view.frame.height
        
        upperBackgroundView.frame = CGRect(x: view.frame.origin.x,
                                           y: -view.frame.height,
                                           width: view.frame.width,
                                           height: view.frame.height
        )
        
        upperBackgroundView.setupSubviews()
        
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

