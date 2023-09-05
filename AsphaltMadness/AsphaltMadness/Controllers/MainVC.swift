import UIKit

class MainVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Initialize two backgrounds to manage them in animations block
    private lazy var backgroundView = BackgroundView()
    
    private var upperBackgroundView = BackgroundView()
    
    private lazy var carView = {
        if let color = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.carColorIndex) as? Int {
            let car = self.createCar(color: listOfColors[color])
            return car
        }
        return self.createCar(color: UIColor.systemBlue)
    }()
    
    private lazy var containerAlphaView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.3
        return view
    }()

    private lazy var gameNameLabel = {
       let label = UILabel()
        label.text = "AsphaltMadness"
        label.textColor = .white
        label.font = UIFont(name: "Blazed", size: 32)
        return label
    }()
    
    private lazy var menuView = UIView()
    
    //MARK: - Make! goodLooking points
    private lazy var menuLabel = {
        let label = UILabel()
        label.font = UIFont(name: "Jura-Bold", size: Constants.FontSizes.mediumFont)
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.blue,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        var attributtedString = NSMutableAttributedString(string: "Menu", attributes: attributes)
        let addAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
        ]
        label.attributedText = attributtedString
        return label
    }()
    
    private lazy var playButton = {
        let button = AdaptiveButton(title: "Play")
        button.backgroundColor = .systemBlue
        button.addTarget(self, action: #selector(goToGameScreen(_:)), for: .touchUpInside)
        return button
    }()

    
    private lazy var settingsButton = {
        let button = AdaptiveButton(title: "Settings")
        button.backgroundColor = .systemBlue
        button.addTarget(self, action: #selector(goToSettingsScreen(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var recordsButton = {
        let button = AdaptiveButton(title: "Records")
        button.backgroundColor = .systemBlue
        return button
    }()
    
    // MARK: - VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        addSubviews()
        setupConstraints()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playButton.roundCorners()
        settingsButton.roundCorners()
        recordsButton.roundCorners()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupFrames()
        if let colorIndex = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.carColorIndex) as? Int {
            carView.backgroundColor = listOfColors[colorIndex]
        }
       
        self.animateWay(backView: backgroundView,
                        upperView: upperBackgroundView,
                        duration: Constants.Game.roadAnimationSpeed)
    }
    
    @objc func goToSettingsScreen(_ sender: UIButton) {
        let settingsController = SettingsVC()
        navigationController?.pushViewController(settingsController, animated: true)
    }
    
    @objc func goToGameScreen(_ sender: UIButton) {
        let gameController = GameVC()
        navigationController?.pushViewController(gameController, animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        UIView.animate(withDuration: 0.3) {
            
        }
    }

}
// MARK: - Setuping frames and constraintes

extension MainVC {
    
    func addSubviews() {
        view.addSubview(backgroundView)
        view.addSubview(upperBackgroundView)
        view.addSubview(containerAlphaView)
        view.addSubview(gameNameLabel)
        view.addSubview(menuView)
        menuView.addSubview(menuLabel)
        menuView.addSubview(playButton)
        menuView.addSubview(settingsButton)
        menuView.addSubview(recordsButton)
        view.addSubview(carView)
    }
    
    func setupFrames() {
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
        
        
        carView.frame = CGRect(x: view.center.x - Constants.CarMetrics.carWidth / 2,
                               y: view.frame.height - Constants.Offsets.hyper - Constants.CarMetrics.carHeight,
                               width: Constants.CarMetrics.carWidth,
                               height: Constants.CarMetrics.carHeight
        )
        setupCarView(car: carView)

        gameNameLabel.transform = CGAffineTransform(rotationAngle: -0.7)
    }
    
    private func setupCarView(car: UIView) {
        car.roundCorners()
        car.dropShadow()
        car.wobble()
    }
    
    private func setupConstraints() {
        containerAlphaView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gameNameLabel.snp.makeConstraints { make in
            make.left.equalTo(Constants.Offsets.small)
            make.top.equalToSuperview().offset(Constants.Offsets.hyper)
            make.height.equalTo(Constants.Game.gameNameLabelHeight)
            make.width.equalTo(Constants.Game.gameNameLabelWidth)
        }
        
        menuView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(gameNameLabel.snp.bottom).offset(Constants.Offsets.medium)
            make.height.equalTo(Constants.Game.menuHeight)
            make.width.equalTo(Constants.Game.menuWidth)
        }
        menuLabel.snp.makeConstraints { make in
            make.top.equalTo(menuView.snp.top).offset(Constants.Offsets.medium + Constants.Offsets.small)
            make.centerX.equalToSuperview()
        }
        
        playButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(Constants.Game.buttonWidth * 2)
            make.height.equalTo(Constants.Game.buttonHeight)
        }
        
        settingsButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(Constants.Game.buttonWidth * 1.75)
            make.height.equalTo(Constants.Game.buttonHeight)
            make.top.equalTo(playButton.snp.bottom).offset(Constants.Offsets.medium)
        }
        
        recordsButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(Constants.Game.buttonWidth * 1.5)
            make.height.equalTo(Constants.Game.buttonHeight)
            make.top.equalTo(settingsButton.snp.bottom).offset(Constants.Offsets.medium)
        }
    }
}

