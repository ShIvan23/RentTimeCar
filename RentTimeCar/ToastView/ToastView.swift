//
//  ToastView.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 31.07.2025.
//

import UIKit

final class ToastView: UIView {
    
    private let textLabel = Label(
        text: "",
        textColor: .white
    )
    
    init(text: String) {
        super.init(frame: .zero)
        setupView(text: text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutToaster(in view: UIView) {
        let horizontalInset: CGFloat = 30
        let verticalTextInset: CGFloat = 8
        let maxToastWidth = view.bounds.width - horizontalInset * 2
        let textHorizontalInset: CGFloat = 8
        let textMaxSize = CGSize(
            width: maxToastWidth - textHorizontalInset * 2,
            height: view.bounds.height
        )
        let textSize = textLabel.sizeThatFits(textMaxSize)
        let toastHeight = textSize.height + verticalTextInset * 2
        frame = CGRect(
            x: horizontalInset,
            y: -toastHeight,
            width: maxToastWidth,
            height: toastHeight
        )
        textLabel.frame = CGRect(
            x: horizontalInset + textHorizontalInset,
            y: verticalTextInset,
            width: textSize.width,
            height: textSize.height
        )
    }
    
    func animateShowingToaster() {
        UIView.animate(withDuration: 0.5) {
            self.transform = CGAffineTransform(translationX: 0, y: 150)
        }
    }
    
    func animateDismissToaster(in view: UIView) {
        UIView.animate(withDuration: 0.5) {
            view.layoutIfNeeded()
            self.transform = .identity
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    private func setupView(text: String) {
        addSubview(textLabel)
        backgroundColor = .black
        layer.cornerRadius = 12
        layer.borderWidth = 3
        layer.borderColor = UIColor.white.cgColor
        textLabel.text = text
    }
}
