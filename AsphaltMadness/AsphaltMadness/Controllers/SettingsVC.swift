import UIKit

final class SettingsVC: UIViewController {
    
    // MARK: - Properties
    private var selectedColorName: String?
    private var selectedLevel: Double?
    private var selectedDangerObjectIndex: Int?
    private var isMinimalisticDesign: Bool?
    
    private lazy var gamerNameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .blue
        textField.textColor = .white
        textField.textAlignment = .center
        return textField
    }()
    
    private lazy var avatarImage = {
        let avatar = CircularImageView()
        avatar.isUserInteractionEnabled = true
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

        loadUserDefaults()
        setupGestureRecogniser()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveUserDefaults()

    }
    override func viewDidLayoutSubviews() {
        gamerNameTextField.roundCorners()
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
        view.addSubview(avatarImage)
        view.addSubview(carColorsCollectionView)
        view.addSubview(dangerObjectsPanel)
        view.addSubview(levelSegmentControl)
        view.addSubview(dangerDesignSegmentControl)
    }
    
    // MARK: - User Defaults
    
    private func loadUserDefaults() {
        if let savedSettings = UserDefaults.standard.object(UserSettings.self, forKey: Constants.UserDefaultsKeys.userSettingsKey) {
            loadSavedSettings(savedSettings)
        }
    }
    
    private func loadSavedSettings(_ settings: UserSettings) {
        if let savedAvatarImage = DataManager.shared.loadImage(fileName: settings.avatarImageName) {
            avatarImage.image = savedAvatarImage
        } else {
            avatarImage.image = UIImage(named: "person.crop.circle.fill")
        }
        
        gamerNameTextField.text = settings.userName
        
        selectedColorName = settings.carColorName
        
        levelSegmentControl.selectedSegmentIndex = Int(settings.gameLevel) - 1
        selectedLevel = settings.gameLevel - 1
        
        dangerDesignSegmentControl.selectedSegmentIndex = settings.gameDesign ? 0 : 1
        isMinimalisticDesign = settings.gameDesign
        
        dangerObjectView.image = UIImage(named: settings.dangerCarImageName)
        selectedDangerObjectIndex = dangerObjectsList.firstIndex(where: { $0 == settings.dangerCarImageName })
    }

    
    private func saveUserDefaults() {
        guard let settings = UserDefaults.standard.object(UserSettings.self, forKey: Constants.UserDefaultsKeys.userSettingsKey) else {
            print("UserSettings not found in UserDefaults")
            return
        }
        
        if let directoryPath = DataManager.shared.saveImage(image: avatarImage.image),
           let userName = gamerNameTextField.text,
           let selectedColorName = selectedColorName,
           let selectedDangerObjectIndex = selectedDangerObjectIndex,
           let selectedLevel = selectedLevel,
           let isMinimalisticDesign = isMinimalisticDesign {
            settings.avatarImageName = directoryPath
            settings.userName = userName
            settings.carColorName = selectedColorName
            settings.dangerCarImageName = dangerObjectsList[selectedDangerObjectIndex]
            settings.gameLevel = selectedLevel + 1
            settings.gameDesign = isMinimalisticDesign
        }
        UserDefaults.standard.set(encodable: settings, forKey: Constants.UserDefaultsKeys.userSettingsKey)
    }
    
    private func setupGestureRecogniser() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(chooseNewAvatar(_:)))
        avatarImage.addGestureRecognizer(tap)
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
    
    @objc func chooseNewAvatar(_ sender: UITapGestureRecognizer) {
        print("Tapped")
        showAlert(messageTitle: "ChoosePhoto", alertStyle: .actionSheet, firstButtonTitle: "Library", secondButtonTitle: "Camera", firstAlertActionStyle: .default, secondAlertActionStyle: .default, firstHandler:  {
            self.showPicker(source: .photoLibrary)
        }) {
            self.showPicker(source: .camera)
        }
    }
}

extension SettingsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var chosenImage = UIImage()
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            chosenImage = image
        } else if  let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            chosenImage = image
        }
        
        avatarImage.image = chosenImage
        picker.dismiss(animated: true)
    }
    
    private func showPicker(source: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = source
        present(imagePicker, animated: true)
    }
}


extension SettingsVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    private func setupConstraints() {
        gamerNameTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(Constants.Offsets.big)
            make.top.equalToSuperview().offset(Constants.Offsets.large + Constants.Offsets.big)
            make.height.equalTo(Constants.Settings.textFieldHeight)
            make.width.equalTo(Constants.Settings.textFieldWidth)
        }
        
        avatarImage.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-Constants.Offsets.big)
            make.top.equalToSuperview().offset(Constants.Offsets.large + Constants.Offsets.medium)
            make.height.width.equalTo(Constants.Game.avatarSide)
        }
        
        carColorsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(avatarImage.snp.bottom).offset(Constants.Offsets.medium)
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
