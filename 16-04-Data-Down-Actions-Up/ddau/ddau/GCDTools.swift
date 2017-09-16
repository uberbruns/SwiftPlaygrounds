import Foundation

/**
 Takes a block and executes it after a certain amount of time
 on the main thread
 */
public func dispatchAfterTime(_ time: Double, action: @escaping () -> ()) {
    if time == 0 {
        action()
        return
    }
    
    let nanoSeconds: Int64 = Int64(Double(NSEC_PER_SEC) * time);
    let when = DispatchTime.now() + Double(nanoSeconds) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: when, execute: {
        action()
    });
}


/**
 Takes a block and executes it after a certain amount of time
 on the main thread.
 */
public func dispatchAfter(time: Int, action: @escaping () -> ()) {
    dispatchAfterTime(Double(time), action: action)
}


/**
 Takes a block and executes it on the main thread.
 - Parameter sync: Default is false. If `true` the function waits until the block is executed
 */
public func dispatchOnMainQueue(sync: Bool = false, code: @escaping () -> ()) {
    if Thread.isMainThread {
        code()
    } else {
        let mainQueue = DispatchQueue.main
        if sync {
            mainQueue.sync(execute: code)
        } else {
            mainQueue.async(execute: code)
        }
    }
}


/**
 Takes a block and executes it on a background thread thread.
 - Parameter sync: Default is false. If `true` the function waits until the block is executed
 */
public func dispatchInBackground(sync: Bool = false, code: @escaping () -> ()) {
    let backgroundQueue = DispatchQueue.global(qos: .background)
    if sync {
        backgroundQueue.sync(execute: code)
    } else {
        backgroundQueue.async(execute: code)
    }
}
