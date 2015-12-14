//: Playground - noun: a place where people can play

import UIKit

enum MediaType {
    case Book(pages: Int)
    case Movie(length: Int)
    case Album(tracks: Int)
}

extension MediaType : Equatable { }

func ==(lhs: MediaType, rhs: MediaType) -> Bool {
    switch (lhs, rhs) {
    case (.Book(let pagesLeft), .Book(let pagesRight)) :
        return pagesLeft == pagesRight
    case (.Movie(let lengthLeft), .Movie(let lengthRight)) :
        return lengthLeft == lengthRight
    case (.Album(let tracksLeft), .Album(let tracksRight)) :
        return tracksLeft == tracksRight
    default :
        return false
    }
}

let bookA = MediaType.Book(pages: 100)
let bookB = MediaType.Book(pages: 100)
let bookC = MediaType.Book(pages: 200)
let movieA = MediaType.Movie(length: 90)

print(bookA == bookB)  // true
print(bookA == bookC)  // false
print(bookA == movieA) // false

