//
//  SplashViewController.swift
//  RentTimeCar
//

import PinLayout
import UIKit

final class SplashViewController: UIViewController {

    // MARK: - UI

    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: - Private Properties

    private let onFinish: () -> Void

    // MARK: - Init

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainBackground
        view.addSubview(logoImageView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.onFinish()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logoImageView.pin
            .center()
            .size(CGSize(square: 160))
    }
}

