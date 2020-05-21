//
//  main.swift
//  DataSheet
//
//  Created by Karsten Bruns on 31.03.19.
//  Copyright © 2019 bruns.me. All rights reserved.
//

import Combine
import Foundation



class Hello {
    @Mutable var apples = 5
    @Mutable var pears = 3
    
    @Computed var sum: Int
    @Computed var title: String

    init() {
        $sum.zip($apples, $pears, +)
        $title.map($sum) { "\($0) Fruits!" }
    }
}

var cancellables = Set<AnyCancellable>()
let hello = Hello()

hello.$sum.sink { sum in
    print(hello.title)
    print("Sum changed to: \(sum)")
}.store(in: &cancellables)

hello.pears += 2
hello.apples = 9
