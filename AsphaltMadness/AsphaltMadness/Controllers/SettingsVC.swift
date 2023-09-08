import UIKit

final class SettingsVC: UIViewController {
    
    // MARK: - Properties
    private var selectedColorName: String?
    private var selectedLevel: Double?
    private var selectedDangerObjectIndex: Int? = 0
    private var isMinimalisticDesign: Bool?
    
    private lazy var gamerNameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .blue
        textField.textColor = .white
        textField.textAlignment = .center
        return textField
    }()
    
    private lazy var avatarImage: UIImageView = {
        let avatar = UIImageView()
        avatar.image = UIImage(systemName: "person.crop.circle.fill")
        return avatar
    }()
    
    private lazy var carColorsCollectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        cv.showsHorizontalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    private lazy var dangerObjectView = {
        let view = UIImageView()
        if let selectedDangerObjectIndex {
            let image = dangerObjectsList[selectedDangerObjectIndex]
            view.image = UIImage(named: image)
        }
        return view
    }()
    
    private lazy var dangerObjectsPanel = UIView()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(systemName: "arrowshape.backward.fill"), for: .normal)
        button.addTarget(self, action: #selector(showNewImage(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(systemName: "arrowshape.right.fill"), for: .normal)
        button.addTarget(self, action: #selector(showNewImage(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var dangerDesignSegmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: ["2D", "Minimalistic"])
        segmentControl.addTarget(self, action: #selector(designSegmentDidChange(_:)), for: .valueChanged)
        return segmentControl
    }()
    
    private lazy var levelSegmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: ["easy", "medium", "hard", "Legend", "GOAT"])
        segmentControl.addTarget(self, action: #selector(segmentDidChange(_:)), for: .valueChanged)
        return segmentControl
    }()
    
    private let colorsArray = Array(listOfColors.values)
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gamerNameTextField.roundCorners()
        setupInitialValues()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveUserDefaults()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = false
        addSubviews()
        setupDangerObjectPanel()
        //MARK: - Заглушка, пока не сделается онбординг
        //        if let entries = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.appEntries) as? Int,
        //        entries < 2 {
        //            selectedDangerObjectName = 0
        //        } else {
        //            selectedDangerObjectName = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.dangerObjectIndex) as? Int
        //        }
        
        //        if let selectedDangerObjectIndex = selectedDangerObjectName {
        //          //  dangerObjectView.image = dangerObjectsList[selectedDangerObjectIndex]
        //        }
    }
    
    private func addSubviews() {
        view.addSubview(gamerNameTextField)
        view.addSubview(carColorsCollectionView)
        view.addSubview(dangerObjectsPanel)
        view.addSubview(levelSegmentControl)
        view.addSubview(dangerDesignSegmentControl)
    }
    
    // MARK: - User Defaults
    
    private func setupInitialValues() {
        guard let savedsettings = UserDefaults.standard.object(UserSettings.self,
                                                               forKey: Constants.UserDefaultsKeys.userSettingsKey) else {
            return
        }
        
        levelSegmentControl.selectedSegmentIndex = Int(savedsettings.gameLevel) - 1
        dangerDesignSegmentControl.selectedSegmentIndex = savedsettings.gameDesign ? 0 : 1
        gamerNameTextField.text = savedsettings.userName
        dangerObjectView.image = UIImage(named: savedsettings.dangerCarImageName)
    }
    
    private func saveUserDefaults() {
        guard let settings = UserDefaults.standard.object(UserSettings.self, forKey: Constants.UserDefaultsKeys.userSettingsKey) else {
            print("UserSettings not found in UserDefaults")
            return
        }
        
        if let userName = gamerNameTextField.text {
            settings.userName = userName
        } else {
            print("userName is nil")
        }
        
        if let selectedColorName = selectedColorName {
            settings.heroCarColorName = selectedColorName
        } else {
            print("selectedColorName is nil")
        }
        
        if let selectedDangerObjectIndex = selectedDangerObjectIndex {
            settings.dangerCarImageName = dangerObjectsList[selectedDangerObjectIndex]
        } else {
            print("selectedDangerObjectIndex is nil")
        }
        
        if let selectedLevel = selectedLevel {
            settings.gameLevel = selectedLevel + 1
        } else {
            print("selectedLevel is nil")
        }
        
        if let isMinimalisticDesign = isMinimalisticDesign {
            settings.gameDesign = isMinimalisticDesign
        } else {
            print("isMinimalisticDesign is nil")
        }
        
        UserDefaults.standard.set(encodable: settings, forKey: Constants.UserDefaultsKeys.userSettingsKey)

    }
    
    // MARK: - Actions
    @objc private func segmentDidChange(_ sender: UISegmentedControl) {
        selectedLevel = Double(sender.selectedSegmentIndex)
    }
    
    @objc private func designSegmentDidChange(_ sender: UISegmentedControl) {
        isMinimalisticDesign = sender.selectedSegmentIndex == 0
    }
    
    @objc func showNewImage(_ sender: UIButton) {
        let direction = sender == backButton ? -1 : 1
        if let currentIndex = selectedDangerObjectIndex {
            let nextIndex = (currentIndex + direction + dangerObjectsList.count) % dangerObjectsList.count
            selectedDangerObjectIndex = nextIndex
            dangerObjectView.image = UIImage(named: dangerObjectsList[nextIndex])
        }
    }
}

