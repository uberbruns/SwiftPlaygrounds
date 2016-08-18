//: Playground - noun: a place where people can play

import UIKit
import XCPlayground



class WorldView: UIView {

    let follower = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
    let topSpeed: CGFloat = 640
    let deceleration: CGFloat = 640
    let acceleration: CGFloat = 640
    var velocity: CGFloat = 0


    let target = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
    var displayLink: CADisplayLink!

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .darkGrayColor()

        follower.backgroundColor = .redColor()
        follower.layer.cornerRadius = 22
        addSubview(follower)

        target.backgroundColor = .whiteColor()
        target.layer.cornerRadius = 6
        addSubview(target)

        displayLink = CADisplayLink(target: self, selector: #selector(loop(_:)))
        displayLink.frameInterval = 1
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let loc = touches[touches.startIndex].locationInView(self)
        target.center = loc
    }


    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let loc = touches[touches.startIndex].locationInView(self)
        target.center = loc
    }


    func loop(displayLink: CADisplayLink) {
        let deltaX = target.center.x - follower.center.x
        let deltaY = target.center.y - follower.center.y
        let distance = sqrt(pow(deltaX, 2) + pow(deltaY, 2))
        let dt = CGFloat(displayLink.duration) * CGFloat(displayLink.frameInterval)

        if distance <= (velocity * dt) {
            follower.center.x = target.center.x
            follower.center.y = target.center.y
            velocity = 0
            return
        }

        let decelDistance = pow(velocity, 2) / (2 * deceleration)

        if (distance > decelDistance) {
            velocity = min(velocity + acceleration * dt, topSpeed);
        } else {
            velocity = max(velocity - deceleration * dt, 0)
        }

        let angle = atan2(deltaY, deltaX)
        let cosangle = cos(angle)
        let sinangle = sin(angle)
        
        follower.center.x += velocity * cosangle * dt
        follower.center.y += velocity * sinangle * dt
    }
}


let worldView = WorldView(frame: CGRect(x: 0, y: 0, width: 100, height: 700))
XCPlaygroundPage.currentPage.liveView = worldView
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
