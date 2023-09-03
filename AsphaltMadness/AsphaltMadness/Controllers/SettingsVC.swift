import UIKit

final class SettingsVC: UIViewController {
    
    // MARK: - Properties
    private var selectedColorIndex = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.carColorIndex) as? Int
    private var selectedLevelIndex = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.gameLevel) as? Int
    private var selectedDangerObjectIndex = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.dangerObjectIndex) as? Int
    private var minimalisticDesign = UserDefaults.standard.object(forKey:
                                                                                Constants.UserDefaultsKeys.dangerObjectMinimalisticDesign) as? Bool

    private lazy var gamerNameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .blue
        textField.textColor = .white
        textField.textAlignment = .center
        textField.text = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.gamerName) as? String
        return textField
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
            view.image = image
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
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupInitialValues()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gamerNameTextField.roundCorners()

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
        if let selectedColorIndex {
            let indexPath = IndexPath(item: selectedColorIndex, section: 0)
            carColorsCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        }
        
        if let selectedLevelIndex {
            levelSegmentControl.selectedSegmentIndex = selectedLevelIndex
            segmentDidChange(levelSegmentControl)
        }
        if let selectedDesign = minimalisticDesign {
            dangerDesignSegmentControl.selectedSegmentIndex = selectedDesign ? 0 : 1
            designSegmentDidChange(dangerDesignSegmentControl)
        }
    }

    private func saveUserDefaults() {
        UserDefaults.standard.set(gamerNameTextField.text, forKey: Constants.UserDefaultsKeys.gamerName)
        UserDefaults.standard.set(selectedColorIndex, forKey: Constants.UserDefaultsKeys.carColorIndex)
        UserDefaults.standard.set(selectedLevelIndex, forKey: Constants.UserDefaultsKeys.gameLevel)
        UserDefaults.standard.set(selectedDangerObjectIndex, forKey: Constants.UserDefaultsKeys.dangerObjectIndex)
        UserDefaults.standard.set(minimalisticDesign, forKey: Constants.UserDefaultsKeys.dangerObjectMinimalisticDesign)
    }
    
    // MARK: - Actions
    
    @objc private func segmentDidChange(_ sender: UISegmentedControl) {
        selectedLevelIndex = sender.selectedSegmentIndex
        
    }
    
    @objc private func designSegmentDidChange(_ sender: UISegmentedControl) {
        minimalisticDesign = sender.selectedSegmentIndex == 0
    }

    
    @objc func showNewImage(_ sender: UIButton) {
        let direction = sender == backButton ? -1 : 1
        
        if let currentIndex = selectedDangerObjectIndex {
            let nextIndex = (currentIndex + direction + dangerObjectsList.count) % dangerObjectsList.count
            selectedDangerObjectIndex = nextIndex
            dangerObjectView.image = dangerObjectsList[nextIndex]
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
        carView.backgroundColor = listOfColors[indexPath.item]
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
        selectedColorIndex = indexPath.item
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

    
