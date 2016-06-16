import Foundation

/**
 Takes a block and executes it after a certain amount of time
 on the main thread
 */
public func dispatchAfterTime(time: Double, action: () -> ()) {
    if time == 0 {
        action()
        return
    }
    
    let nanoSeconds: Int64 = Int64(Double(NSEC_PER_SEC) * time);
    let when = dispatch_time(DISPATCH_TIME_NOW, nanoSeconds)
    dispatch_after(when, dispatch_get_main_queue(), {
        action()
    });
}


/**
 Takes a block and executes it after a certain amount of time
 on the main thread.
 */
public func dispatchAfter(time time: Int, action: () -> ()) {
    dispatchAfterTime(Double(time), action: action)
}


/**
 Takes a block and executes it on the main thread.
 - Parameter sync: Default is false. If `true` the function waits until the block is executed
 */
public func dispatchOnMainQueue(sync sync: Bool = false, code: () -> ()) {
    if NSThread.isMainThread() {
        code()
    } else {
        let mainQueue = dispatch_get_main_queue()
        if sync {
            dispatch_sync(mainQueue, code)
        } else {
            dispatch_async(mainQueue, code)
        }
    }
}


/**
 Takes a block and executes it on a background thread thread.
 - Parameter sync: Default is false. If `true` the function waits until the block is executed
 */
public func dispatchInBackground(sync sync: Bool = false, code: () -> ()) {
    let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
    if sync {
        dispatch_sync(backgroundQueue, code)
    } else {
        dispatch_async(backgroundQueue, code)
    }
}