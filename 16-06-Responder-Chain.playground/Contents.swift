import UIKit

// Message Type
struct Action<TargetType> {
    let action: (TargetType) -> ()
    
    
    init(_ action: (TargetType) -> ()) {
        self.action = action
    }

    
    func deliverTo(object: ActionResponder) {
        if let targetObject = object as? TargetType {
            action(targetObject)
        }
    }
}


// Action Responder Protocol
protocol ActionResponder : class {
    var parentActionResponder: ActionResponder? { get }
}


extension ActionResponder {
    
    func sendAction<T>(action: Action<T>) {
        var actionResponder: ActionResponder? = self
        while actionResponder != nil {
            action.deliverTo(actionResponder!)
            actionResponder = actionResponder!.parentActionResponder
        }
    }
}


// Target Protocol
protocol DataSource {
    func requestData()
}


// Receiver
class ReceivingObject : ActionResponder, DataSource {

    var parentActionResponder: ActionResponder?

    func requestData() {
        print("Action Received")
    }
}


// Not Receiver
class NotReceivingObject : ActionResponder {
    var parentActionResponder: ActionResponder?
}



let obj4 = ReceivingObject()

let obj3 = NotReceivingObject()
obj3.parentActionResponder = obj4

let obj2 = ReceivingObject()
obj2.parentActionResponder = obj3

let obj1 = NotReceivingObject()
obj1.parentActionResponder = obj2

let action = Action<DataSource>({ $0.requestData() })
obj1.sendAction(action)
