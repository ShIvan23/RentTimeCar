//
//  InfoView.swift
//  RentTimeCar
//
//  Created by Андрей Пермяков on 13.02.2026.
//

import UIKit
import PinLayout

final class InfoView: UIView {
    
    // MARK: - Private properties
    private let dimmedBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()

    private let contentView = InfoViewContentView()

    // MARK: - Init
    init(text: String) {
        super.init(frame: .zero)
        setupViews()
        contentView.configure(text: text)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        dimmedBackground.pin.all()
        contentView.pin.center()
    }

    // MARK: - Internal Methods
    func show(in parentView: UIView) {
        frame = parentView.bounds
        alpha = 0
        parentView.addSubview(self)

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }

    func hide() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        backgroundColor = .clear
        addSubview(dimmedBackground)
        addSubview(contentView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        dimmedBackground.addGestureRecognizer(tapGesture)
    }

    @objc private func backgroundTapped() {
        hide()
    }
}
