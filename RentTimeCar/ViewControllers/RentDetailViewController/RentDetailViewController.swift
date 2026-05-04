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

    private let contract: ContractDto
    private let coordinator: ICoordinator
    private let rentApiFacade: IRentApiFacade
    private var isInfoTabSelected = true
    private var hasLoadedPayments = false

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

    // MARK: - UI — Payment content

    private let paymentLoadingIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.color = .secondaryTextColor
        ai.hidesWhenStopped = true
        return ai
    }()

    private let paymentErrorLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryTextColor
        l.textAlignment = .center
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }()

    private let paymentContainerView: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()
    private var paymentContentViews: [UIView] = []

    // MARK: - UI — Bottom button

    private let bottomContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = .secondaryBackground
        return v
    }()

    private let signButton = MainButton(title: "ПОДПИСАТЬ")

    // MARK: - Init

    init(contract: ContractDto, coordinator: ICoordinator, rentApiFacade: IRentApiFacade) {
        self.contract = contract
        self.coordinator = coordinator
        self.rentApiFacade = rentApiFacade
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
            paymentLoadingIndicator,
            paymentErrorLabel,
            paymentContainerView
        ])
        headerCardView.addSubviews([carImageView, carNameLabel, dateFromLabel, dateToLabel])

        tabContainerView.addSubviews([infoTabButton, paymentTabButton])

        infoTabButton.addTarget(self, action: #selector(infoTabTapped), for: .touchUpInside)
        paymentTabButton.addTarget(self, action: #selector(paymentTabTapped), for: .touchUpInside)
        actReturnButton.addTarget(self, action: #selector(actReturnTapped), for: .touchUpInside)

        updateTabSelection()
    }

    private func configure() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm, dd.MM.yy"

        carNameLabel.text = contract.carTitle ?? contract.vehicle ?? "Автомобиль"
        dateFromLabel.text = "От: \(formatter.string(from: contract.dateFrom))"
        dateToLabel.text = "До: \(formatter.string(from: contract.dateTo))"

        configureStatus()
        configureInfoContent()
        loadCarImage(vehicleId: Int(contract.vehicleId))
    }

    private func configureStatus() {
        statusIconLabel.text = "◉"
        statusTextLabel.text = contract.statusTitle

        let color: UIColor
        switch contract.contractState {
        case .opened, .extended, .extendedOpened, .realisation:
            color = .systemGreen
        case .closed, .extendedClosed, .komissionClose, .sold, .archivedDogovor:
            color = .secondaryTextColor
        case .terminated, .defolt, .komissionCanceled:
            color = .systemRed
        case .readyToSign, .reserved:
            color = .systemOrange
        default:
            color = .enabledMainButtonBorderColor
        }
        statusIconLabel.textColor = color
        statusTextLabel.textColor = color
    }

    private func configureInfoContent() {
        let address = contract.deliveryAddress?.displayAddress
        deliveryAddressLabel.text = (address?.isEmpty == false) ? address : "Адрес уточняется"

        let vehicleId = Int(contract.vehicleId)
        let auto = FilterService.shared.allAutos.first { $0.itemID == vehicleId }
        let mileageText = auto.map { "\($0.mileageLimit) км" } ?? "—"

        territoryTileView.configure(title: "Территория аренды", value: contract.allowedLocation ?? "—")
        mileageTileView.configure(title: "Лимит пробега", value: mileageText)
    }

    private func loadCarImage(vehicleId: Int) {
        carImageView.image = .carPlaceholder
        let auto = FilterService.shared.allAutos.first { $0.itemID == vehicleId }
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
        let showPaymentContent = !isInfoTabSelected
        paymentLoadingIndicator.isHidden = !showPaymentContent || !paymentLoadingIndicator.isAnimating
        paymentErrorLabel.isHidden = !showPaymentContent || paymentErrorLabel.text == nil
        paymentContainerView.isHidden = !showPaymentContent || paymentContentViews.isEmpty
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
        if !hasLoadedPayments {
            fetchMoneyInfo()
        }
    }

    private func fetchMoneyInfo() {
        guard let integrationId = AuthService.shared.client?.integrationId else { return }
        paymentLoadingIndicator.startAnimating()
        paymentLoadingIndicator.isHidden = false
        paymentErrorLabel.isHidden = true
        paymentContainerView.isHidden = true
        view.setNeedsLayout()

        rentApiFacade.getContractMoneyInfo(
            clientIntegrationId: integrationId,
            objectId: contract.id
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.hasLoadedPayments = true
                self.paymentLoadingIndicator.stopAnimating()
                switch result {
                case let .success(response):
                    if let info = response.result {
                        self.configurePaymentContent(info)
                    } else {
                        self.paymentErrorLabel.text = "Нет данных"
                        self.paymentErrorLabel.isHidden = false
                    }
                case .failure:
                    self.paymentErrorLabel.text = "Не удалось загрузить данные"
                    self.paymentErrorLabel.isHidden = false
                }
                self.view.setNeedsLayout()
            }
        }
    }

    private func configurePaymentContent(_ info: ContractMoneyInfoResponse) {
        paymentContentViews.forEach { $0.removeFromSuperview() }
        paymentContentViews = []

        let fmt = moneyFormatter()

        let summaryRows: [PaymentSummaryCardView.Row] = [
            .init(title: "Итого начислено", value: fmt(info.moneyInfo.servicesTotalSum), highlighted: false),
            .init(title: "Оплачено", value: fmt(info.moneyInfo.servicesTotalPaydPaysSum), highlighted: false),
            info.moneyInfo.finesBalance != 0
                ? .init(title: "Баланс штрафов", value: fmt(info.moneyInfo.finesBalance), highlighted: true)
                : nil,
            .init(title: "Депозит", value: fmt(info.moneyInfo.depositBalance), highlighted: false)
        ].compactMap { $0 }
        paymentContentViews.append(PaymentSummaryCardView(rows: summaryRows))

        if !info.operations.isEmpty {
            let opsLabel = UILabel()
            opsLabel.text = "Операции"
            opsLabel.font = .systemFont(ofSize: 16, weight: .semibold)
            opsLabel.textColor = .whiteTextColor
            paymentContentViews.append(opsLabel)
            info.operations.forEach { paymentContentViews.append(OperationCardView(operation: $0)) }
        }

        paymentContentViews.forEach { paymentContainerView.addSubview($0) }
        paymentContainerView.isHidden = false
        view.setNeedsLayout()
    }

    private func moneyFormatter() -> (Decimal) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.groupingSeparator = "\u{202F}"
        fmt.maximumFractionDigits = 2
        fmt.minimumFractionDigits = 0
        return { decimal in
            let str = fmt.string(from: decimal as NSDecimalNumber) ?? "0"
            return "\(str) ₽"
        }
    }

    @objc private func actReturnTapped() {
        guard let integrationId = AuthService.shared.client?.integrationId else { return }
        rentApiFacade.getActInfo(
            clientIntegrationId: integrationId,
            objectId: contract.id,
            objectDescriptorLong: 1
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(response):
                    print("ActInfo response: \(response)")
                case let .failure(error):
                    print("ActInfo error: \(error)")
                }
            }
        }
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
            if paymentLoadingIndicator.isAnimating {
                paymentLoadingIndicator.pin
                    .below(of: tabContainerView)
                    .marginTop(40)
                    .hCenter()
                    .sizeToFit()
            }

            if !paymentErrorLabel.isHidden {
                paymentErrorLabel.pin
                    .below(of: tabContainerView)
                    .marginTop(40)
                    .horizontally(hInset)
                    .sizeToFit(.width)
            }

            if !paymentContainerView.isHidden {
                paymentContainerView.pin
                    .below(of: tabContainerView)
                    .marginTop(16)
                    .horizontally(hInset)

                let cardWidth = paymentContainerView.bounds.width
                var yOffset: CGFloat = 0
                for view in paymentContentViews {
                    let h = view.sizeThatFits(CGSize(width: cardWidth, height: .infinity)).height
                    view.pin.top(yOffset).horizontally().height(h)
                    yOffset += h + 12
                }
                paymentContainerView.pin.height(max(yOffset - 12, 0))
            }

            contentView.pin.wrapContent(.vertically, padding: PEdgeInsets(top: 0, left: 0, bottom: 24, right: 0))
        }

        scrollView.contentSize = contentView.frame.size
    }
}

