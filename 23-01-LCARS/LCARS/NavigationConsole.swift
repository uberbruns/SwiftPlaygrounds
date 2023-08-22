//
//  NavigationConsole.swift
//  LCARS
//
//  Created by Karsten Bruns on 15.01.23.
//

import SwiftUI

struct NavigationConsole: View {
    var body: some View {
      LCARSPanel(patchSize: CGSize(width: 16, height: 16), rows: 48, columns: 64, padding: 2) { x, y in
        let vBeamWidth = 14.0
        let hBeamHeight = 4.0

        // Header
        LCARSPatch(x: 0, y: 0, width: 64, height: 9) {
          HStack(alignment: .top, spacing: 4) {
            LCARSArc(outerRadius: y(8), innerRadius: y(2), vBeamWidth: x(vBeamWidth), hBeamHeight: x(hBeamHeight))
              .lcarsFilled(Color("Blueberry 25"))
              .overlay(alignment: .bottomLeading) {
              }
            LCARSText("Navigation", size: x(4))
              .foregroundColor(Color("Orange 50"))
              .padding(.horizontal, 8)
            LCARSRect()
              .lcarsFilled(Color("Blueberry 50"))
              .frame(width: x(10), height: x(4))
              .lcarsLabel("Console CFG", color: .black)
            LCARSPill(rounded: .right)
              .lcarsFilled(Color("Blueberry 25"))
              .frame(width: x(4), height: x(4))
          }
        }

        // Interstellar
        LCARSPatch(x: 0, y: 9, width: vBeamWidth, height: 3) {
          LCARSPill(rounded: .left)
            .lcarsFilled(Color("Plum 50"))
            .lcarsLabel("Interstellar", color: .black)
        }

        // Star System
        LCARSPatch(x: 0, y: 12, width: vBeamWidth, height: 3) {
          LCARSPill(rounded: .left)
            .lcarsHollow(Color("Plum 25"))
            .lcarsLabel("Star System", color: Color("Plum 25"))
        }
      }
      .padding()
      .padding()
      .background(.black)
    }
}

struct NavigationConsole_Previews: PreviewProvider {
    static var previews: some View {
        NavigationConsole()
    }
}
