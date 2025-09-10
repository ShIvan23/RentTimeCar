//
//  UIViewController+Extension.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 31.07.2025.
//

import UIKit

extension UIViewController {
    var contentHeight: CGFloat {
        view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom
    }
}
