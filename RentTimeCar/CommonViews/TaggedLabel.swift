//
//  TaggedLabel.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 31.07.2025.
//

import UIKit

protocol TaggedLabelDelegate: AnyObject {
    func personalDataDidTapped()
    func privacyPolicyDidTapper()
}

final class TaggedLabel: UILabel {
    // MARK: - Internal Properties
    
    weak var delegate: TaggedLabelDelegate?
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        if size == .zero {
            return intrinsicContentSize
        }
        let rect = textRect(
            forBounds: CGRect(
                origin: .zero,
                size: size
            ),
            limitedToNumberOfLines: numberOfLines
        )
        return rect.size
    }
    
    // MARK: - Private Methods
    
    private func setupLabel() {
        let formattedText = String.format(
            strings: [.second, .fourth, .sixth],
            inString: .allText,
            font: UIFont.openSans(fontSize: 14)!,
            color: .white
        )
        attributedText = formattedText
        textAlignment = .center
        numberOfLines = 0
        lineBreakMode = .byWordWrapping
        isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func tapAction(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let text = (gestureRecognizer.view as? UILabel)?.text else { return }
        let nsString = text as NSString
        let secondRange = nsString.range(of: .second)
        let fourthRange = nsString.range(of: .fourth)
        let sixthRange = nsString.range(of: .sixth)
        let tapLocation = gestureRecognizer.location(in: self)
        let index = indexOfAttributedTextCharacterAtPoint(point: tapLocation)
        if checkRange(secondRange, contain: index) {
            print("+++", String.second)
        }
        if checkRange(fourthRange, contain: index) {
            print("+++", String.fourth)
            delegate?.privacyPolicyDidTapper()
        }
        if checkRange(sixthRange, contain: index) {
            print("+++", String.sixth)
            delegate?.personalDataDidTapped()
        }
    }
    
    private func checkRange(_ range: NSRange, contain index: Int) -> Bool {
        return index > range.location && index < range.location + range.length
    }
    
    private func indexOfAttributedTextCharacterAtPoint(point: CGPoint) -> Int {
        assert(self.attributedText != nil, "This method is developed for attributed string")
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: self.frame.size)
        textContainer.lineFragmentPadding = 5.0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        layoutManager.addTextContainer(textContainer)

        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }
}

private extension String {
    static let first = "Нажимая кнопку \"Получить код\", вы принимаете условия "
    static let second = "Пользовательского соглашения"
    static let third = ", подтверждаете свое ознакомление с "
    static let fourth = "Политикой ĸонфиденциальности"
    static let fifth = " и даете "
    static let sixth = "Согласие на обработку персональных данных"
    
    static let allText = first + second + third + fourth + fifth + sixth
}
