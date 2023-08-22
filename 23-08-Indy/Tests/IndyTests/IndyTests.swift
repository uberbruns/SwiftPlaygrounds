import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest


#if canImport(IndyMacros)
import IndyMacros

let testMacros: [String: Macro.Type] = [
  "Dependent": DependentMacro.self,
]
#endif


final class IndyTests: XCTestCase {
  func testMacro() throws {
    assertMacroExpansion(
      """
      @Dependent
      class MyService {
          @Dependency
          var client: Client

          @Dependency
          var manager: Manager
      }
      """,
      expandedSource: """
      class MyService {
          @Dependency
          var client: Client

          @Dependency
          var manager: Manager

          init(client: Client, manager: Manager) {
              self.client = client
              self.manager = manager
          }

          init(dependencies: some MyServiceDependencies) {
              self.client = dependencies.client
              self.manager = dependencies.manager
          }
      }

      protocol MyServiceDependencies: Dependencies {
          var client: Client {
              get
          }
          var manager: Manager {
              get
          }
      }
      """,
      macros: testMacros
    )
  }
}
