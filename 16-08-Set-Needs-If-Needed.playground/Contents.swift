import Foundation
import PlaygroundSupport

import UIKit


UIFeedbackGenerator


PlaygroundPage.current.needsIndefiniteExecution = true


class DispatchHelper {

    private var code = [String: () -> ()]()

    /// Adds a block that will be executed in one of the next run cycles
    func addBlock(identifier: String, qualityOfService: QualityOfService? = nil, block: @escaping () -> ()) {
        guard code[identifier] == nil, let queue = OperationQueue.current else {
            return
        }

        // Assign default qos value if needed
        let qualityOfService = qualityOfService ?? queue.qualityOfService

        // Add block
        code[identifier] = block

        // Operation
        let blockOperation = BlockOperation() { [weak self] in
            self?.executeBlock(identifier: identifier)
        }
        blockOperation.qualityOfService = qualityOfService

        // Execute in one of the next run loop cycles
        queue.addOperation(blockOperation)
    }

    /// Executes a block immediatly
    func executeBlock(identifier: String) {
        let block = code.removeValue(forKey: identifier)
        block?()
    }
}



class Example {

    let dispatchHelper = DispatchHelper()


    func setNeedsBoo() {
        dispatchHelper.addBlock(identifier: "boo", qualityOfService: .userInteractive, block: boo)
    }


    func booIfNeeded() {
        dispatchHelper.executeBlock(identifier: "boo")
    }


    private func boo() {
        print("👻")
    }
}


let example = Example()
example.setNeedsBoo()
example.setNeedsBoo()
example.setNeedsBoo()
example.booIfNeeded() // prints "👻"
example.setNeedsBoo()
example.setNeedsBoo() // prints "👻"
