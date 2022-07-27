import Foundation
import UIKit

final class NavigationBar: UIView {

    @IBOutlet private weak var rightButton: UIButton!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!

    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var isLeftButtonHidden: Bool {
        set {
            leftButton.isHidden = newValue
        }
        get {
            return leftButton.isHidden
        }
    }

    func setOnClickLeftButton(completion: @escaping () -> Void){
        self.leftButton.actionHandler(controlEvents: .touchUpInside, forAction: completion)
    }
    
    var isRightButtonHidden: Bool {
        set {
            rightButton.isHidden = newValue
        }
        get {
            return rightButton.isHidden
        }
    }

    func setOnClickRightButton(completion: @escaping () -> Void){
        self.rightButton.actionHandler(controlEvents: .touchUpInside, forAction: completion)
    }
}
