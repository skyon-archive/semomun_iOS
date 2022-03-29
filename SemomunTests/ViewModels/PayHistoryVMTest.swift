//
//  PayHistoryVMTest.swift
//  semomunTests
//
//  Created by SEONG YEOL YI on 2022/03/29.
//

@testable import semomun
import XCTest

class MyPurchasesVMTest: XCTestCase {
    
    // MockPayNetworkUsecase의 구현에 따라 구매 목록은 110/2=55개
    private let networkUsecase = MockPayNetworkUsecase(payHistoryCount: 110)
    private var vm: PayHistoryVM!
    
    override func setUp() {
        self.vm = PayHistoryVM(onlyPurchaseHistory: true, networkUsecase: networkUsecase)
    }
    
    func testInitialState() {
        XCTAssertEqual(self.vm.remainingSemopay, 0)
        XCTAssertEqual(self.vm.purchaseOfEachMonth.count, 0)
    }
    
    func testInitPublished() {
        self.vm.initPublished()
        XCTAssertEqual(vm.remainingSemopay, networkUsecase.remainingSemopay)
        
        let dataGroupedByVM = vm.purchaseOfEachMonth
        let contentCount = dataGroupedByVM.reduce(0, { $0 + $1.content.count })
        XCTAssertEqual(contentCount, networkUsecase.pageSize)
        
        for payHistory in networkUsecase.purchaseHistories[0..<networkUsecase.pageSize] {
            XCTAssert(groupContainsItem(group: dataGroupedByVM, payHistoryOfDB: payHistory))
        }
    }
    
    func testPagination() {
        // Page 1 (0~24)
        self.vm.initPublished()
        
        // Page 2 (25~49)
        self.vm.tryFetchMoreList()
        var dataGroupedByVM = self.vm.purchaseOfEachMonth
        
        // 정렬 확인
        dataGroupedByVM.forEach { _, content in
            XCTAssert(content == content.sorted(by: { $0.createdDate > $1.createdDate }))
        }
        
        // 개수 확인
        var contentCount = dataGroupedByVM.reduce(0, { $0 + $1.content.count })
        XCTAssertEqual(contentCount, 50)
        
        // DB값과 매칭여부 확인
        for payHistory in networkUsecase.purchaseHistories[0..<50] {
            XCTAssert(groupContainsItem(group: dataGroupedByVM, payHistoryOfDB: payHistory))
        }
        
        // Page 3 (50~55)
        self.vm.tryFetchMoreList()
        dataGroupedByVM = self.vm.purchaseOfEachMonth
        
        dataGroupedByVM.forEach { _, content in
            XCTAssert(content == content.sorted(by: { $0.createdDate > $1.createdDate }))
        }
        
        contentCount = dataGroupedByVM.reduce(0, { $0 + $1.content.count })
        XCTAssertEqual(contentCount, 55)
        
        for payHistory in networkUsecase.purchaseHistories[0..<55] {
            XCTAssert(groupContainsItem(group: dataGroupedByVM, payHistoryOfDB: payHistory))
        }
    }
    
    private func groupContainsItem(group: [(section: String, content: [PurchasedItem])], payHistoryOfDB: PayHistoryofDB) -> Bool {
        guard let section = group.first(where: { $0.section == payHistoryOfDB.createdDate.yearMonthText }) else {
            return false
        }
        return section.content.contains(where: { purchasedItem in
            purchasedItem.createdDate == payHistoryOfDB.createdDate &&
            purchasedItem.descriptionImageID == payHistoryOfDB.item.workbook.bookcover &&
            purchasedItem.title == payHistoryOfDB.item.workbook.title &&
            purchasedItem.transaction == Transaction(amount: payHistoryOfDB.amount)
        })
    }
}

// MARK: Supporting extensions
extension Transaction: Equatable {
    public static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        guard lhs.amount == rhs.amount else { return false }
        
        switch (lhs, rhs) {
        case (.free, .free), (.charge, .charge), (.purchase, .purchase):
            return true
        default:
            return false
        }
    }
}

extension PurchasedItem: Equatable {
    public static func == (lhs: PurchasedItem, rhs: PurchasedItem) -> Bool {
        return lhs.createdDate == rhs.createdDate &&
        lhs.transaction == rhs.transaction &&
        lhs.descriptionImageID == rhs.descriptionImageID &&
        lhs.title == rhs.title
    }
}
