//
//  SecondaryButton.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 08.01.2026.
//

import UIKit

final class SecondaryButton: UIButton {
    var action: (() -> Void)?

    init(title: String = "") {
        super.init(frame: .zero)
        setupButton(title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupButton(title: String) {
        setTitle(title, for: .normal)
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.whiteTextColor.cgColor
        backgroundColor = .black
        tintColor = .whiteTextColor
        titleLabel?.font = UIFont.openSans(fontSize: 18)
        addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }

    @objc
    private func buttonAction() {
        action?()
    }
}
