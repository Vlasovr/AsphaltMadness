import UIKit

class MainVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Initialize two backgrounds to manage them in animations block
    private var backgroundView = BackgroundView()
    
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
    
    //MARK: - Make! goodLooking points
    private lazy var menuLabel = {
        let label = UILabel()
        label.font = UIFont(name: "Jura-Bold", size: Constants.FontSizes.mediumFont)
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        var attributtedString = NSMutableAttributedString(string: "Points: ", attributes: attributes)
        let addAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        let addAttributtedString = NSAttributedString(string: "", attributes: addAttributes)
        attributtedString.append(addAttributtedString)
        label.text = "Menu"
        return label
    }()
    
    private lazy var playButton = {
        let button = UIButton()
        button.setTitle("Play", for: .normal)

        button.addTarget(self, action: #selector(goToGameScreen(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var settingsButton = {
        let button = UIButton()
        button.setTitle("Settings", for: .normal)
        
        button.addTarget(self, action: #selector(goToSettingsScreen(_:)), for: .touchUpInside)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //resumeLayer(layer: view.layer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupFrames()
        if let colorIndex = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.carColorIndex) as? Int {
            carView.backgroundColor = listOfColors[colorIndex]
        }
        
//        self.animateWay(backView: backgroundView,
//                        upperView: upperBackgroundView,
//                        duration: Constants.Game.roadAnimationSpeed)
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
        //pauseLayer(layer: view.layer)
    }

}
// MARK: - Setuping frames and constraintes

extension MainVC {
    
    func addSubviews() {
        view.addSubview(backgroundView)
        //view.addSubview(upperBackgroundView)
        view.addSubview(carView)
        view.addSubview(containerAlphaView)
        view.addSubview(playButton)
        view.addSubview(settingsButton)
    }
    
    func setupFrames() {
        backgroundView.frame = CGRect(x: view.frame.origin.x,
                                      y: -view.frame.height,
                                      width: view.frame.width,
                                      height: view.frame.height)
        
        backgroundView.setupSubviews()
        backgroundView.bounds.origin.y -= view.frame.height
        
//        upperBackgroundView.frame = CGRect(x: view.frame.origin.x,
//                                           y: -view.frame.height,
//                                           width: view.frame.width,
//                                           height: view.frame.height
//        )
//
//        upperBackgroundView.setupSubviews()
        
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
    
    private func setupConstraints() {
        containerAlphaView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        playButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        settingsButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(Constants.Offsets.hyper)
        }
        
    }
}

