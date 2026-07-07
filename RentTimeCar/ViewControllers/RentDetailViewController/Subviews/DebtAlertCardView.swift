//
//  DebtAlertCardView.swift
//  RentTimeCar
//

import PinLayout
import UIKit

final class DebtAlertCardView: UIView {

    private let titleLabel = Label(fontSize: 17, weight: .bold, textColor: .systemRed, textAlignment: .natural)

    private let descriptionLabel: Label = {
        let l = Label(
            text: "По договору есть неоплаченные начисления. Оплатите, чтобы продолжить пользоваться сервисом RentTimeCar.",
            numberOfLines: 0,
            fontSize: 14,
            textColor: .whiteTextColor,
            textAlignment: .natural
        )
        return l
    }()

    var onPayTapped: (() -> Void)?

    private let payButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = .systemRed
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont.openSans(fontSize: 16, weight: .semibold)
        b.layer.cornerRadius = 12
        return b
    }()

    init(amount: String) {
        super.init(frame: .zero)
        backgroundColor = .secondaryBackground
        layer.cornerRadius = 12
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.systemRed.withAlphaComponent(0.5).cgColor

        titleLabel.text = "К оплате: \(amount)"
        payButton.setTitle("Оплатить \(amount)", for: .normal)

        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(payButton)

        payButton.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
    }

    func hidePayButton() {
        payButton.isHidden = true
    }

    @objc private func payTapped() {
        onPayTapped?()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        let hPad: CGFloat = 16
        let vPad: CGFloat = 16

        titleLabel.pin.top(vPad).horizontally(hPad).sizeToFit(.width)
        descriptionLabel.pin.below(of: titleLabel).marginTop(8).horizontally(hPad).sizeToFit(.width)

        let totalH: CGFloat
        if payButton.isHidden {
            totalH = descriptionLabel.frame.maxY + vPad
        } else {
            payButton.pin.below(of: descriptionLabel).marginTop(16).horizontally(hPad).height(50)
            totalH = payButton.frame.maxY + vPad
        }
        if frame.height != totalH { frame.size.height = totalH }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        frame = CGRect(origin: .zero, size: CGSize(width: size.width, height: 0))
        layoutSubviews()
        return CGSize(width: size.width, height: frame.height)
    }
}
