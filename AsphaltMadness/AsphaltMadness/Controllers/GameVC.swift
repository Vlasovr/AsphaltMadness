import UIKit

class GameVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Initialize two backgrounds to manage them in animations block
    private lazy var backgroundView = BackgroundView()
    
    private lazy var upperBackgroundView = BackgroundView()
    
    private lazy var carView = {
        let car = UIView()
        return car
    }()
    
    //MARK: - Array of views pointers
    private var listOfСars = [UIView]()
    
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
    
    //MARK: - future feature ?? SPEED COEFficient
    private var timerCoefficient = 1.0 {
        didSet {
            animationSpeedUpCoef -= timerCoefficient / 2
        }
    }
    
    private var animationSpeedUpCoef = 5.0
    
    
    //MARK: - Some counter that I would use
    private lazy var countUserCarActions = 0 {
        didSet {
            print(countUserCarActions)
        }
    }
    
    //MARK: - Initialise real car object
    private lazy var dynamicAnimator = UIDynamicAnimator()
    private var snap: UISnapBehavior?
    
    // MARK: - VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        addSubviews()
        setupConstraints()
        
        let pointsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.points += (Double.random(in: (0.0...3.0) ) * self.timerCoefficient)
        }

        let speedCoefTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.timerCoefficient *= 1.1
            self.addDangerCars(minX: self.backgroundView.getSingleLineWidth(), maxX: self.backgroundView.getSingleLineWidth() * 2)
        }

        let leftLineDangerTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            self.addDangerCars(minX: Constants.Offsets.small, maxX: self.backgroundView.getSingleLineWidth())
        }

        let rightCenteredLineDangerTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            self.addDangerCars(minX: self.backgroundView.getSingleLineWidth() * 2, maxX: self.backgroundView.getSingleLineWidth() * 3)
        }

//        let rightLineDangerTimer = Timer.scheduledTimer(withTimeInterval: 5.5, repeats: true) { _ in
//            self.addDangerCars(minX: self.backgroundView.getSingleLineWidth() * 3, maxX: self.backgroundView.getSingleLineWidth() * 4)
//        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let colorIndex = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.carColorIndex) as? Int {
            carView.backgroundColor = listOfColors[colorIndex]
        }
        
        setupFrames()
        self.animateWay(backView: backgroundView,
                        upperView: upperBackgroundView,
                        duration: Constants.Game.roadAnimationSpeed)
        setupBackground()
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

    
    //MARK: - Realisation of danger objects with timer
    
    private func addDangerCars(minX: CGFloat, maxX: CGFloat) {
        let car = UIView()
        car.randomiseColor()
        car.roundCorners()
        car.wobble()
        view.addSubview(car)
        setRandomPosition(to: car,
                          minX: minX,
                          maxX: maxX,
                          y: -Constants.CarMetrics.carHeight - view.safeAreaInsets.top,
                          width: Constants.CarMetrics.carWidth,
                          height: Constants.CarMetrics.carHeight)
        car.dropShadow()
        listOfСars.append(car)
        animateDangerObject(object: car)
    }
    
    private func setRandomPosition(to object: UIView, minX: CGFloat, maxX: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let x = CGFloat.random(in: (minX...maxX))
        object.frame = CGRect(x: x, y: y, width: width, height: height)
    }
    
    private func checkCarIsBumped(object: UIView) {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] _ in
            if let objectFrame = object.layer.presentation()?.frame {
                let curbFrames = backgroundView.getCurbsFrames()
                if carView.frame.intersects(objectFrame) || carView.frame.intersects(curbFrames.0) || carView.frame.intersects(curbFrames.1) {
                    carView.layerremoveAllAnimations()
                    carView.removeFromSuperview()
                    stopGame()
                }
            }
        }
    }

    //MARK: - Animations Block

    private func animateDangerObject(object: UIView) {
        guard let speedLevel = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.gameLevel) as? Double else { return }
        UIView.animate(withDuration: speedLevel, delay: .zero, options: .curveLinear) {
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
       // stopAnimations()
        timerCoefficient = 1
        let layer = view.layer
        pauseLayer(layer: layer)
        
        //MARK: - ALERT CONTROLLER
        let alert = UIAlertController(title: "Конец игры!", message: "Не отчаивайся, ты сможешь лучше", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
            self.points = 0
            self.view.addSubview(self.carView)
        }
        
        alert.addAction(okAction)
        
        let cancel = UIAlertAction(title: "Выйти", style: .cancel) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(cancel)
        
        self.present(alert, animated: true)
    }
    
    private func stopAnimations()   {
        self.listOfСars.forEach { $0.layer.removeAllAnimations() }
        self.view.layer.removeAllAnimations()
        backgroundView.layer.removeAllAnimations()
        upperBackgroundView.layer.removeAllAnimations()
        self.view.layoutIfNeeded()
    }
}
// MARK: - Setupping frames and constraintes

extension GameVC {
    
    func addSubviews() {
        view.addSubview(backgroundView)
        view.addSubview(upperBackgroundView)
        view.addSubview(carView)
        view.addSubview(pointsLabel)
        view.addSubview(buttonsContainerView)
        buttonsContainerView.addSubview(leftButton)
        buttonsContainerView.addSubview(rightButton)
    }
    
    func setupBackground() {
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
    
    func setupFrames() {

        carView.frame = CGRect(x: view.center.x - Constants.CarMetrics.carWidth / 2,
                               y: view.frame.height - Constants.Offsets.hyper - Constants.CarMetrics.carHeight,
                               width: Constants.CarMetrics.carWidth,
                               height: Constants.CarMetrics.carHeight
                               )
 
        setupCarView(car: carView)
    }
    
    private func setupCarView(car: UIView) {
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

