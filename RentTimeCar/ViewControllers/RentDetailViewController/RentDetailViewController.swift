//
//  RentDetailViewController.swift
//  RentTimeCar
//

import Nuke
import NukeExtensions
import PinLayout
import UIKit

final class RentDetailViewController: UIViewController {

    // MARK: - Private Properties

    private let request: ClientRequest
    private let coordinator: ICoordinator
    private var isInfoTabSelected = true

    // MARK: - UI — Header card

    private let headerCardView: UIView = {
        let v = UIView()
        v.backgroundColor = .secondaryBackground
        v.layer.cornerRadius = 12
        return v
    }()

    private let carImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        iv.backgroundColor = .mainBackground
        return iv
    }()

    private let carNameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .whiteTextColor
        return l
    }()

    private let dateFromLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryTextColor
        return l
    }()

    private let dateToLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryTextColor
        return l
    }()

    // MARK: - UI — Status

    private let statusIconLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18)
        return l
    }()

    private let statusTextLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .medium)
        return l
    }()

    // MARK: - UI — Tabs

    private let infoTabButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Информация", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        b.layer.cornerRadius = 10
        return b
    }()

    private let paymentTabButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Расчеты", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        b.layer.cornerRadius = 10
        return b
    }()

    private let tabContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = .secondaryBackground
        v.layer.cornerRadius = 12
        return v
    }()

    // MARK: - UI — Info content

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let deliveryTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Доставка:"
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryTextColor
        return l
    }()

    private let deliveryAddressLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15)
        l.textColor = .whiteTextColor
        l.numberOfLines = 0
        return l
    }()

    private let separatorView: UIView = {
        let v = UIView()
        v.backgroundColor = .secondaryBackground
        return v
    }()

    private let territoryTileView = RentInfoTileView()
    private let mileageTileView = RentInfoTileView()

    private let actReturnButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Акт возврата", for: .normal)
        b.setTitleColor(.whiteTextColor, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15)
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.whiteTextColor
        ]
        b.setAttributedTitle(NSAttributedString(string: "Акт возврата", attributes: attributes), for: .normal)
        return b
    }()

    // MARK: - UI — Payment content (placeholder)

    private let paymentPlaceholderLabel: UILabel = {
        let l = UILabel()
        l.text = "Расчеты"
        l.font = .systemFont(ofSize: 15)
        l.textColor = .secondaryTextColor
        l.textAlignment = .center
        l.isHidden = true
        return l
    }()

    // MARK: - UI — Bottom button

    private let bottomContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = .secondaryBackground
        return v
    }()

    private let signButton = MainButton(title: "ПОДПИСАТЬ")

    // MARK: - Init

    init(request: ClientRequest, coordinator: ICoordinator) {
        self.request = request
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configure()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        performLayout()
    }

    // MARK: - Private Methods

    private func setupView() {
        view.backgroundColor = .mainBackground
        navigationController?.isNavigationBarHidden = false

        view.addSubviews([scrollView, bottomContainerView])
        bottomContainerView.addSubview(signButton)
        scrollView.addSubview(contentView)

        contentView.addSubviews([
            headerCardView,
            statusIconLabel,
            statusTextLabel,
            tabContainerView,
            deliveryTitleLabel,
            deliveryAddressLabel,
            separatorView,
            territoryTileView,
            mileageTileView,
            actReturnButton,
            paymentPlaceholderLabel
        ])
        headerCardView.addSubviews([carImageView, carNameLabel, dateFromLabel, dateToLabel])

        tabContainerView.addSubviews([infoTabButton, paymentTabButton])

        infoTabButton.addTarget(self, action: #selector(infoTabTapped), for: .touchUpInside)
        paymentTabButton.addTarget(self, action: #selector(paymentTabTapped), for: .touchUpInside)

        updateTabSelection()
    }

    private func configure() {
        let info = request.rentInfo
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm, dd.MM.yy"

        carNameLabel.text = info?.autoTitle ?? request.service
        dateFromLabel.text = info?.dateFrom.map { "От: \(formatter.string(from: $0))" } ?? "От: —"
        dateToLabel.text = info?.dateTo.map { "До: \(formatter.string(from: $0))" } ?? "До: —"

        configureStatus()
        configureInfoContent(info: info)
        loadCarImage(autoId: info?.autoId)
    }

    private func configureStatus() {
        let step = request.currentStep
        let cancelledSteps = ["Отмена", "Отклонено"]
        let completedSteps = ["Завершена", "Завершён", "Закрыт"]

        if completedSteps.contains(where: { step.localizedCaseInsensitiveContains($0) }) {
            statusIconLabel.text = "✓"
            statusTextLabel.text = "Аренда завершена"
            let color = UIColor(red: 0.3, green: 0.65, blue: 0.35, alpha: 1)
            statusIconLabel.textColor = color
            statusTextLabel.textColor = color
        } else if cancelledSteps.contains(where: { step.localizedCaseInsensitiveContains($0) }) {
            statusIconLabel.text = "✕"
            statusTextLabel.text = "Аренда отменена"
            let color = UIColor(red: 0.85, green: 0.25, blue: 0.25, alpha: 1)
            statusIconLabel.textColor = color
            statusTextLabel.textColor = color
        } else {
            statusIconLabel.text = "◉"
            statusTextLabel.text = step.isEmpty ? "В процессе" : step
            statusIconLabel.textColor = .enabledMainButtonBorderColor
            statusTextLabel.textColor = .enabledMainButtonBorderColor
        }
    }

    private func configureInfoContent(info: ClientRentInfo?) {
        deliveryAddressLabel.text = info?.deliveryAddress ?? "Адрес уточняется"

        let auto = info?.autoId.flatMap { id in
            FilterService.shared.allAutos.first { $0.itemID == id }
        }
        let mileageText = auto.map { "\($0.mileageLimit) км" } ?? "—"
        let territoryText = info?.territory ?? "—"

        territoryTileView.configure(title: "Территория аренды", value: territoryText)
        mileageTileView.configure(title: "Лимит пробега", value: mileageText)
    }

    private func loadCarImage(autoId: Int?) {
        carImageView.image = .carPlaceholder
        guard let autoId else { return }
        let auto = FilterService.shared.allAutos.first { $0.itemID == autoId }
        guard let urlString = auto?.files.first(where: { $0.url != nil && $0.folder == .folderImageValue })?.url,
              let url = URL(string: urlString) else { return }
        let options = ImageLoadingOptions(placeholder: .carPlaceholder, transition: .fadeIn(duration: 0.3))
        NukeExtensions.loadImage(with: url, options: options, into: carImageView)
    }

    private func updateTabSelection() {
        if isInfoTabSelected {
            infoTabButton.backgroundColor = .mainBackground
            infoTabButton.setTitleColor(.whiteTextColor, for: .normal)
            paymentTabButton.backgroundColor = .clear
            paymentTabButton.setTitleColor(.secondaryTextColor, for: .normal)
        } else {
            paymentTabButton.backgroundColor = .mainBackground
            paymentTabButton.setTitleColor(.whiteTextColor, for: .normal)
            infoTabButton.backgroundColor = .clear
            infoTabButton.setTitleColor(.secondaryTextColor, for: .normal)
        }
        deliveryTitleLabel.isHidden = !isInfoTabSelected
        deliveryAddressLabel.isHidden = !isInfoTabSelected
        separatorView.isHidden = !isInfoTabSelected
        territoryTileView.isHidden = !isInfoTabSelected
        mileageTileView.isHidden = !isInfoTabSelected
        actReturnButton.isHidden = !isInfoTabSelected
        paymentPlaceholderLabel.isHidden = isInfoTabSelected
        view.setNeedsLayout()
    }

    // MARK: - Actions

    @objc private func infoTabTapped() {
        guard !isInfoTabSelected else { return }
        isInfoTabSelected = true
        updateTabSelection()
    }

    @objc private func paymentTabTapped() {
        guard isInfoTabSelected else { return }
        isInfoTabSelected = false
        updateTabSelection()
    }

    // MARK: - Layout

    private func performLayout() {
        let hInset: CGFloat = 16

        bottomContainerView.pin
            .bottom()
            .horizontally()
            .height(view.safeAreaInsets.bottom + 50 + 16)

        signButton.pin
            .top(8)
            .horizontally(hInset)
            .height(50)

        scrollView.pin
            .top(view.pin.safeArea)
            .horizontally()
            .above(of: bottomContainerView)

        contentView.pin.top().horizontally()

        // Header card
        let cardHeight: CGFloat = 120
        headerCardView.pin
            .top(16)
            .horizontally(hInset)
            .height(cardHeight)

        carImageView.pin
            .left()
            .top()
            .bottom()
            .width(140)

        let labelLeft: CGFloat = 152
        let labelRight: CGFloat = 12
        carNameLabel.pin
            .top(16)
            .left(labelLeft)
            .right(labelRight)
            .sizeToFit(.width)

        dateFromLabel.pin
            .below(of: carNameLabel)
            .marginTop(10)
            .left(labelLeft)
            .right(labelRight)
            .sizeToFit(.width)

        dateToLabel.pin
            .below(of: dateFromLabel)
            .marginTop(4)
            .left(labelLeft)
            .right(labelRight)
            .sizeToFit(.width)

        // Status
        statusIconLabel.pin
            .below(of: headerCardView)
            .marginTop(20)
            .sizeToFit()

        statusTextLabel.pin
            .after(of: statusIconLabel, aligned: .center)
            .marginLeft(8)
            .sizeToFit()

        let statusWidth = statusIconLabel.frame.width + 8 + statusTextLabel.frame.width
        let statusX = (scrollView.bounds.width - statusWidth) / 2
        statusIconLabel.pin.left(statusX)
        statusTextLabel.pin.left(statusX + statusIconLabel.frame.width + 8)

        // Tab switcher
        let tabHeight: CGFloat = 44
        tabContainerView.pin
            .below(of: statusTextLabel)
            .marginTop(20)
            .horizontally(hInset)
            .height(tabHeight)

        let tabWidth = (tabContainerView.bounds.width - 8) / 2
        infoTabButton.pin
            .left(4)
            .vCenter()
            .height(tabHeight - 8)
            .width(tabWidth)

        paymentTabButton.pin
            .right(4)
            .vCenter()
            .height(tabHeight - 8)
            .width(tabWidth)

        // Info content
        if isInfoTabSelected {
            deliveryTitleLabel.pin
                .below(of: tabContainerView)
                .marginTop(20)
                .left(hInset)
                .right(hInset)
                .sizeToFit(.width)

            deliveryAddressLabel.pin
                .below(of: deliveryTitleLabel)
                .marginTop(4)
                .left(hInset)
                .right(hInset)
                .sizeToFit(.width)

            separatorView.pin
                .below(of: deliveryAddressLabel)
                .marginTop(16)
                .horizontally(hInset)
                .height(1)

            let tileWidth = (scrollView.bounds.width - hInset * 2 - 8) / 2
            let tileHeight: CGFloat = 80

            territoryTileView.pin
                .below(of: separatorView)
                .marginTop(16)
                .left(hInset)
                .width(tileWidth)
                .height(tileHeight)

            mileageTileView.pin
                .below(of: separatorView)
                .marginTop(16)
                .right(hInset)
                .width(tileWidth)
                .height(tileHeight)

            actReturnButton.pin
                .below(of: territoryTileView)
                .marginTop(16)
                .left(hInset)
                .sizeToFit()

            contentView.pin.wrapContent(.vertically, padding: PEdgeInsets(top: 0, left: 0, bottom: 24, right: 0))
        } else {
            paymentPlaceholderLabel.pin
                .below(of: tabContainerView)
                .marginTop(40)
                .horizontally(hInset)
                .sizeToFit(.width)

            contentView.pin.wrapContent(.vertically, padding: PEdgeInsets(top: 0, left: 0, bottom: 24, right: 0))
        }

        scrollView.contentSize = contentView.frame.size
    }
}

