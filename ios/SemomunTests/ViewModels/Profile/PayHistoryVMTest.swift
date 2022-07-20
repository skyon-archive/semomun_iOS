//
//  PayHistoryVMTest.swift
//  semomunTests
//
//  Created by SEONG YEOL YI on 2022/04/06.
//

@testable import semomun
import XCTest

class PayHistoryVMTest: XCTestCase {
    
    private let networkUsecase = MockPayNetworkUsecase(payHistoryCount: 55)
    private var vm: PayHistoryVM!
    
    override func setUp() {
        self.vm = PayHistoryVM(onlyPurchaseHistory: false, networkUsecase: networkUsecase)
    }
    
    func testInitialState() {
        XCTAssertEqual(self.vm.remainingSemopay, 0)
        XCTAssertEqual(self.vm.purchaseOfEachMonth.count, 0)
    }
    
    func testInitPublished() {
        self.vm.initPublished()
        self.checkMonthGroupValidity(group: self.vm.purchaseOfEachMonth, expectedSize: 25)
        XCTAssertEqual(vm.remainingSemopay, networkUsecase.remainingSemopay)
    }
    
    func testPagination() {
        // Page 1 (0~24)
        self.vm.initPublished()
        
        // Page 2 (25~49)
        self.vm.tryFetchMoreList()
        self.checkMonthGroupValidity(group: self.vm.purchaseOfEachMonth, expectedSize: 50)
        XCTAssertEqual(vm.remainingSemopay, networkUsecase.remainingSemopay)
        
        // Page 3 (50~55)
        self.vm.tryFetchMoreList()
        self.checkMonthGroupValidity(group: self.vm.purchaseOfEachMonth, expectedSize: 55)
        XCTAssertEqual(vm.remainingSemopay, networkUsecase.remainingSemopay)
    }
    
    /// VM이 DB에서 전달받은 값을 월별로 올바르게 묶었는지 확인
    private func checkMonthGroupValidity(group: [(section: String, content: [PurchasedItem])], expectedSize: Int) {
        // 정렬 확인
        group.forEach { _, content in
            XCTAssert(content == content.sorted(by: { $0.createdDate > $1.createdDate }))
        }
        
        // 개수 확인
        let contentCount = group.reduce(0, { $0 + $1.content.count })
        XCTAssertEqual(contentCount, expectedSize)
        
        // DB값과 매칭 여부 확인
        for payHistory in networkUsecase.wholePayHistories[0..<expectedSize] {
            self.checkGroupContainsItem(group: group, payHistoryOfDB: payHistory)
        }
    }
    
    /// VM이 월별로 묶은 자료구조에 특정 PayHistoryofDB의 존재유무 확인
    private func checkGroupContainsItem(group: [(section: String, content: [PurchasedItem])], payHistoryOfDB: PayHistoryofDB) {
        guard let section = group.first(where: { $0.section == payHistoryOfDB.createdDate.yearMonthText }) else {
            XCTFail()
            return
        }
        XCTAssert(
            section.content.contains(where: { purchasedItem in
                purchasedItem.createdDate == payHistoryOfDB.createdDate &&
                purchasedItem.descriptionImageID == payHistoryOfDB.item.workbook.bookcover &&
                purchasedItem.title == payHistoryOfDB.item.workbook.title &&
                purchasedItem.transaction == Transaction(amount: payHistoryOfDB.amount)
            })
        )
    }
}
