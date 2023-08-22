import Foundation
import Indy


// MARK: - Services

@Dependent
class HTTPCallBuilder { }

@Dependent
class MyHTTPClient {
  @Dependency
  let builder: HTTPCallBuilder
}

@Dependent
class MyService {
  @Dependency
  let myHTTPClient: MyHTTPClient
}


// MARK: - Dependency Container

class LiveDependencies:
  HTTPCallBuilderDependencies,
  MyHTTPClientDependencies,
  MyServiceDependencies
{
  static let shared = LiveDependencies()

  lazy var builder: HTTPCallBuilder = {
    HTTPCallBuilder()
  }()

  lazy var myHTTPClient: MyHTTPClient = {
    MyHTTPClient(dependencies: self)
  }()
}


extension Dependencies where Self == LiveDependencies {
  static var live: Self {
    return LiveDependencies.shared
  }
}


// MARK: - Usage

let myService = MyService(dependencies: .live)
