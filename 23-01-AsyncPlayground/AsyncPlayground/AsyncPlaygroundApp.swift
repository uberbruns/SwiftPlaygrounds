//
//  AsyncPlaygroundApp.swift
//  AsyncPlayground
//
//  Created by Karsten Bruns on 17.01.23.
//

import SwiftUI

@main
struct AsyncPlaygroundApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: AsyncPlaygroundDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
