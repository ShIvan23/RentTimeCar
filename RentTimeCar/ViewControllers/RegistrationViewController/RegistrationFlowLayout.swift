//
//  RegistrationFlowLayout.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 28.02.2026.
//

import UIKit

final class RegistrationFlowLayout: UICollectionViewFlowLayout {

    // MARK: - Private Properties

    private let registrationModelBox: RegistrationModelBox

    // MARK: - Init

    init(registrationModelBox: RegistrationModelBox) {
        self.registrationModelBox = registrationModelBox
        super.init()
        initialSetup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)?
            .compactMap { $0.copy() as? UICollectionViewLayoutAttributes }
        guard let attributes else { return nil }
        let newAttributes = attributes.map { change(attribute: $0) }

        return newAttributes
    }

    // MARK: - Private Methods

    private func initialSetup() {
        minimumLineSpacing = 8
        sectionInset = UIEdgeInsets(vertical: .margin)
    }

    private func change(attribute: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let collectionViewWidth = collectionView?.bounds.width ?? .zero
        let xPosition: CGFloat = switch registrationModelBox.items[attribute.indexPath.item] {
        case .text:
                .margin
        case .image:
            collectionViewWidth - attribute.frame.width - .margin
        }
        attribute.frame = CGRect(
            x: xPosition,
            y: attribute.frame.minY,
            width: attribute.frame.width,
            height: attribute.frame.height
        )
        return attribute
    }
}

private extension CGFloat {
    static let margin: CGFloat = 16
}
