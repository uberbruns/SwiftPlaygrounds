import XCTest
@testable import DataSource

final class DataSourceTests: XCTestCase {
    func testExample() throws {
      let dataSource = ShipDataSource()
      print(dataSource.index)
      print(dataSource.get(id: "1701")!)
    }
}
