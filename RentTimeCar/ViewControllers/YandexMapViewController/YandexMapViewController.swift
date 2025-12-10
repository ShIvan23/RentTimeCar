//
//  YandexMapViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 15.11.2025.
//

import PinLayout
import YandexMapsMobile
import UIKit

enum YandexMapStep: String {
    case first = "Доставка"
    case second = "Возврат"
    case edit = "Получение и возврат"
}

final class YandexMapViewController: UIViewController {
    // MARK: - UI
    
    private let mapView = YMKMapView()
    private let placeMarkImageView = UIImageView()
    private let segmentControl = UISegmentedControl(items: [String.office, String.delivery])
    private let addressOfficeView = AddressOfficeView()
    private let customAddressView = CustomAddressView()
    private let confirmButton = MainButton(title: "Продолжить")
    private let editAddressView = EditAddressView()

    // MARK: - Private Properties
    
    private let coordinator: ICoordinator
    private let searchManager = YMKSearchFactory.instance().createSearchManager(with: .online)
    private var searchSession: YMKSearchSession?
    private var searchSessions: [YMKSearchSession] = []
    private let officeCameraPosition = YMKPoint(latitude: 55.7976500, longitude: 37.495626)
    private var placeMark: YMKPlacemarkMapObject?
    private var mapObjects: YMKMapObjectCollection {
        return mapView.mapWindow.map.mapObjects
    }
    private var step = YandexMapStep.first
    private var firstStepAddress = ""
    private var secondStepAddress = ""


    // MARK: - Init
    
    init(coordinator: ICoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupMap()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        performLayout()
    }
    
    // MARK: - Private Methods
    
    private func performLayout() {
        mapView.pin
            .top(view.safeAreaInsets.top)
            .horizontally()
            .height(view.bounds.width)
        
        let placeMarkSize: CGFloat = 50
        
        placeMarkImageView.pin
            .center()
            .size(CGSize(square: placeMarkSize))
            .marginBottom(placeMarkSize / 2)
        
        let horizontalMargin: CGFloat = 16
        
        segmentControl.pin
            .below(of: mapView)
            .horizontally()
            .marginTop(20)
            .marginHorizontal(horizontalMargin)
            .height(40)
        
        let deliveryTopMargin: CGFloat = 20
        
        if !addressOfficeView.isHidden {
            addressOfficeView.pin
                .below(of: segmentControl)
                .horizontally()
                .marginHorizontal(horizontalMargin)
                .marginTop(deliveryTopMargin)
                .sizeToFit(.width)
        }
        
        if !customAddressView.isHidden {
            customAddressView.pin
                .below(of: segmentControl)
                .horizontally()
                .marginHorizontal(horizontalMargin)
                .marginTop(deliveryTopMargin)
                .sizeToFit(.width)
        }

        if !editAddressView.isHidden {
            editAddressView.pin
                .below(of: segmentControl)
                .horizontally()
                .marginHorizontal(horizontalMargin)
                .marginTop(deliveryTopMargin)
                .sizeToFit(.width)
        }

        confirmButton.pin
            .below(of: visible([addressOfficeView, customAddressView, editAddressView]))
            .horizontally()
            .marginTop(20)
            .marginHorizontal(horizontalMargin)
            .height(50)
    }
    
    private func setupView() {
        view.addSubviews([mapView, segmentControl, addressOfficeView, customAddressView, confirmButton, editAddressView])
        mapView.addSubview(placeMarkImageView)
        view.backgroundColor = .mainBackground
        placeMarkImageView.image = .location
        placeMarkImageView.isHidden = true
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(segmentControlAction), for: .valueChanged)
        customAddressView.isHidden = true
        customAddressView.addTapGestureClosure { [weak self] in
            guard let self else { return }
            coordinator.openSearchAddressViewController(delegate: self)
        }

