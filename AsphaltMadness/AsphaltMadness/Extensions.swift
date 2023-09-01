import UIKit

var listOfColors: [UIColor] = [.blue, .brown, .cyan, .green, .orange, .purple, .red, .yellow, .systemPink]

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
        self.backgroundColor = listOfColors.randomElement()
    }
}

extension UIViewController {
    //MARK: - Animations block
    
    func animateWay(backView: UIView, upperView: UIView, duration: Double) {
        UIView.animate(withDuration: duration, delay: .zero, options: .curveLinear) {
            backView.bounds.origin.y -= self.view.frame.height
            
        } completion: { _ in
            
            backView.bounds.origin.y = 0
            self.animateRoad(road: backView, duration: duration )
        }
        self.animateRoad(road: upperView, duration: duration)
    }
    
    func animateRoad(road: UIView, duration: Double) {
        UIView.animate(withDuration: duration * 2, delay: .zero, options: .curveLinear) {
            road.bounds.origin.y -= self.view.frame.height * 2
            
        } completion: { _ in
            
            road.bounds.origin.y = 0
            self.animateRoad(road: road, duration: duration )
        }
    }
    
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
    
    
}
