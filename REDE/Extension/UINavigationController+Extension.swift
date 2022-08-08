//
//  UINavigationController+Extension.swift
//  REDE
//
//  Created by Avishek on 08/08/22.
//

import UIKit

extension UINavigationController {
  func popToViewController(ofClass: AnyClass, animated: Bool = true) {
    if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
      popToViewController(vc, animated: animated)
    }
  }
}
