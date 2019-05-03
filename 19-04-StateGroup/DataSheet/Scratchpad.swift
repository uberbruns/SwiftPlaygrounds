//
//  Scratchpad.swift
//  DataSheet
//
//  Created by Karsten Bruns on 08.04.19.
//  Copyright © 2019 bruns.me. All rights reserved.
//

import Foundation


protocol X: AnyObject {

}

class ClassA: X { }


class ClassA2: ClassA { }


protocol ProtocolA {
  var varA: X { get }
}


class ImplementationA {
  var varA = ClassA2()
}


// Why can't a subclass establish protocol conformance in place of superclass
