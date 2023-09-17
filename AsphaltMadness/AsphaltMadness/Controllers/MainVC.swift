import UIKit

final class MainVC: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Initialize two backgrounds to manage them in animations block
    private lazy var mainRoadView = BackgroundView()
    
    private var upperRoadView = BackgroundView()
    
    private lazy var carView = UIView()
    
    //MARK: - Setup menu elements
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
        label.font = UIFont(name: "Blazed", size: Constants.FontSizes.large)
        return label
    }()
    
    private lazy var menuView = UIView()
    
    private lazy var menuLabel = {
        let label = UILabel()
        label.font = UIFont(name: "Jura-Bold", size: Constants.FontSizes.hyper)
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.blue,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        var attributtedString = NSMutableAttributedString(string: "Menu", attributes: attributes)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playButton.roundCorners()
        settingsButton.roundCorners()
        recordsButton.roundCorners()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupFrames()
        setupUI()
    }
    
    //MARK: Setup UI with loading user settings
    private func setupUI() {
        if let userSettings = UserDefaults.standard.object(UserSettings.self,
                                                           forKey: Constants.UserDefaultsKeys.userSettingsKey) {
            loadUserSettings(userSettings)
        } else {
            let defaultSettings = UserSettings(avatarImageName: "person.crop.circle.fill", userName: "Avatar", carColorName: "blue", dangerCarImageName: "redDangerObject", gameDesign: true, gameLevel: 2.0)
            UserDefaults.standard.set(encodable: defaultSettings, forKey: Constants.UserDefaultsKeys.userSettingsKey)
            loadUserSettings(defaultSettings)
        }
    }

    private func loadUserSettings(_ userSettings: UserSettings) {
        let gameLevel = userSettings.gameLevel
        carView.backgroundColor = listOfColors[userSettings.carColorName]
        animateRoad(backView: mainRoadView, upperView: upperRoadView, duration: gameLevel)
    }
    
    @objc func goToSettingsScreen(_ sender: UIButton) {
        let settingsController = SettingsVC()
        navigationController?.pushViewController(settingsController, animated: true)
    }
    
    @objc func goToGameScreen(_ sender: UIButton) {
        let gameController = GameVC()
        navigationController?.pushViewController(gameController, animated: true)
    }
}
// MARK: - Setuping frames and constraintes
extension MainVC {
    
    func addSubviews() {
        view.addSubview(mainRoadView)
        view.addSubview(upperRoadView)
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
        
        setupRoadFrames(mainView: mainRoadView, upperView: upperRoadView)
        
        carView.frame = CGRect(x: view.center.x - Constants.CarMetrics.carWidth / 2,
                               y: view.frame.height - Constants.Offsets.hyper - Constants.CarMetrics.carHeight,
                               width: Constants.CarMetrics.carWidth,
                               height: Constants.CarMetrics.carHeight
        )
        setupCarView(car: carView)
        
        gameNameLabel.transform = CGAffineTransform(rotationAngle:
                                                        Constants.Game.gameNameLabelRotationAngle)
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
            make.top.equalTo(gameNameLabel.snp.bottom).offset(Constants.Offsets.big)
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

