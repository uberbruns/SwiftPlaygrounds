//: Playground - noun: a place where people can play

import UIKit


struct ImageConfiguation {
    var scale: Float = 0.0
}


struct Image {
    let config: ImageConfiguation
    init(configurationFunc: (inout config: ImageConfiguation) -> Void) {
        var config = ImageConfiguation()
        configurationFunc(config: &config)
        self.config = config
    }
}


let image = Image { (inout config: ImageConfiguation) -> Void in
    config.scale = 2.0
}