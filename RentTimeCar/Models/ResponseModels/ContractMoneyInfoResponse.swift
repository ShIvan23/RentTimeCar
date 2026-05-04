//
//  ContractMoneyInfoResponse.swift
//  RentTimeCar
//

import Foundation

// MARK: - Root

struct ContractMoneyInfoResponse: Decodable {
    let operations: [MoneyOperation]
    let contractCalculations: [MoneyCalculation]
    let moneyInfo: MoneyInfo

    enum CodingKeys: String, CodingKey {
        case operations = "Operations"
        case contractCalculations = "ContractCalculations"
        case moneyInfo = "MoneyInfo"
    }
}

// MARK: - Operation

struct MoneyOperation: Decodable {
    let operationId: String
    let sum: Decimal
    let direction: Int
    let operationTypeTitle: String
    let operationType: Int
    let description: String
    let accountingDate: Date
    let amount: Decimal
    let amountIntervalBegin: Date
    let amountIntervalEnd: Date
    let amountTitle: String
    let paymentResultState: Int
    let toPaymentSum: Decimal
    let calculations: [MoneyCalculation]
    let payments: [MoneyPayment]

    enum CodingKeys: String, CodingKey {
        case operationId = "OperationId"
        case sum = "Sum"
        case direction = "Direction"
        case operationTypeTitle = "OperationTypeTitle"
        case operationType = "OperationType"
        case description = "Description"
        case accountingDate = "AccountingDate"
        case amount = "Amount"
        case amountIntervalBegin = "AmountIntervalBegin"
        case amountIntervalEnd = "AmountIntervalEnd"
        case amountTitle = "AmountTitle"
        case paymentResultState = "PaymentResultState"
        case toPaymentSum = "ToPaymentSum"
        case calculations = "Calculations"
        case payments = "Payments"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        operationId = try c.decode(String.self, forKey: .operationId)
        sum = (try? c.decode(Decimal.self, forKey: .sum)) ?? 0
        direction = try c.decode(Int.self, forKey: .direction)
        operationTypeTitle = (try? c.decode(String.self, forKey: .operationTypeTitle)) ?? ""
        operationType = try c.decode(Int.self, forKey: .operationType)
        description = (try? c.decode(String.self, forKey: .description)) ?? ""
        amount = (try? c.decode(Decimal.self, forKey: .amount)) ?? 0
        amountTitle = (try? c.decode(String.self, forKey: .amountTitle)) ?? ""
        paymentResultState = (try? c.decode(Int.self, forKey: .paymentResultState)) ?? 0
        toPaymentSum = (try? c.decode(Decimal.self, forKey: .toPaymentSum)) ?? 0
        calculations = (try? c.decode([MoneyCalculation].self, forKey: .calculations)) ?? []
        payments = (try? c.decode([MoneyPayment].self, forKey: .payments)) ?? []

        let formatter = DateFormatter.moneyInfoFormatter
        let dateStr = try c.decode(String.self, forKey: .accountingDate)
        accountingDate = formatter.date(from: dateStr) ?? Date()
        let beginStr = try c.decode(String.self, forKey: .amountIntervalBegin)
        amountIntervalBegin = formatter.date(from: beginStr) ?? Date()
        let endStr = try c.decode(String.self, forKey: .amountIntervalEnd)
        amountIntervalEnd = formatter.date(from: endStr) ?? Date()
    }
}

// MARK: - Calculation

