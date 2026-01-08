//
//  CalendarViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 09.09.2025.
//

import FSCalendar
import UIKit

final class CalendarViewController: UIViewController {
    // MARK: - UI
    
    private let calendar = FSCalendar()
    private let selectButton = MainButton(title: "Выбрать")
    
    // MARK: - Private Properties
    
    private var firstDate: Date?
    private var lastDate: Date?
    private var datesRange = [Date]()
    private let filterService = FilterService.shared

    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        performLayout()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        setupCalendar()
        view.addSubviews([calendar, selectButton])
        view.backgroundColor = .mainBackground
        setupButtonAction()
    }

    private func setupCalendar() {
        calendar.delegate = self
        calendar.allowsMultipleSelection = true
        calendar.firstWeekday = 2
        calendar.locale = Locale(identifier: "ru_RU")
        calendar.appearance.headerDateFormat = "LLLL yyyy"
        calendar.appearance.titleDefaultColor = .whiteTextColor
        calendar.appearance.headerTitleColor = .whiteTextColor
        calendar.appearance.weekdayTextColor = .whiteTextColor
        filterService.selectedDates.forEach {
            calendar.select($0)
        }
        datesRange = filterService.selectedDates
        firstDate = filterService.selectedDates.first
        lastDate = filterService.selectedDates.last
    }

    private func setupButtonAction() {
        selectButton.action = { [weak self] in
            guard let self else { return }
            sendSelectedDates()
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func sendSelectedDates() {
        FilterService.shared.setSelectedDates(datesRange)
    }
    
    private func performLayout() {
        selectButton.pin
            .bottom()
            .horizontally()
            .height(50)
            .marginHorizontal(12)
            .marginBottom(view.safeAreaInsets.bottom + 10)
        
        calendar.pin
            .top()
            .horizontally()
            .bottom(to: selectButton.edge.top)
            .marginTop(view.safeAreaInsets.top)
    }
    
    private func datesRange(from: Date, to: Date) -> [Date] {
        // in case of the "from" date is more than "to" date,
        // it should returns an empty array:
        if from > to { return [Date]() }
        
        var tempDate = from
        var array = [tempDate]
        
        while tempDate < to {
            tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)!
            array.append(tempDate)
        }
        
        return array
    }
}

// MARK: - FSCalendarDelegate

extension CalendarViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if firstDate == nil {
            firstDate = date
            datesRange = [firstDate!]
            return
        }
        
        if firstDate != nil && lastDate == nil {
            if date <= firstDate! {
                calendar.deselect(firstDate!)
                firstDate = date
                datesRange = [firstDate!]
                return
            }
            let range = datesRange(from: firstDate!, to: date)
            lastDate = range.last
            
            for date in range {
                calendar.select(date)
            }
            datesRange = range
            return
        }
        
        if firstDate != nil && lastDate != nil {
            for date in calendar.selectedDates {
                calendar.deselect(date)
            }
            lastDate = nil
            firstDate = nil
            datesRange = []
        }
    }
}
