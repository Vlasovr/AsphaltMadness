import UIKit

final class SettingsVC: UIViewController {
    
    private var selectedColor = 0
    private var selectedLevel = 0
    
    private lazy var colorsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    private lazy var gamerNameTextField = {
        let textField = UITextField()
        textField.backgroundColor = .blue
        textField.textColor = .white
        textField.textAlignment = .center
        textField.text = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.gamerName) as? String
        return textField
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        var segmentContr = UISegmentedControl(items: ["1", "2", "3"])
        if let index = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.gameLevel) as? Int {
            segmentContr.selectedSegmentIndex = index
        }
        segmentContr.addTarget(self, action: #selector(segmentDidChange(_:)), for: .valueChanged)
        return segmentContr
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        setupConstraints()
        colorsCollectionView.dataSource = self
        colorsCollectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gamerNameTextField.roundCorners()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserDefaults.standard.set(gamerNameTextField.text, forKey: Constants.UserDefaultsKeys.gamerName)
        UserDefaults.standard.set(selectedColor, forKey: Constants.UserDefaultsKeys.carColorIndex)
        UserDefaults.standard.set(selectedLevel, forKey: Constants.UserDefaultsKeys.gameLevel)
    }
    
    @objc func segmentDidChange(_ sender: UISegmentedControl) {
        selectedLevel = sender.selectedSegmentIndex
    }
}

extension SettingsVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    private func addSubviews() {
        view.addSubview(gamerNameTextField)
        view.addSubview(colorsCollectionView)
        view.addSubview(segmentedControl)
    }
    
    private func setupConstraints() {
        gamerNameTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Constants.Offsets.large)
            make.height.equalTo(Constants.Settings.textFieldHeight)
            make.width.equalTo(Constants.Settings.textFieldWidth)
        }
        
        colorsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(gamerNameTextField.snp.bottom).offset(Constants.Offsets.medium)
            make.height.equalTo(Constants.Settings.collectionViewHeight)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        segmentedControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(colorsCollectionView.snp.width)
            make.height.equalTo(gamerNameTextField.snp.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width * 0.75, height: collectionView.frame.width )
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
        
        cell.backgroundColor = .lightGray
        cell.layer.cornerRadius = 20
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let target = targetContentOffset.pointee
        
        let center = CGPoint(x: target.x + colorsCollectionView.bounds.width / 2, y: target.y + colorsCollectionView.bounds.height / 2)
        
        guard let indexPath = colorsCollectionView.indexPathForItem(at: center) else { return }
        
        guard let attributes = colorsCollectionView.layoutAttributesForItem(at: indexPath) else { return }
        
        let insets = colorsCollectionView.contentInset
        
        let itemSize = attributes.frame.size
        
        let spacing = (colorsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing ?? 0
        
        let newX = round((target.x - insets.left) / (itemSize.width + spacing)) * (itemSize.width + spacing)
        
        targetContentOffset.pointee = CGPoint(x: newX, y: target.y)
        colorsCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
        
        selectedColor = indexPath.item
    }
}
