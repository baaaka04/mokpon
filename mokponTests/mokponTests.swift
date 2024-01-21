import XCTest
@testable import mokpon

final class mokponTests: XCTestCase {


    func testInitializationChartsDate() {
        let testDate = ChartsDate(month: 1, year: 2024)
        
        XCTAssertEqual(testDate.currentPeriod.year, 2024)
        XCTAssertEqual(testDate.currentPeriod.month, 1)
        XCTAssertEqual(testDate.previousMonthPeriod.year, 2023)
        XCTAssertEqual(testDate.previousMonthPeriod.month, 12)
        XCTAssertEqual(testDate.previousYearPeriod.year, 2023)
        XCTAssertEqual(testDate.previousYearPeriod.month, 1)
        
    }
    
    func testMutatingChartsDatePeriod() {
        var testDate = ChartsDate(month: 2, year: 2024)
        
        testDate.decreaseMonth()
        
        XCTAssertEqual(testDate.currentPeriod.month, 1)
        XCTAssertEqual(testDate.currentPeriod.year, 2024)
        
        testDate.decreaseMonth()

        XCTAssertEqual(testDate.currentPeriod.month, 12)
        XCTAssertEqual(testDate.currentPeriod.year, 2023)
        XCTAssertEqual(testDate.previousYearPeriod.month, 12)
        XCTAssertEqual(testDate.previousYearPeriod.year, 2022)
        XCTAssertEqual(testDate.previousMonthPeriod.month, 11)
        XCTAssertEqual(testDate.previousMonthPeriod.year, 2023)
        
        testDate.increaseMonth()
        XCTAssertEqual(testDate.previousMonthPeriod.month, 12)
        XCTAssertEqual(testDate.previousMonthPeriod.year, 2023)
        
        
    }
    
 

}
