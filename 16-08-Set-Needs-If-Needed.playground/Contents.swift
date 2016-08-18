import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true


class DispatchHelper {

    private var code = [String: () -> ()]()

    /// Adds a block that will be executed in one of the next run cycles
    func addBlock(identifier: String, qualityOfService: QualityOfService? = nil, block: () -> ()) {
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


    func setNeedsFoo() {
        dispatchHelper.addBlock(identifier: "boo", qualityOfService: .userInteractive, block: boo)
    }


    func fooIfNeeded() {
        dispatchHelper.executeBlock(identifier: "boo")
    }


    private func boo() {
        print("👻")
    }
}


let example = Example()
example.setNeedsFoo()
example.setNeedsFoo()
example.setNeedsFoo()
example.fooIfNeeded() // prints "👻"
example.setNeedsFoo()
example.setNeedsFoo() // prints "👻"



