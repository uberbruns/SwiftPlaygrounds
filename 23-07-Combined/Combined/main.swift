import Combine
import Foundation


protocol Combined: Publisher {
  associatedtype OutputPublisher where OutputPublisher: Publisher
  var output: OutputPublisher { get }
}



extension Combined where OutputPublisher.Failure == Never {
  func receive<S>(subscriber: S) where S : Subscriber, S.Failure == OutputPublisher.Failure, S.Input == OutputPublisher.Output {
    output.receive(subscriber: subscriber)
  }
}


struct DataSource: Combined {
  var output: some Publisher {
    Just("Hello")
  }
}
