//
//  FullImageViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 26.10.2025.
//

import PinLayout
import UIKit

final class FullImageViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let image: String
    
    // MARK: - UI
    
    private let scrollView = ImageScrollView()
    private lazy var backButton: UIButton = {
        $0.setImage(.redCross, for: .normal)
        $0.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        return $0
    }(UIButton())
    
    // MARK: - Init
    
    init(image: String) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        scrollView.set(image: image)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        performLayout()
    }
    
    // MARK: - Private Methods
    
    private func performLayout() {
        backButton.pin
            .top()
            .right()
            .marginTop(view.layoutMargins.top)
            .marginRight(15)
            .size(CGSize(square: 32))
        
        scrollView.frame = view.bounds
    }
    
    private func setupView() {
        [scrollView, backButton].forEach { view.addSubview($0) }
        view.backgroundColor = .black
    }
    
    @objc private func backButtonAction() {
        dismiss(animated: true)
    }
}

