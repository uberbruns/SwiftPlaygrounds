//
//  main.swift
//  Map
//
//  Created by Karsten Bruns on 27.08.19.
//  Copyright © 2019 bruns.me. All rights reserved.
//

import Foundation



enum Sections: CaseIterable, Hashable {
  case a, b, c
}


var defaultTitle: String? = nil
var sections = Map(keys: Sections.self, default: (title: defaultTitle, rows: [Int]()))

sections[.a].rows.append(1)
sections[.a].rows.append(2)
sections[.c].rows.append(99)

print(sections[.b])

for (key, value) in sections.filter({ !$0.1.rows.isEmpty }) {
  print(key, value)
}
