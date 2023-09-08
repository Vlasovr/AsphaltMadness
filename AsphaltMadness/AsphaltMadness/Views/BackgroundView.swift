import UIKit
import SnapKit

final class BackgroundView: UIView {
    
    private lazy var asphaltView = {
        let asphaltView = UIView()
        asphaltView.backgroundColor = .lightGray
        return asphaltView
    }()
    
    private lazy var leftCurb = {
        let curb = UIView()
        curb.backgroundColor = .white
        return curb
    }()
    
    private lazy var rightCurb = {
        let curb = UIView()
        curb.backgroundColor = .white
        return curb
    }()
    
    private lazy var listOfShadingViews = [UIView]()
    
    lazy var getSingleLineWidth = {
        return self.asphaltView.frame.width / 4
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
        self.addSubview(asphaltView)
        
        asphaltView.snp.makeConstraints { make in
            make.left.equalTo(leftCurb.snp.right)
            make.right.equalTo(rightCurb.snp.left)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(5)
        }
        
        setupShadeViews()
    }
    
    private func setupShadeViews() {
        let shadesWidth = 5.0
        let spacingFactor: CGFloat = 0.5
        
        let centeredShadesView = UIView()
        asphaltView.addSubview(centeredShadesView)
        listOfShadingViews.append(centeredShadesView)
        
        centeredShadesView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.centerX.equalTo(asphaltView.snp.centerX)
            make.width.equalTo(shadesWidth)
        }
        
        let leftShadesView = UIView()
        asphaltView.addSubview(leftShadesView)
        listOfShadingViews.append(leftShadesView)
        
        leftShadesView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.centerX.equalTo(centeredShadesView.snp.centerX).multipliedBy(1 - spacingFactor)
            make.width.equalTo(shadesWidth)
        }
        
        let rightShadesView = UIView()
        asphaltView.addSubview(rightShadesView)
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
        let objectSide = Constants.Game.curbsObjectsSide
        var isWhiteViewLeft = false
        var isWhiteViewRight = false
        
        for y in stride(from: -objectSide, to: self.frame.height - objectSide, by: objectSide) {
            let leftObject = createCurbsObjects(&isWhiteViewLeft)
            let rightObject = createCurbsObjects(&isWhiteViewRight)
            
            leftCurb.addSubview(leftObject)
            rightCurb.addSubview(rightObject)
            
            setRandomXPosition(to: leftObject,
                               x: leftCurb.frame.origin.x,
                               y: y,
                               width: objectSide,
                               height: objectSide)
            
            setRandomXPosition(to: rightObject,
                               x: rightCurb.frame.origin.x,
                               y: y,
                               width: objectSide,
                               height: objectSide)
        }
    }
    
    private func createCurbsObjects(_ isWhite: inout Bool) -> UIImageView {
        let object = UIImageView()
        if isWhite {
            object.backgroundColor = .red
        } else {
            object.backgroundColor = .white
        }
        isWhite.toggle()
        return object
    }
    
    private func setRandomXPosition(to object: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        object.frame = CGRect(x: x, y: y, width: width, height: height)
    }
}
