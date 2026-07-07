//
//  RentDetailViewController.swift
//  RentTimeCar
//

import Nuke
import NukeExtensions
import PinLayout
import UIKit

final class RentDetailViewController: UIViewController, ToastViewShowable {
    var showingToast: ToastView?

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

    private static func makeActLinkButton(title: String) -> UIButton {
        let b = UIButton(type: .system)
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.whiteTextColor,
            .font: UIFont.systemFont(ofSize: 15)
        ]
        b.setAttributedTitle(NSAttributedString(string: title, attributes: attributes), for: .normal)
        return b
    }

    private lazy var actAcceptanceButton = Self.makeActLinkButton(title: "Акт приёмки")
    private lazy var actReturnButton = Self.makeActLinkButton(title: "Акт возврата")

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

    // MARK: - UI — Loading overlay

    private let loadingOverlayView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        v.isHidden = true
        return v
    }()

    private let overlaySpinner: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        return ai
    }()

    // MARK: - UI — Sign buttons

    private let signAcceptanceButton = MainButton(title: "Подписать")
    private let signReturnButton = MainButton(title: "Подписать")
    private let actRetryButton = MainButton(title: "Загрузить акты")

    // MARK: - Act state

    private enum SignState { case hidden, needsSign, signed, notSigned }
    private var acceptanceSignState: SignState = .hidden
    private var returnSignState: SignState = .hidden
    private var acceptanceActData: Data?
    private var returnActData: Data?
    private var actBlockLoaded = false
    private var actBlockError = false

    private let actAcceptanceShimmerView: ShimmerView = {
        let v = ShimmerView()
        v.layer.cornerRadius = 4
        v.layer.masksToBounds = true
        return v
    }()

    private let actReturnShimmerView: ShimmerView = {
        let v = ShimmerView()
        v.layer.cornerRadius = 4
        v.layer.masksToBounds = true
        return v
    }()

    private let actAcceptanceSignShimmerView: ShimmerView = {
        let v = ShimmerView()
        v.layer.cornerRadius = 8
        v.layer.masksToBounds = true
        return v
    }()

    private let actReturnSignShimmerView: ShimmerView = {
        let v = ShimmerView()
        v.layer.cornerRadius = 8
        v.layer.masksToBounds = true
        return v
    }()

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

        view.addSubviews([scrollView, loadingOverlayView])
        loadingOverlayView.addSubview(overlaySpinner)
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
            actAcceptanceShimmerView,
            actReturnShimmerView,
            actAcceptanceSignShimmerView,
            actReturnSignShimmerView,
            actAcceptanceButton,
            actReturnButton,
            signAcceptanceButton,
            signReturnButton,
            actRetryButton,
            paymentLoadingIndicator,
            paymentErrorLabel,
            paymentContainerView
        ])
        actAcceptanceShimmerView.startAnimating()
        actReturnShimmerView.startAnimating()
        actAcceptanceSignShimmerView.startAnimating()
        actReturnSignShimmerView.startAnimating()
        headerCardView.addSubviews([carImageView, carNameLabel, dateFromLabel, dateToLabel])

        tabContainerView.addSubviews([infoTabButton, paymentTabButton])

        infoTabButton.addTarget(self, action: #selector(infoTabTapped), for: .touchUpInside)
        paymentTabButton.addTarget(self, action: #selector(paymentTabTapped), for: .touchUpInside)
        paymentTabButton.isHidden = FeatureFlagService.shared.hidePayments
        actAcceptanceButton.addTarget(self, action: #selector(actAcceptanceTapped), for: .touchUpInside)
        actReturnButton.addTarget(self, action: #selector(actReturnTapped), for: .touchUpInside)
        signAcceptanceButton.action = { [weak self] in self?.signButtonTapped(objectDescriptorLong: 1) }
        signReturnButton.action = { [weak self] in self?.signButtonTapped(objectDescriptorLong: 2) }
        actRetryButton.action = { [weak self] in self?.fetchActBlock() }

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
        fetchActBlock()
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
        let days = max(Calendar.current.dateComponents([.day], from: contract.dateFrom, to: contract.dateTo).day ?? 1, 1)
        let mileageText = auto.map { "\($0.mileageLimit * days) км" } ?? "—"

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
        let actLoading = !actBlockLoaded
        let actError = actBlockLoaded && actBlockError
        actAcceptanceShimmerView.isHidden = !isInfoTabSelected || !actLoading
        actReturnShimmerView.isHidden = !isInfoTabSelected || !actLoading
        actAcceptanceSignShimmerView.isHidden = !isInfoTabSelected || !actLoading
        actReturnSignShimmerView.isHidden = !isInfoTabSelected || !actLoading
        if actBlockLoaded {
            actAcceptanceShimmerView.stopAnimating()
            actReturnShimmerView.stopAnimating()
            actAcceptanceSignShimmerView.stopAnimating()
            actReturnSignShimmerView.stopAnimating()
        }
        actRetryButton.isHidden = !isInfoTabSelected || !actError
        actAcceptanceButton.isHidden = !isInfoTabSelected || actLoading || actError || acceptanceActData == nil
        actReturnButton.isHidden = !isInfoTabSelected || actLoading || actError || returnActData == nil
        signAcceptanceButton.isHidden = !isInfoTabSelected || actLoading || actError || acceptanceSignState == .hidden
        signReturnButton.isHidden = !isInfoTabSelected || actLoading || actError || returnSignState == .hidden
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

    private func fetchActBlock() {
        actBlockLoaded = false
        actBlockError = false
        acceptanceActData = nil
        returnActData = nil
        acceptanceSignState = .hidden
        returnSignState = .hidden
        updateTabSelection()
        view.setNeedsLayout()

        guard let client = AuthService.shared.client else {
            actBlockLoaded = true
            updateTabSelection()
            view.setNeedsLayout()
            return
        }

        let auth = AuthService.shared
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "dd.MM.yyyy"
        let renterName = "\(client.name.lastName) \(client.name.firstName)"
            .trimmingCharacters(in: .whitespaces)
        let renterPassport = "\(client.passport.series) \(client.passport.number)"
            .trimmingCharacters(in: .whitespaces)
        let integrationId = client.integrationId

        let group = DispatchGroup()
        var hasError = false

        for descriptorLong in [1, 2] {
            group.enter()
            rentApiFacade.getActInfo(
                clientIntegrationId: integrationId,
                objectId: contract.id,
                objectDescriptorLong: descriptorLong,
                contractNumber: contract.contractNumber ?? "",
                contractDate: dateFmt.string(from: contract.dateFrom),
                renterName: renterName,
                renterPassport: renterPassport,
                renterPhone: auth.phoneNumber ?? "",
                carInfo: contract.vehicle ?? ""
            ) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self else { group.leave(); return }
                    switch result {
                    case let .success(data):
                        if descriptorLong == 1 { self.acceptanceActData = data }
                        else { self.returnActData = data }
                        group.enter()
                        group.leave() // release getActInfo slot
                        self.rentApiFacade.getActSignState(
                            clientIntegrationId: integrationId,
                            objectId: self.contract.id,
                            objectDescriptorLong: descriptorLong
                        ) { [weak self] result in
                            DispatchQueue.main.async {
                                defer { group.leave() }
                                guard let self else { return }
                                switch result {
                                case let .success(response):
                                    let signState: SignState
                                    switch response.actState {
                                    case .draft:    signState = .needsSign
                                    case .finished: signState = .signed
                                    default:        signState = .notSigned
                                    }
                                    if descriptorLong == 1 { self.acceptanceSignState = signState }
                                    else { self.returnSignState = signState }
                                case .failure:
                                    hasError = true
                                }
                            }
                        }
                    case .failure:
                        group.leave() // act doesn't exist, skip sign state
                    }
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.actBlockLoaded = true
            self.actBlockError = hasError
            self.updateTabSelection()
            self.view.setNeedsLayout()
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
        let m = info.moneyInfo
        let hasDebt = m.notPaydCalculationsSumCurrent > 0

        // 1. Contract header card
        let statusTitle: String
        let statusColor: UIColor
        if hasDebt {
            statusTitle = "Требует оплаты"
            statusColor = .systemRed
        } else {
            switch contract.contractState {
            case .closed, .extendedClosed, .komissionClose, .terminated, .defolt, .komissionCanceled, .archivedDogovor, .sold:
                statusTitle = "Завершена"
                statusColor = .secondaryTextColor
            case .realisation, .extended, .extendedOpened:
                statusTitle = "Активна"
                statusColor = .systemGreen
            default:
                statusTitle = contract.statusTitle
                statusColor = .secondaryTextColor
            }
        }
        let headerCard = ContractPaymentHeaderCardView(
            contractNumber: contract.contractNumber ?? "",
            carName: contract.carTitle ?? contract.vehicle ?? "Автомобиль",
            dateFrom: contract.dateFrom,
            dateTo: contract.dateTo,
            statusTitle: statusTitle,
            statusColor: statusColor
        )
        paymentContentViews.append(headerCard)

        // 2. Debt alert card
        if hasDebt {
            let debtCard = DebtAlertCardView(amount: fmt(m.notPaydCalculationsSumCurrent))
            if !FeatureFlagService.shared.hidePayments {
                debtCard.onPayTapped = { [weak self] in
                    self?.payAccruals(sum: m.notPaydCalculationsSumCurrent)
                }
            } else {
                debtCard.hidePayButton()
            }
            paymentContentViews.append(debtCard)
        }

        // 3. Summary card
        let balance = m.servicesTotalPaydPaysSum - m.servicesTotalSum
        let overpaySubtitle: String? = balance > 0 ? "Переплата \(fmt(balance)) зачтена на следующую аренду" : nil
        let summaryCard = PaymentSummaryCardView(
            charged: fmt(m.servicesTotalSum),
            paid: fmt(m.servicesTotalPaydPaysSum),
            balance: balance,
            subtitle: overpaySubtitle,
            fmt: fmt
        )
        paymentContentViews.append(summaryCard)

        // 4. Deposit card
        if m.paydDepositSum > 0 || m.depositSum > 0 {
            paymentContentViews.append(DepositCardView(
                deposited: fmt(m.paydDepositSum),
                spent: fmt(m.depositOverSum),
                remaining: fmt(m.aviableDepositSum)
            ))
        }

        // 5. Calculations sections
        let allCalcs = info.contractCalculations
        let unpaid = allCalcs.filter { $0.paymentResultState == PaymentResultStates.notPayd.rawValue || $0.paymentResultState == PaymentResultStates.partPayd.rawValue }
        let paid = allCalcs.filter { $0.paymentResultState != PaymentResultStates.notPayd.rawValue && $0.paymentResultState != PaymentResultStates.partPayd.rawValue }

        if hasDebt {
            if !unpaid.isEmpty {
                let section = makeCalculationsSection(
                    title: "Требует оплаты",
                    total: fmt(m.notPaydCalculationsSumCurrent),
                    totalColor: .systemRed,
                    calculations: unpaid,
                    amountColor: .systemRed,
                    badge: .none,
                    expanded: true,
                    fmt: fmt
                )
                paymentContentViews.append(section)
            }
            if !paid.isEmpty {
                let section = makeCalculationsSection(
                    title: "Оплачено",
                    total: fmt(m.servicesTotalPaydPaysSum),
                    totalColor: .systemGreen,
                    calculations: paid,
                    amountColor: .whiteTextColor,
                    badge: .paid,
                    expanded: false,
                    fmt: fmt
                )
                paymentContentViews.append(section)
            }
        } else {
            if !allCalcs.isEmpty {
                let section = makeCalculationsSection(
                    title: "Все начисления",
                    total: fmt(m.servicesTotalSum),
                    totalColor: .systemGreen,
                    calculations: allCalcs,
                    amountColor: .whiteTextColor,
                    badge: .paid,
                    expanded: true,
                    fmt: fmt
                )
                paymentContentViews.append(section)
            }
        }

        // 6. Payment history section
        let paymentOps = info.operations.filter { $0.operationType == OperationTypes.payment.rawValue }
        if !paymentOps.isEmpty {
            let historyItems = paymentOps.map { op -> UIView in
                let dateFmt = DateFormatter()
                dateFmt.dateFormat = "dd.MM.yyyy"
                let subtitle = dateFmt.string(from: op.accountingDate)
                return CalculationItemView(
                    title: "Платёж",
                    subtitle: subtitle,
                    badge: .none,
                    amount: fmt(op.sum),
                    amountColor: .systemGreen
                )
            }
            let totalPaid = paymentOps.reduce(Decimal(0)) { $0 + $1.sum }
            let historySection = CollapsibleSectionView(
                title: "История платежей",
                total: fmt(totalPaid),
                totalColor: .systemGreen,
                items: historyItems,
                expanded: false
            )
            historySection.onToggle = { [weak self] in self?.performLayout() }
            paymentContentViews.append(historySection)
        }

        // 7. Footer
        let footerLabel = Label(
            text: "Вопросы по начислениям? Напишите в поддержку",
            numberOfLines: 0,
            fontSize: 13,
            textColor: .secondaryTextColor,
            textAlignment: .center
        )
        paymentContentViews.append(footerLabel)

        paymentContentViews.forEach { paymentContainerView.addSubview($0) }
        paymentContainerView.isHidden = false
        view.setNeedsLayout()
    }

    private func makeCalculationsSection(
        title: String,
        total: String,
        totalColor: UIColor,
        calculations: [MoneyCalculation],
        amountColor: UIColor,
        badge: CalculationItemView.Badge,
        expanded: Bool,
        fmt: (Decimal) -> String
    ) -> CollapsibleSectionView {
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "dd.MM.yyyy"

        let items: [UIView] = calculations.map { calc in
            let name = calc.subCategory.isEmpty ? calc.categoryTitle : calc.subCategory
            let rawSubtitle = calc.amountTitle.trimmingCharacters(in: .whitespaces)
            let subtitle = (rawSubtitle.isEmpty || rawSubtitle == "0") ? nil : rawSubtitle
            return CalculationItemView(
                title: name,
                subtitle: subtitle,
                badge: badge,
                amount: fmt(calc.sum),
                amountColor: amountColor
            )
        }

        let section = CollapsibleSectionView(
            title: title,
            total: total,
            totalColor: totalColor,
            items: items,
            expanded: expanded
        )
        section.onToggle = { [weak self] in self?.performLayout() }
        return section
    }

    private func payAccruals(sum: Decimal) {
        let amountInRubles = Int(truncating: sum as NSDecimalNumber)
        let contractNumber = contract.contractNumber ?? String(contract.id)
        let description = "Оплата начислений по договору №\(contractNumber)"

        coordinator.openYukassaPayment(
            amount: amountInRubles,
            description: description,
            onSuccess: { [weak self] transactionCode in
                self?.callPayAccrualsAPI(sum: sum, transactionCode: transactionCode)
            },
            onFail: { [weak self] in
                self?.coordinator.openPaymentFailBottomSheet {
                    self?.coordinator.popViewController()
                }
            }
        )
    }

    private func callPayAccrualsAPI(sum: Decimal, transactionCode: String?) {
        guard let integrationId = AuthService.shared.client?.integrationId else { return }
        coordinator.popViewController()
        showLoadingOverlay()
        rentApiFacade.payAccruals(
            clientIntegrationId: integrationId,
            contractId: contract.id,
            sum: sum,
            externalSource: "ЮKassa",
            externalSourceTransactionCode: transactionCode
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.hideLoadingOverlay()
                switch result {
                case let .success(response):
                    if let error = response.errors?.first?.message {
                        self.showToast(with: error)
                    } else {
                        self.hasLoadedPayments = false
                        self.fetchMoneyInfo()
                        self.showToast(with: "Оплата прошла успешно")
                    }
                case .failure:
                    self.showToast(with: "Ошибка оплаты. Попробуйте ещё раз")
                }
            }
        }
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

    @objc private func actAcceptanceTapped() {
        openActPDF(objectDescriptorLong: 1)
    }

    @objc private func actReturnTapped() {
        openActPDF(objectDescriptorLong: 2)
    }

    private func openActPDF(objectDescriptorLong: Int) {
        let data = objectDescriptorLong == 1 ? acceptanceActData : returnActData
        guard let data else { return }
        coordinator.openPDFViewController(pdfFile: .data(data))
    }

    private func signButtonTapped(objectDescriptorLong: Int) {
        guard let integrationId = AuthService.shared.client?.integrationId else { return }
        showLoadingOverlay()
        rentApiFacade.acceptAct(
            clientIntegrationId: integrationId,
            objectId: contract.id,
            objectDescriptorLong: objectDescriptorLong,
            signDate: Date()
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.hideLoadingOverlay()
                switch result {
                case .success:
                    switch objectDescriptorLong {
                    case 1: self.acceptanceSignState = .signed
                    case 2: self.returnSignState = .signed
                    default: break
                    }
                    self.view.setNeedsLayout()
                    let toastText = objectDescriptorLong == 1 ? "Акт приёмки подписан" : "Акт возврата подписан"
                    self.showToast(with: toastText)
                case .failure:
                    self.showToast(with: "Не удалось подписать акт")
                }
            }
        }
    }

    // MARK: - Layout

    private func performLayout() {
        let hInset: CGFloat = 16

        scrollView.pin.top(view.pin.safeArea).horizontally().bottom()

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

            let actLoading = !actBlockLoaded
            let actError = actBlockLoaded && actBlockError
            let signH: CGFloat = 40
            let linkShimH: CGFloat = 20
            let rowSpacing: CGFloat = 20
            let actSignGap: CGFloat = 12
            if actLoading {
                let shimTop0 = territoryTileView.frame.maxY + rowSpacing
                let linkShimW0: CGFloat = 120
                let linkShimW1: CGFloat = 110
                actAcceptanceShimmerView.pin
                    .top(shimTop0 + (signH - linkShimH) / 2)
                    .left(hInset)
                    .width(linkShimW0)
                    .height(linkShimH)
                actAcceptanceSignShimmerView.pin
                    .top(shimTop0)
                    .left(hInset + linkShimW0 + actSignGap)
                    .right(hInset)
                    .height(signH)
                let shimTop1 = shimTop0 + signH + rowSpacing
                actReturnShimmerView.pin
                    .top(shimTop1 + (signH - linkShimH) / 2)
                    .left(hInset)
                    .width(linkShimW1)
                    .height(linkShimH)
                actReturnSignShimmerView.pin
                    .top(shimTop1)
                    .left(hInset + linkShimW1 + actSignGap)
                    .right(hInset)
                    .height(signH)
                actAcceptanceButton.pin.top(0).left(0).width(0).height(0)
                actReturnButton.pin.top(0).left(0).width(0).height(0)
                signAcceptanceButton.pin.top(0).left(0).width(0).height(0)
                signReturnButton.pin.top(0).left(0).width(0).height(0)
                actRetryButton.pin.top(0).left(0).width(0).height(0)
            } else if actError {
                actAcceptanceShimmerView.pin.top(0).left(0).width(0).height(0)
                actReturnShimmerView.pin.top(0).left(0).width(0).height(0)
                actAcceptanceSignShimmerView.pin.top(0).left(0).width(0).height(0)
                actReturnSignShimmerView.pin.top(0).left(0).width(0).height(0)
                actAcceptanceButton.pin.top(0).left(0).width(0).height(0)
                actReturnButton.pin.top(0).left(0).width(0).height(0)
                signAcceptanceButton.pin.top(0).left(0).width(0).height(0)
                signReturnButton.pin.top(0).left(0).width(0).height(0)
                actRetryButton.pin
                    .top(territoryTileView.frame.maxY + rowSpacing)
                    .horizontally(hInset)
                    .height(signH)
            } else {
                actAcceptanceShimmerView.pin.top(0).left(0).width(0).height(0)
                actReturnShimmerView.pin.top(0).left(0).width(0).height(0)
                actAcceptanceSignShimmerView.pin.top(0).left(0).width(0).height(0)
                actReturnSignShimmerView.pin.top(0).left(0).width(0).height(0)
                actRetryButton.pin.top(0).left(0).width(0).height(0)

                var rowTop = territoryTileView.frame.maxY + rowSpacing

                // Row 1: acceptance act
                let row1HasLink = acceptanceActData != nil
                let row1HasSign = acceptanceSignState != .hidden
                if row1HasLink || row1HasSign {
                    if row1HasLink {
                        actAcceptanceButton.pin.top(rowTop).left(hInset).sizeToFit()
                    } else {
                        actAcceptanceButton.pin.top(0).left(0).width(0).height(0)
                    }
                    if row1HasSign {
                        switch acceptanceSignState {
                        case .needsSign:
                            signAcceptanceButton.setTitle("Подписать", for: .normal)
                            signAcceptanceButton.enable()
                        case .signed:
                            signAcceptanceButton.setTitle("Подписан", for: .normal)
                            signAcceptanceButton.disable()
                        default:
                            signAcceptanceButton.setTitle("Не подписан", for: .normal)
                            signAcceptanceButton.disable()
                        }
                        let signLeft = row1HasLink ? actAcceptanceButton.frame.maxX + actSignGap : hInset
                        signAcceptanceButton.pin.top(rowTop).left(signLeft).right(hInset).height(signH)
                    } else {
                        signAcceptanceButton.pin.top(0).left(0).width(0).height(0)
                    }
                    if row1HasLink && row1HasSign {
                        actAcceptanceButton.pin.vCenter(to: signAcceptanceButton.edge.vCenter).left(hInset).sizeToFit()
                    }
                    let row1H = max(row1HasLink ? actAcceptanceButton.frame.height : 0,
                                   row1HasSign ? signH : 0)
                    rowTop += row1H + rowSpacing
                } else {
                    actAcceptanceButton.pin.top(0).left(0).width(0).height(0)
                    signAcceptanceButton.pin.top(0).left(0).width(0).height(0)
                }

                // Row 2: return act
                let row2HasLink = returnActData != nil
                let row2HasSign = returnSignState != .hidden
                if row2HasLink || row2HasSign {
                    if row2HasLink {
                        actReturnButton.pin.top(rowTop).left(hInset).sizeToFit()
                    } else {
                        actReturnButton.pin.top(0).left(0).width(0).height(0)
                    }
                    if row2HasSign {
                        switch returnSignState {
                        case .needsSign:
                            signReturnButton.setTitle("Подписать", for: .normal)
                            signReturnButton.enable()
                        case .signed:
                            signReturnButton.setTitle("Подписан", for: .normal)
                            signReturnButton.disable()
                        default:
                            signReturnButton.setTitle("Не подписан", for: .normal)
                            signReturnButton.disable()
                        }
                        let signLeft = row2HasLink ? actReturnButton.frame.maxX + actSignGap : hInset
                        signReturnButton.pin.top(rowTop).left(signLeft).right(hInset).height(signH)
                    } else {
                        signReturnButton.pin.top(0).left(0).width(0).height(0)
                    }
                    if row2HasLink && row2HasSign {
                        actReturnButton.pin.vCenter(to: signReturnButton.edge.vCenter).left(hInset).sizeToFit()
                    }
                } else {
                    actReturnButton.pin.top(0).left(0).width(0).height(0)
                    signReturnButton.pin.top(0).left(0).width(0).height(0)
                }
            }

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

        loadingOverlayView.pin.all()
        overlaySpinner.pin.center()
    }

    // MARK: - Loading overlay

    private func showLoadingOverlay() {
        loadingOverlayView.isHidden = false
        overlaySpinner.startAnimating()
        actAcceptanceButton.isEnabled = false
        actReturnButton.isEnabled = false
    }

    private func hideLoadingOverlay() {
        loadingOverlayView.isHidden = true
        overlaySpinner.stopAnimating()
        actAcceptanceButton.isEnabled = true
        actReturnButton.isEnabled = true
    }
}

