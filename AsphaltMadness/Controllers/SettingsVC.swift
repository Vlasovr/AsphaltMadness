import UIKit

//MARK: - перестали выбираться цвета машинки

final class SettingsVC: UIViewController {
    
    // MARK: - variables to work with UI and User Defaults
    private var selectedColorName: String?
    private var selectedLevel: Double?
    private var selectedDangerObjectIndex: Int?
    private var isMinimalisticDesign: Bool?
    private var isButtonControl: Bool?
    
    //MARK: - User name
    private lazy var gamerNameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .blue
        textField.textColor = .white
        textField.textAlignment = .center
        return textField
    }()
    
    //MARK: - Users avatar
    private lazy var avatarImage = {
        let avatar = CircularImageView()
        avatar.isUserInteractionEnabled = true
        return avatar
    }()
    
    //MARK: - Color of hero car
    private lazy var carColorsCollectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Constants.Settings.cellIdentifier)
        cv.showsHorizontalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        cv.showsVerticalScrollIndicator = false
        
        return cv
    }()
    
    //MARK: - Danger objects images leaflet
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
        button.setBackgroundImage(UIImage(systemName: Constants.ButtonNames.leftCircleButton), for: .normal)
        button.addTarget(self, action: #selector(showNewImage(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextButton: UIButton = {
            let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(systemName: Constants.ButtonNames.rightCircleButton), for: .normal)
        button.addTarget(self, action: #selector(showNewImage(_:)), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Design of danger object
    private lazy var dangerDesignSegmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: Constants.Settings.designSegmentControlItems)
        segmentControl.addTarget(self, action: #selector(designSegmentDidChange(_:)), for: .valueChanged)
        return segmentControl
    }()
    //MARK: - Car control variant
    private lazy var carRaceSegmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: Constants.Settings.raceSegmentControlItems)
        segmentControl.addTarget(self, action: #selector(raceSegmentDidChange(_:)), for: .valueChanged)
        return segmentControl
    }()
    
    //MARK: - Choosing level of the game
    private lazy var levelSegmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: Constants.Settings.levelSegmentControlItems)
        segmentControl.addTarget(self, action: #selector(levelSegmentDidChange(_:)), for: .valueChanged)
        return segmentControl
    }()
    
    //MARK: - Taking colors strings from dictionary to manage them in array
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
    
    override func viewDidLayoutSubviews() {
        setupDangerObjectPanel()
        gamerNameTextField.roundCorners()

        gamerNameTextField.dropShadow()
        dangerObjectsPanel.dropShadow()
        dangerObjectsPanel.roundCorners()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveUserDefaults()
    }
    
    @objc func closeSettings(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = false
        addSubviews()
    }
    
    private func addSubviews() {
        view.addSubview(gamerNameTextField)
        view.addSubview(avatarImage)
        view.addSubview(carColorsCollectionView)
        view.addSubview(dangerObjectsPanel)
        view.addSubview(levelSegmentControl)
        view.addSubview(carRaceSegmentControl)
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
            avatarImage.image = UIImage(systemName: Constants.Settings.defaultSettings.avatarImageName)
        }
        
        gamerNameTextField.text = settings.userName
        
        selectedColorName = settings.carColorName
        
        levelSegmentControl.selectedSegmentIndex = Int(settings.gameLevel) - 1
        selectedLevel = settings.gameLevel - 1
        
        dangerDesignSegmentControl.selectedSegmentIndex = settings.gameDesign ? 0 : 1
        isMinimalisticDesign = settings.gameDesign
        
        carRaceSegmentControl.selectedSegmentIndex = settings.isButtonControl ? 0 : 1
        
        dangerObjectView.image = UIImage(named: settings.dangerCarImageName)
        selectedDangerObjectIndex = dangerObjectsList.firstIndex(where: { $0 == settings.dangerCarImageName })
    }

    
    private func saveUserDefaults() {
        guard let settings = UserDefaults.standard.object(UserSettings.self,
                                                          forKey: Constants.UserDefaultsKeys.userSettingsKey) else {
            return
        }
        
        if let directoryPath = DataManager.shared.saveImage(image: avatarImage.image) {
            settings.avatarImageName = directoryPath
        }
        
        if let userName = gamerNameTextField.text {
            settings.userName = userName
        }
        
        if let selectedColorName = selectedColorName {
            settings.carColorName = selectedColorName
        }
        
        if let selectedDangerObjectIndex = selectedDangerObjectIndex {
            settings.dangerCarImageName = dangerObjectsList[selectedDangerObjectIndex]
        }
        
        if let selectedLevel = selectedLevel {
            settings.gameLevel = selectedLevel + 1
        }
        
        if let isMinimalisticDesign = isMinimalisticDesign {
            settings.gameDesign = isMinimalisticDesign
        }
        
        if let isButtonControl = isButtonControl {
            settings.isButtonControl = isButtonControl
        }
        
        UserDefaults.standard.set(encodable: settings, forKey: Constants.UserDefaultsKeys.userSettingsKey)
    }
    
    //MARK: - Gesture recognisers for tapping on avatar and hiding keyboard
    private func setupGestureRecogniser() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(chooseNewAvatar(_:)))
        avatarImage.addGestureRecognizer(tap)
    }
    
    // MARK: - Changing user settings actions
    @objc private func levelSegmentDidChange(_ sender: UISegmentedControl) {
        selectedLevel = Double(sender.selectedSegmentIndex)
    }
    
    @objc private func raceSegmentDidChange(_ sender: UISegmentedControl) {
        isButtonControl = sender.selectedSegmentIndex == .zero
    }
    
    @objc private func designSegmentDidChange(_ sender: UISegmentedControl) {
        isMinimalisticDesign = sender.selectedSegmentIndex == .zero
    }
    
    @objc func chooseNewAvatar(_ sender: UITapGestureRecognizer) {
        showAlert(messageTitle: Constants.Settings.ConstantsInAlert.messageTitle,
                  alertStyle: .actionSheet,
                  firstButtonTitle: Constants.Settings.ConstantsInAlert.firstButtonTitle,
                  secondButtonTitle: Constants.Settings.ConstantsInAlert.secondButtonTitle,
                  firstAlertActionStyle: .default,
                  secondAlertActionStyle: .default, 
                  firstHandler:  {
            self.showPicker(source: .photoLibrary)
        }) {
            self.showPicker(source: .camera)
        }
    }
    
    //MARK: Leaflet with animation
    @objc func showNewImage(_ sender: UIButton) {
        let isSenderBackButton = sender == backButton
        let direction =  isSenderBackButton ? -1 : 1
        if let currentIndex = selectedDangerObjectIndex {
            let nextIndex = (currentIndex + direction + dangerObjectsList.count) % dangerObjectsList.count
            selectedDangerObjectIndex = nextIndex
            if let image =  UIImage(named:dangerObjectsList[nextIndex]) {
                if isSenderBackButton {
                    slideOutAnimation(image: image, replacingImageView: dangerObjectView)
                } else {
                    slideInAnimation(image: image, replacingImageView: dangerObjectView)
                }
            }
        }
    }
}

