import UIKit

extension UIView {
    
    func roundCorners(radius: CGFloat = 10) {
        return self.layer.cornerRadius = radius
    }
    
    func dropShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.7
        layer.shadowOffset = CGSize(width: 10, height: 10)
        layer.shadowRadius = 9
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
    
    func wobble(duration: CFTimeInterval = .infinity) {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.2
        animation.values = [0.015, 0.02, 0]
        animation.repeatDuration = duration
        layer.add(animation, forKey: "wobble")
    }
    
    func layerremoveAllAnimations() {
        layer.removeAllAnimations()
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
                                height: view.frame.height)
        
        mainView.setupSubviews()
        
        
        upperView.frame = CGRect(x: view.frame.origin.x,
                                 y: -view.frame.height,
                                 width: view.frame.width,
                                 height: view.frame.height
        )
        
        upperView.setupSubviews()
        
    }
    
    func animateRoad(backView: UIView, upperView: UIView, duration: Double) {
        guard duration > 0 else { return }
        
        let animationOptions: UIView.AnimationOptions = [.repeat, .curveLinear]
        let distanceToMove = backView.frame.size.height
        
        let animationDuration = Constants.Game.maxAnimationDuration - duration
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions) {
            backView.frame.origin.y += distanceToMove
            upperView.frame.origin.y += distanceToMove
        }
    }
    
    //MARK: - Stop and continue the game animation
    func pauseLayer(layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }
    
    func resumeLayer(layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
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
}

//MARK: - loading and saving custom classes in User Defauts

extension UserDefaults {
    
    func set<T: Encodable>(encodable: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(encodable) {
            set(data, forKey: key)
            print("object loaded")
        }
    }
    
    func object<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        if let data = object(forKey: key) as? Data,
           let value = try? JSONDecoder().decode(type, from: data) {
            return value
            print("object read")
        }
        return nil
    }
}

