import UIKit

extension UIView {
    
    func roundCorners(radius: CGFloat = Constants.radiusOfRoundCorner) {
        return self.layer.cornerRadius = radius
    }
    
    func dropShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = Constants.shadowOpasity
        layer.shadowOffset = CGSize(width: Constants.radiusOfRoundCorner,
                                    height: Constants.radiusOfRoundCorner)
        layer.shadowRadius = Constants.radiusOfRoundCorner
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
    
    func wobble(duration: CFTimeInterval = .infinity) {
        let animation = Constants.WobbleSettings.animationsFrame
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = Constants.WobbleSettings.duration
        animation.values = [Constants.WobbleSettings.firstValue,
                            Constants.WobbleSettings.secondValue,
                            Constants.WobbleSettings.thirdValue]
        animation.repeatDuration = duration
        layer.add(animation, forKey: Constants.WobbleSettings.key)
    }
    
    func randomiseColor() {
        self.backgroundColor = listOfColors.values.randomElement()
    }
}

extension UIViewController {

    func createCar(color: UIColor) -> UIView {
        let car = UIView()
        car.roundCorners()
        car.dropShadow()
        car.wobble()
        car.backgroundColor = color
        return car
    }
    
    //MARK: - Animations block
    func setupRoadFrames(mainView: BackgroundView, upperView: BackgroundView) {
        mainView.frame = CGRect(x: view.frame.origin.x,
                                y: view.frame.origin.y,
                                width: view.frame.width,
                                height: view.frame.height
        )
        
        mainView.setupSubviews()
        
        
        upperView.frame = CGRect(x: view.frame.origin.x,
                                 y: -view.frame.height,
                                 width: view.frame.width,
                                 height: view.frame.height
        )
        
        upperView.setupSubviews()
    }
    
    func animateRoad(backView: UIView, upperView: UIView, duration: Double) {
        guard duration > .zero else { return }
        
        let animationOptions: UIView.AnimationOptions = [.repeat, .curveLinear]
        let distanceToMove = backView.frame.size.height
        
        let animationDuration = Constants.Game.maxAnimationDuration - duration
        
        UIView.animate(withDuration: animationDuration, delay: .zero, options: animationOptions) {
            backView.frame.origin.y += distanceToMove
            upperView.frame.origin.y += distanceToMove
        }
    }
    
    //MARK: - Stop and continue the game animation
    func pauseLayer(layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = .zero
        layer.timeOffset = pausedTime
    }
    
    func resumeLayer(layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = .zero
        layer.beginTime = .zero
        let timeSincePause: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
    
    //MARK: - alert
    func showAlert(alertTitle: String? = nil,
                   messageTitle: String,
                   alertStyle: UIAlertController.Style,
                   firstButtonTitle: String,
                   secondButtonTitle: String? = nil,
                   firstAlertActionStyle: UIAlertAction.Style,
                   secondAlertActionStyle: UIAlertAction.Style? = nil,
                   firstHandler: (() -> Void)? = nil,
                   secondHandler: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: alertTitle,
                                      message: messageTitle,
                                      preferredStyle: alertStyle)
        
        let firstAlertActionButton = UIAlertAction(title: firstButtonTitle,
                                                   style: firstAlertActionStyle) { _ in
            firstHandler?()
        }
        
        alert.addAction(firstAlertActionButton)
        
        if let secondButtonTitle = secondButtonTitle,
           let secondAlertActionStyle = secondAlertActionStyle {
            let secondAlertActionButton = UIAlertAction(title: secondButtonTitle,
                                                        style: secondAlertActionStyle) { _ in
                secondHandler?()
            }
            
            alert.addAction(secondAlertActionButton)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func getDate() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.dataFormat
        return dateFormatter.string(from: currentDate)
    }
}

//MARK: - loading and saving custom classes in User Defauts
extension UserDefaults {
    
    func set<T: Encodable>(encodable: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(encodable) {
            set(data, forKey: key)
        }
    }
    
    func object<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        if let data = object(forKey: key) as? Data,
           let value = try? JSONDecoder().decode(type, from: data) {
            return value
        }
        return nil
    }
}

//MARK: Settings leaflet animations
extension SettingsVC {
    
    func slideOutAnimation(image: UIImage, replacingImageView oldImageView: UIImageView) {
        let newImageView = UIImageView(image: oldImageView.image)
        newImageView.frame = oldImageView.frame
        oldImageView.image = image
        view.addSubview(newImageView)
        
        UIView.animate(withDuration: Constants.Settings.defaultSpeedAnimation, 
                       delay: .zero,
                       options: .curveLinear) { [weak self] in
            newImageView.frame.origin.x -= self?.view.frame.width ?? .zero
        } completion: { _ in
            newImageView.removeFromSuperview()
        }
    }
    
    func slideInAnimation(image: UIImage, replacingImageView oldImageView: UIImageView) {
        let newImageView = UIImageView(image: image)
        
        newImageView.frame = CGRect(x: view.frame.width,
                                    y: oldImageView.frame.origin.y,
                                    width: oldImageView.frame.size.width,
                                    height: oldImageView.frame.size.height)
            
        view.addSubview(newImageView)
        
        UIView.animate(withDuration: Constants.Settings.slideInSpeedAnimation ,
                       delay: .zero,
                       options: .curveLinear) { [weak self] in
            newImageView.frame.origin.x = self?.view.frame.width ?? .zero - newImageView.frame.width
        }  completion: { _ in
            oldImageView.image = image
            newImageView.removeFromSuperview()
        }
    }
}
