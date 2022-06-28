import Foundation
import UIKit

final class NavigationBar: UIView {

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
}
