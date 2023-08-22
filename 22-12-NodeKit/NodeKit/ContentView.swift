import SwiftUI


struct ContentView: View {
  var body: some View {
    TiledWorkspaceView(configuration: .standard) { tile in
      Text("\(tile.x)x\(tile.y)")
        .border(Color.red)
        .id(tile.id)
    }
    .frame(maxWidth: 1024, maxHeight: 1024)
  }
}




struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