        confirmButton.action = { [weak self] in
            guard let self else { return }
            switch step {
            case .first:
                step = .second
                title = step.rawValue
                firstStepAddress = segmentControl.selectedSegmentIndex == 0 ? addressOfficeView.getAddress() : (customAddressView.getAddress() ?? addressOfficeView.getAddress())
            case .second:
                step = .edit
                title = step.rawValue
                secondStepAddress = segmentControl.selectedSegmentIndex == 0 ? addressOfficeView.getAddress() : (customAddressView.getAddress() ?? addressOfficeView.getAddress())
                let editModel = [
                    EditAddressModel(
                        title: YandexMapStep.first.rawValue,
                        address: firstStepAddress
                    ),
                    EditAddressModel(
                        title: YandexMapStep.second.rawValue,
                        address: secondStepAddress
                    ),
                ]
                addressOfficeView.isHidden = true
                customAddressView.isHidden = true
                editAddressView.isHidden = false
                editAddressView.configure(with: editModel)
                view.setNeedsLayout()
            case .edit:
                print("Навигаровать дальше")
            }
        }
        title = step.rawValue
        editAddressView.isHidden = true
    }
    
    private func setupMap() {
        mapView.mapWindow.map.addCameraListener(with: self)
        
        mapView.mapWindow.map.move(with: YMKCameraPosition(target: officeCameraPosition, zoom: 15.5, azimuth: 0, tilt: 0))
        let placeMark = mapObjects.addPlacemark()
        placeMark.setIconWith(.location)
        let officePoint = YMKPoint(latitude: 55.798115, longitude: 37.495626)
        placeMark.geometry = officePoint
        placeMark.isDraggable = true
        let iconStyle = YMKIconStyle()
        iconStyle.scale = 0.3
        placeMark.setIconStyleWith(iconStyle)
        self.placeMark = placeMark
    }
    
    @objc
    private func segmentControlAction(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            showOffice()
            showAddressOfficeView()
            customAddressView.resetText()
        case 1:
            showCustomPlaceMark()
            showCustomAddressView()
        default:
            break
        }
        view.setNeedsLayout()
    }
    
    private func showOffice() {
        placeMark?.opacity = 1.0
        placeMarkImageView.isHidden = true
        mapView.mapWindow.map.move(
            with:
                YMKCameraPosition(
                    target: officeCameraPosition,
                    zoom: 15.5,
                    azimuth: 0,
                    tilt: 0),
            animation:
                YMKAnimation(
                    type: .smooth,
                    duration: 0.3)
        )
    }
    
    private func showCustomPlaceMark() {
        placeMarkImageView.isHidden = false
        placeMark?.opacity = 0.0
    }
    
    private func showAddressOfficeView() {
        addressOfficeView.isHidden = false
        customAddressView.isHidden = true
    }
    
    private func showCustomAddressView() {
        customAddressView.isHidden = false
        addressOfficeView.isHidden = true
    }
}

// MARK: - YMKMapCameraListener

extension YandexMapViewController: YMKMapCameraListener {
    func onCameraPositionChanged(with map: YMKMap, cameraPosition: YMKCameraPosition, cameraUpdateReason: YMKCameraUpdateReason, finished: Bool) {
        guard !placeMarkImageView.isHidden,
              finished else { return }
        let target = cameraPosition.target
        let searchSession = searchManager.submit(
            with: target,
            zoom: 16,
            searchOptions: YMKSearchOptions()
        ) { [weak self] response, error in
            guard let response,
                  let object = response.collection.children.first?.obj?.metadataContainer.getItemOf(YMKSearchToponymObjectMetadata.self) as? YMKSearchToponymObjectMetadata else { return }
            let componentsCount = object.address.components.count
            guard let street = object.address.components[safe: componentsCount - 2],
                  let house = object.address.components[safe: componentsCount - 1] else {
                assertionFailure("No address")
                return
            }
            let address = street.name + " " + house.name
            self?.customAddressView.configure(with: address)
        }
        searchSessions.append(searchSession)
    }
}

// MARK: - SearchAddressViewControllerDelegate

extension YandexMapViewController: SearchAddressViewControllerDelegate {
    func search(uri: String?) {
        guard let uri else { return }
        searchSession?.cancel()
        searchSession = searchManager.searchByURI(
            withUri: uri,
            searchOptions: YMKSearchOptions(),
            responseHandler: { [weak self] response, error in
                guard let self,
                let response,
                    let point = response.collection.children.first?.obj?.geometry.first?.point else { return }
                mapView.mapWindow.map.move(with: YMKCameraPosition(target: point, zoom: 15.5, azimuth: 0, tilt: 0))
            })
    }
}

private extension String {
    static let office = "Забрать из офиса"
    static let delivery = "Доставить по адресу"
}

private extension YandexMapViewController {
    struct SearchResponseItem {
        let point: YMKPoint
        let geoObject: YMKGeoObject?
    }
}