struct MoneyCalculation: Decodable {
    let id: Int64
    let sum: Decimal
    let direction: Int
    let categoryId: Int64
    let categoryTitle: String
    let subCategory: String
    let description: String
    let accountingDate: Date
    let amount: Decimal
    let amountIntervalBegin: Date
    let amountIntervalEnd: Date
    let amountTitle: String
    let paymentResultState: Int
    let toPaymentSum: Decimal
    let contractId: Int64?
    let contractNumber: String?
    let linkedObjectId: Int64?
    let linkedObjectName: String?
    let customValue1: String?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case sum = "Sum"
        case direction = "Direction"
        case categoryId = "CategoryId"
        case categoryTitle = "CategoryTItle"   // опечатка в API
        case subCategory = "SubCategory"
        case description = "Description"
        case accountingDate = "AccountingDate"
        case amount = "Amount"
        case amountIntervalBegin = "AmountIntervalBegin"
        case amountIntervalEnd = "AmountIntervalEnd"
        case amountTitle = "AmountTitle"
        case paymentResultState = "PaymentResultState"
        case toPaymentSum = "ToPaymentSum"
        case contractId = "ContractId"
        case contractNumber = "ContractNumber"
        case linkedObjectId = "LinkedObjectId"
        case linkedObjectName = "LinkedObjectName"
        case customValue1 = "CustomValue1"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int64.self, forKey: .id)
        sum = (try? c.decode(Decimal.self, forKey: .sum)) ?? 0
        direction = try c.decode(Int.self, forKey: .direction)
        categoryId = (try? c.decode(Int64.self, forKey: .categoryId)) ?? 0
        categoryTitle = (try? c.decode(String.self, forKey: .categoryTitle)) ?? ""
        subCategory = (try? c.decode(String.self, forKey: .subCategory)) ?? ""
        description = (try? c.decode(String.self, forKey: .description)) ?? ""
        amount = (try? c.decode(Decimal.self, forKey: .amount)) ?? 0
        amountTitle = (try? c.decode(String.self, forKey: .amountTitle)) ?? ""
        paymentResultState = (try? c.decode(Int.self, forKey: .paymentResultState)) ?? 0
        toPaymentSum = (try? c.decode(Decimal.self, forKey: .toPaymentSum)) ?? 0
        contractId = try? c.decode(Int64.self, forKey: .contractId)
        contractNumber = try? c.decode(String.self, forKey: .contractNumber)
        linkedObjectId = try? c.decode(Int64.self, forKey: .linkedObjectId)
        linkedObjectName = try? c.decode(String.self, forKey: .linkedObjectName)
        customValue1 = try? c.decode(String.self, forKey: .customValue1)

        let formatter = DateFormatter.moneyInfoFormatter
        let dateStr = try c.decode(String.self, forKey: .accountingDate)
        accountingDate = formatter.date(from: dateStr) ?? Date()
        let beginStr = try c.decode(String.self, forKey: .amountIntervalBegin)
        amountIntervalBegin = formatter.date(from: beginStr) ?? Date()
        let endStr = try c.decode(String.self, forKey: .amountIntervalEnd)
        amountIntervalEnd = formatter.date(from: endStr) ?? Date()
    }
}

// MARK: - Payment (inside Operation)

struct MoneyPayment: Decodable {
    let id: Int64
    let sum: Decimal
    let direction: Int
    let categoryId: Int64
    let categoryTitle: String
    let subCategory: String
    let description: String
    let accountingDate: Date
    let amount: Decimal
    let amountIntervalBegin: Date
    let amountIntervalEnd: Date
    let amountTitle: String
    let customValue1: String?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case sum = "Sum"
        case direction = "Direction"
        case categoryId = "CategoryId"
        case categoryTitle = "CategoryTItle"   // опечатка в API
        case subCategory = "SubCategory"
        case description = "Description"
        case accountingDate = "AccountingDate"
        case amount = "Amount"
        case amountIntervalBegin = "AmountIntervalBegin"
        case amountIntervalEnd = "AmountIntervalEnd"
        case amountTitle = "AmountTitle"
        case customValue1 = "CustomValue1"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int64.self, forKey: .id)
        sum = (try? c.decode(Decimal.self, forKey: .sum)) ?? 0
        direction = try c.decode(Int.self, forKey: .direction)
        categoryId = (try? c.decode(Int64.self, forKey: .categoryId)) ?? 0
        categoryTitle = (try? c.decode(String.self, forKey: .categoryTitle)) ?? ""
        subCategory = (try? c.decode(String.self, forKey: .subCategory)) ?? ""
        description = (try? c.decode(String.self, forKey: .description)) ?? ""
        amount = (try? c.decode(Decimal.self, forKey: .amount)) ?? 0
        amountTitle = (try? c.decode(String.self, forKey: .amountTitle)) ?? ""
        customValue1 = try? c.decode(String.self, forKey: .customValue1)

        let formatter = DateFormatter.moneyInfoFormatter
        let dateStr = try c.decode(String.self, forKey: .accountingDate)
        accountingDate = formatter.date(from: dateStr) ?? Date()
        let beginStr = try c.decode(String.self, forKey: .amountIntervalBegin)
        amountIntervalBegin = formatter.date(from: beginStr) ?? Date()
        let endStr = try c.decode(String.self, forKey: .amountIntervalEnd)
        amountIntervalEnd = formatter.date(from: endStr) ?? Date()
    }
}

