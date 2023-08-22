import Foundation


struct Crewman: DataSourceItem {
  let id: String
  let name: String
}


struct Ship: DataSourceItem {
  let id: String
  let `class`: String
  let crew: [Crewman]
}


struct RowViewModel: DataSourceItem {
  let id: String
  let title: String
}


let enterpriseOriginal = Ship(id: "1701", class: "Constitution", crew: [Crewman(id: "kirk", name: "Kirk"), Crewman(id: "spock", name: "Spock")])
let enterpriseD = Ship(id: "1701-D", class: "Galaxy", crew: [Crewman(id: "picard", name: "picard"), Crewman(id: "picard", name: "Picard")])
let ships = [enterpriseOriginal, enterpriseD]

let shipDataSource = ArrayDataSource(items: ships)
let crewDataSource = shipDataSource
  .source(for: \.crew, of: enterpriseD.id)
  .map { crewman in
    RowViewModel(id: crewman.id, title: crewman.name)
  }

