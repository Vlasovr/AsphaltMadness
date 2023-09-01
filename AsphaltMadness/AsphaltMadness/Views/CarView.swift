import UIKit

final class CarView {
    var position: CGPoint
    var side: CGFloat
    var isCrashed: Bool
    var isLightsOn: Bool
    var color: UIColor

    init(position: CGPoint, side: CGFloat, isCrashed: Bool = false, isLightsOn: Bool = false, color: UIColor) {
        self.position = position
        self.side = side
        self.isCrashed = isCrashed
        self.isLightsOn = isLightsOn

        self.color = color
    }

    func updatePosition(newPosition: CGPoint) {
        position = newPosition
    }

    func crash() {
        isCrashed = true
    }

    func toggleLights() {
        isLightsOn = !isLightsOn
    }
}