// MARK: - MoneyInfo

struct MoneyInfo: Decodable {
    let finesCalculationsSum: Decimal
    let finesPaymentsSum: Decimal
    let finesBalance: Decimal
    let firstDebtDate: Date
    let serviceBalances: [ServiceBalance]
    let rentSumInfo: ServiceBalance
    let addServicesSumInfo: ServiceBalance
    let otherSumInfo: ServiceBalance
    let finesSumInfo: ServiceBalance
    let depositSumInfo: ServiceBalance
    let contractPrePaymentsSum: Decimal
    let notPaydCalculationsSumTotal: Decimal
    let notPaydCalculationsSumCurrent: Decimal
    let servicesTotalSum: Decimal
    let servicesTotalPaydPaysSum: Decimal
    let servicesPaymentState: Int
    let depositBalance: Decimal
    let paydDepositSum: Decimal
    let aviableDepositSum: Decimal
    let depositOverSum: Decimal
    let depositState: Int
    let depositSum: Decimal
    let depositIsPayd: Bool
    let paymentsBalance: Decimal
    let paymentsBalanceIn: Decimal
    let paymentsBalanceOut: Decimal

    enum CodingKeys: String, CodingKey {
        case finesCalculationsSum = "FinesCalculationsSum"
        case finesPaymentsSum = "FinesPaymentsSum"
        case finesBalance = "FinesBalance"
        case firstDebtDate = "FirstDebtDate"
        case serviceBalances = "ServiceBalances"
        case rentSumInfo = "RentSumInfo"
        case addServicesSumInfo = "AddServicesSumInfo"
        case otherSumInfo = "OtherSumInfo"
        case finesSumInfo = "FinesSumInfo"
        case depositSumInfo = "DepositSumInfo"
        case contractPrePaymentsSum = "ContractPrePaymentsSum"
        case notPaydCalculationsSumTotal = "NotPaydCalculationsSumTotal"
        case notPaydCalculationsSumCurrent = "NotPaydCalculationsSumCurrent"
        case servicesTotalSum = "ServicesTotalSum"
        case servicesTotalPaydPaysSum = "ServicesTotalPaydPaysSum"
        case servicesPaymentState = "ServicesPaymentState"
        case depositBalance = "DepositBalance"
        case paydDepositSum = "PaydDepositSum"
        case aviableDepositSum = "AviableDepositSum"
        case depositOverSum = "DepositOverSum"
        case depositState = "DepositState"
        case depositSum = "DepositSum"
        case depositIsPayd = "DepositIsPayd"
        case paymentsBalance = "PaymentsBalance"
        case paymentsBalanceIn = "PaymentsBalanceIn"
        case paymentsBalanceOut = "PaymentsBalanceOut"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        finesCalculationsSum = (try? c.decode(Decimal.self, forKey: .finesCalculationsSum)) ?? 0
        finesPaymentsSum = (try? c.decode(Decimal.self, forKey: .finesPaymentsSum)) ?? 0
        finesBalance = (try? c.decode(Decimal.self, forKey: .finesBalance)) ?? 0
        serviceBalances = (try? c.decode([ServiceBalance].self, forKey: .serviceBalances)) ?? []
        rentSumInfo = try c.decode(ServiceBalance.self, forKey: .rentSumInfo)
        addServicesSumInfo = try c.decode(ServiceBalance.self, forKey: .addServicesSumInfo)
        otherSumInfo = try c.decode(ServiceBalance.self, forKey: .otherSumInfo)
        finesSumInfo = try c.decode(ServiceBalance.self, forKey: .finesSumInfo)
        depositSumInfo = try c.decode(ServiceBalance.self, forKey: .depositSumInfo)
        contractPrePaymentsSum = (try? c.decode(Decimal.self, forKey: .contractPrePaymentsSum)) ?? 0
        notPaydCalculationsSumTotal = (try? c.decode(Decimal.self, forKey: .notPaydCalculationsSumTotal)) ?? 0
        notPaydCalculationsSumCurrent = (try? c.decode(Decimal.self, forKey: .notPaydCalculationsSumCurrent)) ?? 0
        servicesTotalSum = (try? c.decode(Decimal.self, forKey: .servicesTotalSum)) ?? 0
        servicesTotalPaydPaysSum = (try? c.decode(Decimal.self, forKey: .servicesTotalPaydPaysSum)) ?? 0
        servicesPaymentState = (try? c.decode(Int.self, forKey: .servicesPaymentState)) ?? 0
        depositBalance = (try? c.decode(Decimal.self, forKey: .depositBalance)) ?? 0
        paydDepositSum = (try? c.decode(Decimal.self, forKey: .paydDepositSum)) ?? 0
        aviableDepositSum = (try? c.decode(Decimal.self, forKey: .aviableDepositSum)) ?? 0
        depositOverSum = (try? c.decode(Decimal.self, forKey: .depositOverSum)) ?? 0
        depositState = (try? c.decode(Int.self, forKey: .depositState)) ?? 0
        depositSum = (try? c.decode(Decimal.self, forKey: .depositSum)) ?? 0
        depositIsPayd = (try? c.decode(Bool.self, forKey: .depositIsPayd)) ?? false
        paymentsBalance = (try? c.decode(Decimal.self, forKey: .paymentsBalance)) ?? 0
        paymentsBalanceIn = (try? c.decode(Decimal.self, forKey: .paymentsBalanceIn)) ?? 0
        paymentsBalanceOut = (try? c.decode(Decimal.self, forKey: .paymentsBalanceOut)) ?? 0

        let formatter = DateFormatter.moneyInfoFormatter
        let dateStr = try c.decode(String.self, forKey: .firstDebtDate)
        firstDebtDate = formatter.date(from: dateStr) ?? Date()
    }
}

// MARK: - ServiceBalance

struct ServiceBalance: Decodable {
    let serviceType: Int
    let calculatedSum: Decimal
    let paydSum: Decimal
    let balance: Decimal

    enum CodingKeys: String, CodingKey {
        case serviceType = "ServiceType"
        case calculatedSum = "CalculatedSum"
        case paydSum = "PaydSum"
        case balance = "Balance"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        serviceType = (try? c.decode(Int.self, forKey: .serviceType)) ?? 0
        calculatedSum = (try? c.decode(Decimal.self, forKey: .calculatedSum)) ?? 0
        paydSum = (try? c.decode(Decimal.self, forKey: .paydSum)) ?? 0
        balance = (try? c.decode(Decimal.self, forKey: .balance)) ?? 0
    }
}

// MARK: - Helpers

private extension DateFormatter {
    static let moneyInfoFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yyyy HH:mm:ss"
        f.locale = Locale(identifier: "ru_RU")
        return f
    }()
}
