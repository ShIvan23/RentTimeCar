//
//  FineDetailViewController.swift
//  RentTimeCar
//

import Nuke
import NukeExtensions
import PinLayout
import UIKit

final class FineDetailViewController: UIViewController {

    // MARK: - Private Properties

    private let fine: FineDto
    private let coordinator: ICoordinator

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Header card
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
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor = .whiteTextColor
        return l
    }()

    private let startLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryTextColor
        return l
    }()

    private let endLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryTextColor
        return l
    }()

    private let plateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryTextColor
        return l
    }()

    // Sections
    private let separator1 = SeparatorView()
    private let separator2 = SeparatorView()
    private let separator3 = SeparatorView()

    private let documentTitleLabel = InfoTitleLabel(text: "Номер постановления")
    private let documentValueLabel = InfoValueLabel()

    private let violationDateTitleLabel = InfoTitleLabel(text: "Дата нарушения:")
    private let violationDateValueLabel = InfoValueLabel()
    private let creationDateTitleLabel = InfoTitleLabel(text: "Дата выставления")
    private let creationDateValueLabel = InfoValueLabel()

    private let descriptionTitleLabel = InfoTitleLabel(text: "Описание штрафа")
    private let descriptionValueLabel: UILabel = {
        let l = InfoValueLabel()
        l.numberOfLines = 0
        return l
    }()

    private let photoButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Смотреть фото нарушения", for: .normal)
        b.setTitleColor(.whiteTextColor, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15)
        b.contentHorizontalAlignment = .left
        b.backgroundColor = .secondaryBackground
        b.layer.cornerRadius = 12
        b.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return b
    }()

    private let photoArrowImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = .secondaryTextColor
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - Formatters

    private static let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm, dd.MM.yy"
        return f
    }()

    private static let fullDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm, dd.MM.yyyy"
        return f
    }()

    // MARK: - Init

    init(fine: FineDto, coordinator: ICoordinator) {
        self.fine = fine
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

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

    // MARK: - Private

    private func setupView() {
        view.backgroundColor = .mainBackground
        title = "Детали штрафа"
        navigationController?.isNavigationBarHidden = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubviews([
            headerCardView,
            separator1,
            documentTitleLabel, documentValueLabel,
            separator2,
            violationDateTitleLabel, violationDateValueLabel,
            creationDateTitleLabel, creationDateValueLabel,
            separator3,
            descriptionTitleLabel, descriptionValueLabel,
            photoButton
        ])
        headerCardView.addSubviews([carImageView, carNameLabel, startLabel, endLabel, plateLabel])
        photoButton.addSubview(photoArrowImageView)

        photoButton.addTarget(self, action: #selector(photoButtonTapped), for: .touchUpInside)

        let hasPhotos = !(fine.attachedImageUris?.isEmpty ?? true)
        photoButton.isHidden = !hasPhotos
    }

    private func configure() {
        carNameLabel.text = fine.vehicle?.uppercased() ?? "АВТОМОБИЛЬ"
        plateLabel.text = fine.vehicleGibddNumber.map { "Номер   \($0)" } ?? "Номер   —"
        startLabel.text = fine.contract?.dateFrom.map { "Начало:  \(Self.shortDateFormatter.string(from: $0))" } ?? "Начало:  —"
        endLabel.text = fine.contract?.dateTo.map { "Конец:   \(Self.shortDateFormatter.string(from: $0))" } ?? "Конец:   —"

        documentValueLabel.text = maskedDocumentNumber(fine.documentNumber)

        violationDateValueLabel.text = fine.violationDate.map { Self.fullDateFormatter.string(from: $0) } ?? "—"
        creationDateValueLabel.text = fine.creationDate.map { Self.fullDateFormatter.string(from: $0) } ?? "—"

        descriptionValueLabel.text = fine.koapEntityDescription ?? fine.location ?? "—"

        loadCarImage()
    }

    private func loadCarImage() {
        carImageView.image = .carPlaceholder
        guard let vehicleName = fine.vehicle else { return }
        let searchKey = vehicleName.components(separatedBy: ",").first ?? vehicleName
        let matched = FilterService.shared.allAutos.first {
            $0.title.localizedCaseInsensitiveContains(searchKey)
        }
        guard let urlString = matched?.files.first(where: { $0.url != nil && $0.folder == .folderImageValue })?.url,
              let url = URL(string: urlString) else { return }
        let options = ImageLoadingOptions(placeholder: .carPlaceholder, transition: .fadeIn(duration: 0.3))
        NukeExtensions.loadImage(with: url, options: options, into: carImageView)
    }

    private func maskedDocumentNumber(_ number: String?) -> String {
        guard let number, !number.isEmpty else { return "—" }
        let visibleCount = min(6, number.count)
        let visible = String(number.prefix(visibleCount))
        let suffix = number.count > visibleCount ? "****" : ""
        return "№\(visible)\(suffix)"
    }

    @objc private func photoButtonTapped() {
        let uris = fine.attachedImageUris ?? []
        guard !uris.isEmpty else { return }
        coordinator.openFinePhotosViewController(images: uris)
    }

    // MARK: - Layout

    private func performLayout() {
        let hPad: CGFloat = 16

        scrollView.pin.all(view.pin.safeArea)
        contentView.pin.top().horizontally()

        // Header card
        let cardHeight: CGFloat = 120
        headerCardView.pin
            .top(16)
            .horizontally(hPad)
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

        startLabel.pin
            .below(of: carNameLabel)
            .marginTop(8)
            .left(labelLeft)
            .right(labelRight)
            .sizeToFit(.width)

        endLabel.pin
            .below(of: startLabel)
            .marginTop(4)
            .left(labelLeft)
            .right(labelRight)
            .sizeToFit(.width)

        plateLabel.pin
            .below(of: endLabel)
            .marginTop(4)
            .left(labelLeft)
            .right(labelRight)
            .sizeToFit(.width)

        // Document number section
        separator1.pin
            .below(of: headerCardView)
            .marginTop(20)
            .horizontally(hPad)
            .height(1)

        documentTitleLabel.pin
            .below(of: separator1)
            .marginTop(16)
            .horizontally(hPad)
            .sizeToFit(.width)

        documentValueLabel.pin
            .below(of: documentTitleLabel)
            .marginTop(6)
            .horizontally(hPad)
            .sizeToFit(.width)

        // Dates section
        separator2.pin
            .below(of: documentValueLabel)
            .marginTop(16)
            .horizontally(hPad)
            .height(1)

        violationDateTitleLabel.pin
            .below(of: separator2)
            .marginTop(16)
            .left(hPad)
            .width(scrollView.bounds.width / 2 - hPad)
            .sizeToFit(.width)

        creationDateTitleLabel.pin
            .below(of: separator2)
            .marginTop(16)
            .left(scrollView.bounds.width / 2)
            .right(hPad)
            .sizeToFit(.width)

        violationDateValueLabel.pin
            .below(of: violationDateTitleLabel)
            .marginTop(6)
            .left(hPad)
            .width(scrollView.bounds.width / 2 - hPad)
            .sizeToFit(.width)

        creationDateValueLabel.pin
            .below(of: creationDateTitleLabel)
            .marginTop(6)
            .left(scrollView.bounds.width / 2)
            .right(hPad)
            .sizeToFit(.width)

        let dateBottom = max(violationDateValueLabel.frame.maxY, creationDateValueLabel.frame.maxY)

        // Description section
        separator3.pin
            .top(dateBottom + 16)
            .horizontally(hPad)
            .height(1)

        descriptionTitleLabel.pin
            .below(of: separator3)
            .marginTop(16)
            .horizontally(hPad)
            .sizeToFit(.width)

        descriptionValueLabel.pin
            .below(of: descriptionTitleLabel)
            .marginTop(6)
            .horizontally(hPad)
            .sizeToFit(.width)

        // Photo button
        let buttonHeight: CGFloat = 52
        if photoButton.isHidden {
            contentView.pin.wrapContent(.vertically, padding: PEdgeInsets(top: 0, left: 0, bottom: 24, right: 0))
        } else {
            photoButton.pin
                .below(of: descriptionValueLabel)
                .marginTop(24)
                .horizontally(hPad)
                .height(buttonHeight)

            photoArrowImageView.pin
                .right(16)
                .vCenter()
                .size(14)

            contentView.pin.wrapContent(.vertically, padding: PEdgeInsets(top: 0, left: 0, bottom: 32, right: 0))
        }

        scrollView.contentSize = contentView.frame.size
    }
}

// MARK: - Helper views

private final class SeparatorView: UIView {
    init() {
        super.init(frame: .zero)
        backgroundColor = .secondaryBackground
    }
    required init?(coder: NSCoder) { fatalError() }
}

private final class InfoTitleLabel: UILabel {
    init(text: String) {
        super.init(frame: .zero)
        self.text = text
        font = .systemFont(ofSize: 13)
        textColor = .secondaryTextColor
    }
    required init?(coder: NSCoder) { fatalError() }
}

private final class InfoValueLabel: UILabel {
    init() {
        super.init(frame: .zero)
        font = .systemFont(ofSize: 15)
        textColor = .whiteTextColor
    }
    required init?(coder: NSCoder) { fatalError() }
}