extension SettingsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: - Setup image picker
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

extension SettingsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SettingsVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    //MARK: - Setup constraints
    private func setupConstraints() {
        gamerNameTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(Constants.Offsets.big)
            make.top.equalToSuperview().offset(Constants.Offsets.hyper - Constants.Offsets.medium)
            make.height.equalTo(Constants.Settings.textFieldHeight)
            make.width.equalTo(Constants.Settings.textFieldWidth)
        }
        
        avatarImage.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-Constants.Offsets.big)
            make.top.equalToSuperview().offset(Constants.Offsets.large + Constants.Offsets.small)
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
        
        carRaceSegmentControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(dangerDesignSegmentControl.snp.bottom).offset(Constants.Offsets.medium)
        }
        
        levelSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(dangerDesignSegmentControl.snp.bottom).offset(Constants.Offsets.large)
            make.centerX.equalToSuperview()
            make.width.equalTo(dangerObjectsPanel.snp.width).inset(Constants.Offsets.medium)
            make.height.equalTo(gamerNameTextField.snp.height)
        }
    }
    
    private func setupDangerObjectPanel() {
        view.addSubview(dangerObjectView)
        dangerObjectsPanel.addSubview(backButton)
        dangerObjectsPanel.addSubview(nextButton)
        dangerObjectsPanel.backgroundColor = .secondarySystemBackground
        
        dangerObjectView.center.x = dangerObjectsPanel.center.x
        dangerObjectView.center.y = dangerObjectsPanel.center.y
        dangerObjectView.frame.size = CGSize(width: Constants.CarMetrics.settingsDangerObjectWidth,
                                        height: Constants.CarMetrics.settingsDangerObjectHeight)
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Constants.Offsets.big)
            make.width.height.equalTo(Constants.Game.buttonWidth)
        }
        
        nextButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Constants.Offsets.big)
            make.width.height.equalTo(Constants.Game.buttonWidth)
        }
    }
    
    //MARK: - Setup collection
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
        view.endEditing(true)
        guard indexPath.item < keysArray.count else { return }
        selectedColorName = keysArray[indexPath.item]
        print("selected")
    }
    
    // MARK: - Compositional Layoutm
    
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
