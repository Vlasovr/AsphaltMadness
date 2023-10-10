import UIKit

//MARK: - Custom class for animated button

final class AdaptiveButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)
        configureButton()
        self.setTitle(title, for: .normal)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    private func configureButton() {
        self.backgroundColor = .systemBlue
        self.setTitleColor(.white, for: .normal)
        self.roundCorners()
        
        self.addTarget(self, action: #selector(touchDown), for: .touchDown)
        self.addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)

    }
    
    @objc func touchDown() {
        UIView.animate(withDuration: Constants.Settings.defaultSpeedAnimation,
                       delay: .zero,
                       options: [.allowUserInteraction, .beginFromCurrentState]) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: Constants.buttonsScaleFactor, 
                                                y: Constants.buttonsScaleFactor)
        }
    }
    
    @objc func touchUpInside() {
        UIView.animate(withDuration: Constants.Settings.defaultSpeedAnimation,
                       delay: .zero,
                       options: [.allowUserInteraction, .beginFromCurrentState]) { [weak self] in
            self?.transform = .identity
        }
    }

}
