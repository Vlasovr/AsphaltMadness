import UIKit

class RecordTableViewCell: UITableViewCell {
    
    static var identifier: String { "\(Self.self)" }
    
    private lazy var userNameLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.FontSizes.large)
        return label
    }()
    
    private lazy var pointsLabel = {
        let label = UILabel()
        label.font = UIFont(name: Constants.Font.blazed, size: Constants.FontSizes.medium)
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        var attributtedString = NSMutableAttributedString(string: Constants.Game.MenuStrings.menu, attributes: attributes)
        label.attributedText = attributtedString
        return label
    }()
    
    private lazy var dateLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.FontSizes.medium)
        return label
    }()
    
    private lazy var userAvatar = CircularImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userNameLabel.text = nil
        userAvatar.image = nil
        pointsLabel.text = nil
        dateLabel.text = nil
    }
    
    func configureCell(userName: String, avatarImageName: String, points: Double, date: String) {
        userNameLabel.text = userName
        
        if let savedAvatarImage = DataManager.shared.loadImage(fileName: avatarImageName) {
            userAvatar.image = savedAvatarImage
        } else {
            userAvatar.image = UIImage(systemName: avatarImageName)
        }
        
        let formattedPoints = String(format: Constants.RecordsScreen.pointsFormat, points)
        pointsLabel.text = Constants.RecordsScreen.points + formattedPoints
        
        dateLabel.text = date
    }
    
    private func addSubviews() {
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userAvatar)
        contentView.addSubview(pointsLabel)
        contentView.addSubview(dateLabel)
    }
    
    private func setupConstraints() {
        userAvatar.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Constants.Offsets.medium)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(Constants.Game.avatarSide - Constants.Offsets.small)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.left.equalTo(userAvatar.snp.right).offset(Constants.Offsets.small)
            make.top.equalToSuperview()
        }
        
        pointsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Constants.Offsets.small)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-Constants.Offsets.medium)
        }
    }
}
