//
//  ContentView.swift
//  AsyncPlayground
//
//  Created by Karsten Bruns on 17.01.23.
//

import SwiftUI

struct ContentView: View {
  @Binding var document: AsyncPlaygroundDocument

  @StateObject var model = ViewModel()

  var body: some View {
    TextEditor(text: $document.text)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(document: .constant(AsyncPlaygroundDocument()))
  }
}


class ViewModel: ObservableObject {
  @Attached var test = TestActor()
}





