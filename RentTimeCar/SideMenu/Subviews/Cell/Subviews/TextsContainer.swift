//
//  TextsContainer.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 02.08.2025.
//

import UIKit

final class TextsContainer: UIView {
    // MARK: - UI
    
    private let title = Label(textAlignment: .left)
    private let subtitle = Label(fontSize: 10, textAlignment: .left)
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        autoSizeThatFits(size, layoutClosure: performLayout)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
    }
    
    // MARK: - Internal Methods
    
    func configure(title: String, subtitle: String?) {
        self.title.text = title
        self.subtitle.isHidden = subtitle == nil
        if let subtitle {
            self.subtitle.text = subtitle
        }
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        addSubviews([title, subtitle])
    }
    
    private func performLayout() {
        if !subtitle.isHidden {
            title.pin
                .top()
                .horizontally()
                .sizeToFit(.width)
        } else {
            title.pin
                .horizontally()
                .vCenter()
                .sizeToFit(.width)
        }
        
        if !subtitle.isHidden {
            subtitle.pin
                .below(of: title)
                .bottom()
                .left(to: title.edge.left)
                .right(to: title.edge.right)
                .sizeToFit(.width)
        }
    }
}
