import Cocoa
import AVFoundation
import AVKit
import QuartzCore
import XCPlayground

var view = NSView(frame:
    NSRect(x: 0, y: 0, width: 640, height: 480))

var session = AVCaptureSession()

session.sessionPreset = AVCaptureSessionPresetMedium
session.beginConfiguration()
session.commitConfiguration()

var input : AVCaptureDeviceInput! = nil
var err : NSError?
var devices : [AVCaptureDevice] = AVCaptureDevice.devices() as! [AVCaptureDevice]

for device in devices {
    print(device)
    if device.hasMediaType(AVMediaTypeVideo) && device.supportsAVCaptureSessionPreset(AVCaptureSessionPresetMedium) {
        
        input = try! AVCaptureDeviceInput(device: device as AVCaptureDevice) as AVCaptureDeviceInput
        if session.canAddInput(input) {
            session.addInput(input)
            break
        }
    }
}


let key: NSString = kCVPixelBufferPixelFormatTypeKey
let value: Int = Int(kCVPixelFormatType_32BGRA)

var settings: [NSObject : AnyObject] = [key:value]

var output = AVCaptureVideoDataOutput()
output.videoSettings = settings
output.alwaysDiscardsLateVideoFrames = true

if session.canAddOutput(output) {
    session.addOutput(output)
}

var captureLayer = AVCaptureVideoPreviewLayer(session: session)

view.wantsLayer = true
view.layer = captureLayer

session.startRunning()

XCPShowView("camera", view: view)