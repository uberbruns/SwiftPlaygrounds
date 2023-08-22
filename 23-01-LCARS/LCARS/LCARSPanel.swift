import SwiftUI


struct LCARSPanel: View {

  typealias CalcX = (CGFloat) -> CGFloat
  typealias CalcY = (CGFloat) -> CGFloat

  let patchSize: CGSize
  let rows: CGFloat
  let columns: CGFloat
  let content: [LCARSPatch]
  let padding: CGFloat

  var canvasSize: CGSize {
    CGSize(
      width: patchSize.width * columns,
      height: patchSize.height * rows
    )
  }

  init(patchSize: CGSize, rows: CGFloat, columns: CGFloat, padding: CGFloat, @LCARSPanelContent content: (_ calcX: CalcX, _ calcY: CalcX) -> [LCARSPatch]) {

    let calcX: CalcX = { x in
      return (x * patchSize.width) - 2 * padding
    }

    let calcY: CalcX = { y in
      return (y * patchSize.height) - 2 * padding
    }

    self.patchSize = patchSize
    self.rows = CGFloat(rows)
    self.columns = CGFloat(columns)
    self.padding = padding
    self.content = content(calcX, calcY)
  }

  var body: some View {
    ZStack {
      ForEach(content) { patch in
        renderPatch(patch: patch)
      }
      .frame(
        width: canvasSize.width,
        height: canvasSize.height,
        alignment: .topLeading
      )
    }
    .padding(padding)
    .background(.black)
  }

  func renderPatch(patch: LCARSPatch) -> some View {
    patch.content
      .padding(padding)
      .frame(
        width: patch.width * patchSize.width,
        height: patch.height * patchSize.height
      )
      .offset(
        x: patch.x * patchSize.width,
        y: patch.y * patchSize.height
      )
  }
}


struct LCARSPatch: Identifiable {

  let x: CGFloat
  let y: CGFloat
  let width: CGFloat
  let height: CGFloat
  let content: AnyView

  let id: Int

  init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, @ViewBuilder content: () -> some View) {
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.content = AnyView(content())

    var hasher = Hasher()
    hasher.combine(x)
    hasher.combine(y)
    hasher.combine(width)
    hasher.combine(height)

    self.id = hasher.finalize()
  }
}


@resultBuilder struct LCARSPanelContent {
  static func buildBlock(_ components: LCARSPatch...) -> [LCARSPatch] {
    components
  }
}



struct LCARSPanel_Previews: PreviewProvider {
  static var previews: some View {
    LCARSPanel(patchSize: CGSize(width: 16, height: 16), rows: 48, columns: 64, padding: 2) { x, y in
      LCARSPatch(x: 0, y: 0, width: 8, height: 3) {
        Text("Hello")
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(.yellow)
      }
      LCARSPatch(x: 0, y: 3, width: 8, height: 3) {
        Text("World")
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(.blue)
      }
      LCARSPatch(x: 8, y: 0, width: 8, height: 6) {
        Text("!")
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(.white)
      }
    }
  }
}
