//
//  RentalPriceCalculator.swift
//  RentTimeCar
//

import Foundation

/// Единственное место расчёта стоимости аренды.
/// Используется в CalendarViewController (превью цены) и RentSummaryViewController (итог заказа).
///
/// Формула:
///   billableDays = remainingMinutes > 360 ? daysCount + 1 : daysCount
///   discountPercent = billableDays > 1 ? min(billableDays, 30) : 0
///   daysRent = Int(Double(dailyPrice × billableDays) × (1 − discountPercent / 100))
///   extraHours = remainingMinutes ∈ (0, 360] ? ceil(remainingMinutes / 60) : 0
///   hourlyRate = Int(dailyPrice / 10 × (1 − discountPercent / 100))
///   totalRent = daysRent + hourlyRate × extraHours
enum RentalPriceCalculator {

    struct Result {
        /// Итоговое количество оплачиваемых суток
        let daysCount: Int
        /// Базовая суточная цена
        let dailyPrice: Int
        /// Скидка на сутки: 0% за 1 сутки, N% за N суток, максимум 30%
        let discountPercent: Int
        /// Стоимость суток с учётом скидки (без почасовой надбавки)
        let daysRent: Int
        /// Почасовая ставка (dailyPrice / 10)
        let hourlyRate: Int
        /// Количество доп. часов (0 если надбавка не применяется)
        let extraHours: Int
        /// Итоговая стоимость аренды: daysRent + hourlyRate × extraHours
        let totalRent: Int
    }

    /// - Parameters:
    ///   - dailyPrice: суточная цена (Auto.defaultPriceWithDiscountSt)
    ///   - daysCount: количество суток (обычно max(1, selectedDates.count − 1))
    ///   - remainingMinutes: остаток времени конец − начало в минутах (default = 0)
    ///     · > 360 → округление вверх до ещё одних суток
    ///     · 1…360 → почасовая надбавка по ставке dailyPrice / 10
    ///     · ≤ 0 → только целые сутки
    static func calculate(dailyPrice: Int, daysCount: Int, remainingMinutes: Int = 0) -> Result {
        let days = max(1, daysCount)
        let hourlyRate = dailyPrice / 10

        let billableDays: Int
        let extraHours: Int

        if remainingMinutes > 360 {
            billableDays = days + 1
            extraHours = 0
        } else if remainingMinutes > 0 {
            billableDays = days
            extraHours = (remainingMinutes + 59) / 60
        } else {
            billableDays = days
            extraHours = 0
        }

        let discount = billableDays > 1 ? min(billableDays, 30) : 0
        let base = dailyPrice * billableDays
        let daysRent = Int(Double(base) * (1.0 - Double(discount) / 100.0))
        // Почасовая ставка: 10% от суточной цены с той же скидкой по дням
        let discountedHourlyRate = Int(Double(hourlyRate) * (1.0 - Double(discount) / 100.0))
        let total = daysRent + discountedHourlyRate * extraHours

        return Result(
            daysCount: billableDays,
            dailyPrice: dailyPrice,
            discountPercent: discount,
            daysRent: daysRent,
            hourlyRate: discountedHourlyRate,
            extraHours: extraHours,
            totalRent: total
        )
    }
}
