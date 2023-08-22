import SwiftUI


struct ContentView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack(alignment: .top, spacing: 4) {
        LCARSArc(outerRadius: 96, innerRadius: 24, vBeamWidth: 12 * 16, hBeamHeight: 64)
          .lcarsFilled(Color("Blueberry 25"))
        LCARSText("Navigation", size: 64)
          .foregroundColor(Color("Orange 50"))
          .padding(.horizontal, 8)
        LCARSRect()
          .lcarsFilled(Color("Blueberry 50"))
          .frame(width: 128, height: 64)
          .lcarsLabel("Console CFG", color: .black)
        LCARSPill(rounded: .right)
          .lcarsFilled(Color("Blueberry 25"))
          .frame(width: 48, height: 64)
      }
      .frame(height: 12 * 10)
      HStack(alignment: .center, spacing: 4) {
        LCARSPill(rounded: .left)
          .lcarsFilled(Color("Plum 50"))
          .frame(width: 12 * 16, height: 48)
          .lcarsLabel("Interstellar", color: .black)
      }
      HStack(alignment: .center, spacing: 4) {
        LCARSPill(rounded: .left)
          .lcarsHollow(Color("Plum 25"))
          .frame(width: 12 * 16, height: 48)
          .lcarsLabel("Star System", color: Color("Plum 25"))
      }
      HStack(alignment: .center, spacing: 4) {
        LCARSRect()
          .lcarsFilled(Color("Blueberry 25"))
          .frame(width: 12 * 16, height: 16 * 4)
          .lcarsLabel("Flight Path Calc", color: Color("Blueberry 50"))
      }
      HStack(alignment: .center, spacing: 4) {
        LCARSRect()
          .lcarsFilled(Color("Orange 50"))
          .frame(width: 12 * 16, height: 48)
          .lcarsLabel("Frame Of Reference", color: .black)
        LCARSText("GLX", size: 32)
          .foregroundColor(Color("Orange 50"))
          .padding(.horizontal, 8)
          .frame(width: 64, alignment: .center)
        LCARSPill(rounded: .right)
          .lcarsHollow(Color("Orange 50"))
          .frame(width: 48, height: 48)
      }
      HStack(alignment: .center, spacing: 4) {
        LCARSRect()
          .lcarsFilled(Color("Orange 75"))
          .frame(width: 12 * 16, height: 48)
          .lcarsLabel("Approach Vector", color: .black)
        LCARSText("D4", size: 32)
          .foregroundColor(Color("Orange 50"))
          .padding(.horizontal, 8)
          .frame(width: 64, alignment: .center)
        LCARSPill(rounded: .right)
          .lcarsFilled(Color("Orange 75"))
          .frame(width: 48, height: 48)
      }
    }
    .frame(width: 1280)
    .padding()
    .padding()
    .background(.black)
  }
}


extension View {
  func lcarsLabel(_ text: String, color: Color) -> some View {
    self
      .overlay(
        alignment: .bottomTrailing) {
          LCARSText(text, size: 14)
            .foregroundColor(color)
            .padding(8)
        }
  }
}


extension Shape {
  func lcarsFilled(_ color: Color) -> some View {
    return self
      .foregroundColor(color)
  }

  func lcarsHollow(_ color: Color) -> some View {
    let copy = self
    return self
      .stroke(color, lineWidth: 4)
      .foregroundColor(color)
      .clipShape(copy)
  }
}


struct LCARSText: View {

  let text: String
  let size: CGFloat

  init(_ text: String, size: CGFloat) {
    self.text = text
    self.size = size
  }

  var body: some View {
    Text(text)
      .font(.lcars(size: size * 1.37))
      .frame(height: size, alignment: .trailingLastTextBaseline)
      .kerning(1)
  }
}


extension Font {
  static func lcars(size: CGFloat) -> Font {
    Font(CTFontCreateWithName("LCARSGTJ3" as CFString, size, nil))
  }
}


struct LCARSRect: Shape {
  let cornerRadius: Double

  init(cornerRadius: Double = 0) {
    self.cornerRadius = cornerRadius
  }

  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.addRoundedRect(
      in: rect,
      cornerSize: CGSize(width: cornerRadius, height: cornerRadius)
    )
    return path
  }
}


struct LCARSPill: Shape {

  enum Roundness {
    case left
    case right
    case leftAndRight
  }

  let roundness: Roundness

  init(rounded roundness: Roundness) {
    self.roundness = roundness
  }

  func path(in rect: CGRect) -> Path {
    let radius = rect.height / 2
    var path = Path()
    switch roundness {
    case .left:
      path.move(to: CGPoint(x: radius, y: rect.maxY))
      path.addArc(
        center: CGPoint(x: radius, y: radius),
        radius: radius,
        startAngle: .degrees(90),
        endAngle: .degrees(270),
        clockwise: false
      )
      path.addLine(to: CGPoint(x: rect.maxX, y: 0))
      path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
      path.addLine(to: CGPoint(x: radius, y: rect.maxY))
    case .leftAndRight:
      path.move(to: CGPoint(x: radius, y: rect.maxY))
      path.addArc(
        center: CGPoint(x: radius, y: radius),
        radius: radius,
        startAngle: .degrees(90),
        endAngle: .degrees(270),
        clockwise: false
      )
      path.addArc(
        center: CGPoint(x: rect.maxX - radius, y: rect.maxY / 2),
        radius: radius,
        startAngle: .degrees(270),
        endAngle: .degrees(90),
        clockwise: false
      )
    case .right:
      path.move(to: CGPoint(x: 0, y: 0))
      path.addArc(
        center: CGPoint(x: rect.maxX - radius, y: rect.maxY / 2),
        radius: radius,
        startAngle: .degrees(270),
        endAngle: .degrees(90),
        clockwise: false
      )
      path.addLine(to: CGPoint(x: 0, y: rect.maxY))
      path.addLine(to: CGPoint(x: 0, y: 0))
    }
    return path
  }
}


struct LCARSArc: Shape {

  let outerRadius: Double
  let innerRadius: Double
  let vBeamWidth: Double
  let hBeamHeight: Double

  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: 0, y: outerRadius))
    path.addArc(
      center: CGPoint(x: outerRadius, y: outerRadius),
      radius: outerRadius,
      startAngle: .degrees(180),
      endAngle: .degrees(270),
      clockwise: false
    )
    path.addLine(to: CGPoint(x: rect.maxX, y: 0))
    path.addLine(to: CGPoint(x: rect.maxX, y: hBeamHeight))
    path.addLine(to: CGPoint(x: vBeamWidth + innerRadius, y: hBeamHeight))
    path.addArc(
      center: CGPoint(x: vBeamWidth + innerRadius , y: hBeamHeight + innerRadius),
      radius: innerRadius,
      startAngle: .degrees(270),
      endAngle: .degrees(180),
      clockwise: true
    )
    path.addLine(to: CGPoint(x: vBeamWidth, y: rect.maxY))
    path.addLine(to: CGPoint(x: 0, y: rect.maxY))
    return path
  }
}




struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

