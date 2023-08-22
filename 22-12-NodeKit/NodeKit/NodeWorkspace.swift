import SwiftUI


struct TileConfiguration {
  let tileSize: CGSize
  let horizontalExpansion: Int
  let verticalExpansion: Int
  let size: CGSize

  init(tileSize: CGSize, horizontalExpansion: Int, verticalExpansion: Int) {
    self.tileSize = tileSize
    self.horizontalExpansion = horizontalExpansion
    self.verticalExpansion = verticalExpansion
    self.size = CGSize(
      width: CGFloat(1 + 2 * horizontalExpansion) * tileSize.width,
      height: CGFloat(1 + 2 * verticalExpansion) * tileSize.height
    )
  }

  func scaled(by factor: CGFloat) -> TileConfiguration {
    let width = max(50, min(250, tileSize.width * factor))
    let height = max(50, min(250, tileSize.height * factor))
    return TileConfiguration(
      tileSize: CGSize(width: width, height: height),
      horizontalExpansion: horizontalExpansion,
      verticalExpansion: verticalExpansion
    )
  }
}


extension TileConfiguration {
  static let standard = TileConfiguration(
    tileSize: CGSize(width: 100, height: 100),
    horizontalExpansion: 50000,
    verticalExpansion: 50000
  )
}



struct TiledWorkspaceView<TileView: View>: View {

  let content: (TileDescriptor) -> TileView

  @State var visibleTiles: [TileDescriptor: TileView]
  @State var configuration: TileConfiguration
  @GestureState var scale: CGFloat = 1.0

  init(configuration: TileConfiguration, content: @escaping (TileDescriptor) -> TileView) {
    self.configuration = configuration
    self.content = content
    self.visibleTiles = [:]
  }

  var body: some View {
    let size = configuration.size
    GeometryReader { workspaceGeometry in
      ScrollView([.horizontal, .vertical], showsIndicators: false) {
        ScrollViewReader { scrollView in
          GeometryReader { scrollContentGeometry in
            ForEach(Array(visibleTiles.keys)) { tile in
              visibleTiles[tile]
                .frame(width: tile.frame.width, height: tile.frame.height)
                .offset(
                  x: tile.frame.origin.x,
                  y: tile.frame.origin.y
                )
            }
            .onChange(of: scrollContentGeometry.tiles(
              with: configuration,
              zoomedTileSize: configuration.tileSize,
              bounds: workspaceGeometry.size
            )) { tiles in
              var newVisibleTiles = [TileDescriptor: TileView]()
              for tile in tiles {
                newVisibleTiles[tile] = visibleTiles[tile] ?? content(tile)
              }
              visibleTiles = newVisibleTiles
            }
          }
          .frame(width: size.width, height: size.height, alignment: .center)
          .id("ScrollViewContent")
          .onAppear {
            scrollView.scrollTo("ScrollViewContent", anchor: .center)
          }
        }
      }
    }
    .coordinateSpace(name: "ScrollView")
    .gesture(
      MagnificationGesture()
        .updating($scale, body: { value, scale, trans in
          scale = value.magnitude
        })
    )
    .onChange(of: scale) { newValue in
      configuration = configuration.scaled(by: newValue)
    }
  }
}


struct TileDescriptor: Hashable, Identifiable {
  var id: String {
    "\(x)x\(y)"
  }

  let x: Int
  let y: Int
  let frame: CGRect

  func hash(into hasher: inout Hasher) {
    hasher.combine(x)
    hasher.combine(y)
  }
}


extension GeometryProxy {
  func tiles(with configuration: TileConfiguration, zoomedTileSize: CGSize, bounds: CGSize) -> Set<TileDescriptor> {
    let tileSize = zoomedTileSize

    let frame = frame(in: .named("ScrollView"))
    let minX = Int(floor(-frame.origin.x / tileSize.width))
    let maxX = Int(ceil((-frame.origin.x + bounds.width) / tileSize.width))
    let minY = Int(floor(-frame.origin.y / tileSize.height))
    let maxY = Int(ceil((-frame.origin.y + bounds.height) / tileSize.height))

    var result = Set<TileDescriptor>()
    for x in minX ... maxX {
      for y in minY ... maxY {
        result.insert(
          TileDescriptor(
            x: x - configuration.horizontalExpansion,
            y: y - configuration.verticalExpansion,
            frame: CGRect(
              origin: CGPoint(
                x: CGFloat(x) * tileSize.width,
                y: CGFloat(y) * tileSize.height
              ),
              size: configuration.tileSize
            )
          )
        )
      }
    }
    return result
  }
}
