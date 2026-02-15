//
//  InfoViewContentView.swift
//  RentTimeCar
//
//  Created by Андрей Пермяков on 14.02.2026.
//

import UIKit
import PinLayout

final class InfoViewContentView: UIView {
    
    // MARK: - Private Properties
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainBackground
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.whiteTextColor.cgColor
        return view
    }()
    
    private let iconImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(resource: .info).withRenderingMode(.alwaysTemplate)
        image.tintColor = .whiteTextColor
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let infoLabel = Label (
        fontSize: 12
    )
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    // MARK: - Internal Methods
    func configure (text: String){
        infoLabel.text = text
        setNeedsLayout()
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        addSubview(contentView)
        contentView.addSubviews([iconImage, infoLabel])
    }
    
    private func layout() {
        contentView.pin
            .width(260)
        
            iconImage.pin
                .top(8)
                .hCenter()
                .size(16)
            
            infoLabel.pin
                .below(of: iconImage)
                .marginTop(8)
                .horizontally(8)
                .sizeToFit(.width)
        //высота контейнера подстраивается под высоту лейбла
        let dinamicHeight = infoLabel.frame.maxY + 8
        contentView.pin
            .height(dinamicHeight)
            .center()
    }
    

}
