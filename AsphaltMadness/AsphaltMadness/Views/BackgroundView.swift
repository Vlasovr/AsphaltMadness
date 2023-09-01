import UIKit
import SnapKit

final class BackgroundView: UIView {
    
    private lazy var asphaltImageView = {
        let asphaltImageView = UIView()
        asphaltImageView.backgroundColor = .lightGray
        return asphaltImageView
    }()
    
    private lazy var leftCurb = {
        let curb = UIView()
        curb.backgroundColor = .systemYellow
        return curb
    }()
    
    private lazy var rightCurb = {
        let curb = UIView()
        curb.backgroundColor = .systemYellow
        return curb
    }()
    
    private lazy var listOfCurbesObjects = [String]()
    
    private var bushesView = {
        let bush = UIImageView()
        return bush
    }()
    
    private lazy var parkingView = {
        let cars = UIImageView()
        return cars
    }()
    
    private lazy var listOfShadingViews = [UIView]()
    
    lazy var getSingleLineWidth = {
        return self.asphaltImageView.frame.width / 4
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewsAndConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViewsAndConstraints()
    }
    
    func setupSubviews() {
        setupShading()
        setupCurbs()
    }
    
    func getCurbsFrames() -> (CGRect, CGRect) {
        return (leftCurb.frame, rightCurb.frame)
    }
    
    private func setupViewsAndConstraints() {
        
        
        self.addSubview(leftCurb)
        
        leftCurb.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(5)
            make.width.equalTo(Constants.Game.spacingForCurbs)
        }
        
        self.addSubview(rightCurb)
        rightCurb.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(5)
            make.width.equalTo(Constants.Game.spacingForCurbs)
        }
        self.addSubview(asphaltImageView)
        
        asphaltImageView.snp.makeConstraints { make in
            make.left.equalTo(leftCurb.snp.right)
            make.right.equalTo(rightCurb.snp.left)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(5)
        }
        
        setupShadeViews()
        listOfCurbesObjects.append("Rock")
        listOfCurbesObjects.append("Bush")
        
    }
    
    private func setupShadeViews() {
        let shadesWidth = 5.0
        let spacingFactor: CGFloat = 0.5
        
        let centeredShadesView = UIView()
        asphaltImageView.addSubview(centeredShadesView)
        listOfShadingViews.append(centeredShadesView)
        
        centeredShadesView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.centerX.equalTo(asphaltImageView.snp.centerX)
            make.width.equalTo(shadesWidth)
        }
        
        let leftShadesView = UIView()
        asphaltImageView.addSubview(leftShadesView)
        listOfShadingViews.append(leftShadesView)
        
        leftShadesView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.centerX.equalTo(centeredShadesView.snp.centerX).multipliedBy(1 - spacingFactor)
            make.width.equalTo(shadesWidth)
        }
        
        let rightShadesView = UIView()
        asphaltImageView.addSubview(rightShadesView)
        listOfShadingViews.append(rightShadesView)
        
        rightShadesView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.centerX.equalTo(centeredShadesView.snp.centerX).multipliedBy(1 + spacingFactor)
            make.width.equalTo(shadesWidth)
        }
    }
    
    private func setupShading() {
        let totalRoadLength = self.frame.height
        let numberOfStripes: CGFloat = 10
        let stripesLength = totalRoadLength / (numberOfStripes * 1.5)
        listOfShadingViews.forEach { shadeView in
            
            for y in stride(from: stripesLength / 4, to: self.frame.height - stripesLength / 4,
                            by: 1.5 * stripesLength) {
                createShade(x: 0, y: y, shadesWidth: shadeView.frame.width, shadesHeight: stripesLength, superView: shadeView)
            }
        }
    }
    
    private func createShade(x: CGFloat, y: CGFloat, shadesWidth: CGFloat, shadesHeight: CGFloat, superView: UIView) {
        let newShade = UIView()
        newShade.backgroundColor = .white
        superView.addSubview(newShade)
        newShade.frame = CGRect(x: x, y: y, width: shadesWidth, height: shadesHeight)
        
    }
    
    private func setupCurbs() {
        let objectSide = 30.0
        
        for y in stride(from: objectSide * 2, to: self.bounds.height - objectSide * 2 , by: objectSide) {

            let leftObject = createCurbsObjects()
            let rightObject = createCurbsObjects()
            leftCurb.addSubview(leftObject)
            rightCurb.addSubview(rightObject)
            setRandomXPosition(to: leftObject,
                               maxX: leftCurb.frame.width + objectSide,
                               y: y,
                               width: objectSide,
                               height: objectSide)
            setRandomXPosition(to: rightObject,
                               maxX: rightCurb.frame.width + objectSide,
                               y: y,
                               width: objectSide,
                               height: objectSide)
        }
    }
    
    private func setRandomXPosition(to object: UIView, maxX: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let x = CGFloat.random(in: (0...maxX))
        object.frame = CGRect(x: x, y: y, width: width, height: height)
    }
    
    private func createCurbsObjects() -> UIImageView {
        if let name = listOfCurbesObjects.randomElement() {
            let object = UIImageView(image: UIImage(named: name))
            return object
        }
        //ИСПРАВИТЬ
        return UIImageView()
    }

}
