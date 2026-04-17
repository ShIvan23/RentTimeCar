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

    private let rentApiFacade: IRentApiFacade
    private let onFinish: (Result<[Auto], Error>) -> Void
    private var fetchResult: Result<[Auto], Error>?
    private var dataReady = false
    private var timerFired = false

    // MARK: - Init

    init(rentApiFacade: IRentApiFacade, onFinish: @escaping (Result<[Auto], Error>) -> Void) {
        self.rentApiFacade = rentApiFacade
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
        ContactsService.shared.prefetch()
        startPreload()
        startTimer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logoImageView.pin
            .center()
            .size(CGSize(square: 160))
    }

    // MARK: - Private Methods

    private func startPreload() {
        rentApiFacade.getAutos { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let model):
                    self.fetchResult = .success(model.result ?? [])
                case .failure(let error):
                    self.fetchResult = .failure(error)
                }
                self.dataReady = true
                self.tryFinish()
            }
        }
    }

    private func startTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }
            self.timerFired = true
            self.tryFinish()
        }
    }

    private func tryFinish() {
        guard timerFired, dataReady, let result = fetchResult else { return }
        onFinish(result)
    }
}
