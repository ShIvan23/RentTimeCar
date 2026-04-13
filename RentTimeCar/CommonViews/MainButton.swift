//
//  MainButton.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 29.07.2025.
//

import UIKit

final class MainButton: UIButton {
    //MARK: - Internal Properties

    var action: (() -> Void)?

    // MARK: - Private Properties

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .whiteTextColor
        indicator.hidesWhenStopped = true
        addSubview(indicator)
        return indicator
    }()

    // MARK: - Init

    init(title: String = "") {
        super.init(frame: .zero)
        setupButton(title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override

    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }

    // MARK: - Internal Methods

    func enable() {
        isEnabled = true
        layer.borderColor = UIColor.enabledMainButtonBorderColor.cgColor
    }

    func disable() {
        isEnabled = false
        layer.borderColor = UIColor.disabledMainButtonBorderColor.cgColor
    }

    func setLoading(_ loading: Bool) {
        isUserInteractionEnabled = !loading
        if loading {
            activityIndicator.startAnimating()
            setTitle(nil, for: .normal)
        } else {
            activityIndicator.stopAnimating()
        }
    }

    // MARK: - Private Methods

    private func setupButton(title: String) {
        setTitle(title, for: .normal)
        layer.cornerRadius = 12
        layer.borderWidth = 4
        layer.borderColor = UIColor.enabledMainButtonBorderColor.cgColor
        backgroundColor = .black
        setTitleColor(.whiteTextColor, for: .normal)
        setTitleColor(.lightGray, for: .disabled)
        titleLabel?.font = UIFont.openSans(fontSize: 18)
        addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    @objc
    private func buttonAction() {
        action?()
    }
}