extension SettingsVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    private func setupConstraints() {
        gamerNameTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Constants.Offsets.large)
            make.height.equalTo(Constants.Settings.textFieldHeight)
            make.width.equalTo(Constants.Settings.textFieldWidth)
        }
        
        carColorsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(gamerNameTextField.snp.bottom).offset(Constants.Offsets.medium)
            make.height.equalTo(Constants.Settings.collectionViewHeight)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        dangerObjectsPanel.snp.makeConstraints { make in
            make.top.equalTo(carColorsCollectionView.snp.bottom).offset(Constants.Offsets.medium)
            make.height.equalTo(Constants.Settings.collectionViewHeight)
            make.left.equalToSuperview().inset(Constants.Offsets.medium)
            make.right.equalToSuperview().inset(Constants.Offsets.medium)
        }
        
        dangerDesignSegmentControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(dangerObjectsPanel.snp.bottom).offset(Constants.Offsets.medium)
            
        }
        
        levelSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(dangerDesignSegmentControl.snp.bottom).offset(Constants.Offsets.large)
            make.centerX.equalToSuperview()
            make.width.equalTo(dangerObjectsPanel.snp.width).inset(Constants.Offsets.medium)
            make.height.equalTo(gamerNameTextField.snp.height)
        }
    }
    
    private func setupDangerObjectPanel() {
        dangerObjectsPanel.addSubview(dangerObjectView)
        dangerObjectsPanel.addSubview(backButton)
        dangerObjectsPanel.addSubview(nextButton)
        dangerObjectsPanel.backgroundColor = .secondarySystemBackground
        dangerObjectsPanel.roundCorners()
        
        dangerObjectView.roundCorners()
        dangerObjectView.clipsToBounds = true
        
        dangerObjectView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Constants.Offsets.small)
            make.height.equalTo(Constants.CarMetrics.carHeight * 1.8)
            make.width.equalTo(Constants.CarMetrics.carWidth * 2)
        }
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
            make.width.height.equalTo(Constants.Game.buttonWidth)
        }
        
        nextButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
            make.width.height.equalTo(Constants.Game.buttonWidth)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOfColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let carView = UIView()
        carView.backgroundColor = colorsArray[indexPath.item]
        carView.roundCorners()
        carView.dropShadow()
        cell.contentView.addSubview(carView)
        
        carView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(Constants.CarMetrics.carHeight)
            make.width.equalTo(Constants.CarMetrics.carWidth)
        }
        
        cell.backgroundColor = .white
        cell.roundCorners()
        cell.dropShadow()
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let keysArray = Array(listOfColors.keys)
        
        guard indexPath.item < keysArray.count else { return }
        selectedColorName = keysArray[indexPath.item]
        print("selected")
    }
    
    // MARK: - Compositional Layout
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .fractionalHeight(0.6))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20)
        
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .fractionalWidth(0.8))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitem: layoutItem, count: 1)
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
        
        return UICollectionViewCompositionalLayout(section: layoutSection)
    }
}
