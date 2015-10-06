//: Playground - noun: a place where people can play

import UIKit

let candidates = ["affe", "elefant", "blauwal", "maus", "wüstenfuchs"]

//let vote0 = [1,3,2,4,0]
//let vote1 = [1,3,0,2,4]
//let vote2 = [3,2,4,1,0]
//let vote3 = [1,2,0,3,4]
//let vote4 = [1,2,4,0,3]

let vote0 = [0,3,2,4,1]
let vote1 = [0,3,2,4,1]
let vote2 = [0,3,2,4,1]
let vote3 = [1,3,2,4,0]
let vote4 = [1,3,2,4,0]
let vote5 = [1,3,2,4,0]

let votes = [vote0,vote1,vote2,vote3,vote4,vote5]



struct Matrix {
    var data = [Int:[Int:Int]]()
    
    mutating func set(a: Int, _ b: Int, value: Int) {
        var x = data[a] ?? [Int:Int]()
        x[b] = value
        data[a] = x
    }
    
    func get(a: Int, _ b: Int) -> Int {
        return data[a]![b]!
    }
}


let candidatesCount = candidates.count
var pathMatrix = Matrix()
var winnerList = [String]()


func numberOfVotesPrefering(a: Int, over b: Int) -> Int {
    var x = 0
    for vote in votes {
        let ia = vote.indexOf(a) ?? candidates.count-1
        let ib = vote.indexOf(b) ?? candidates.count-1
        if ia < ib {
            x++
        }
    }
    return x
}


for candidateA in 0..<candidatesCount {
    for candidateB in 0..<candidatesCount {
        guard candidateA != candidateB else { continue }
        let aOverB = numberOfVotesPrefering(candidateA, over: candidateB)
        let bOverA = numberOfVotesPrefering(candidateB, over: candidateA)
        if aOverB > bOverA {
            pathMatrix.set(candidateA, candidateB, value: aOverB)
        } else {
            pathMatrix.set(candidateA, candidateB, value: 0)
        }
    }
}


for candidateA in 0..<candidatesCount {
    for candidateB in 0..<candidatesCount {
        guard candidateA != candidateB else { continue }
        for candidateK in 0..<candidatesCount {
            guard candidateA != candidateK && candidateB != candidateK else { continue }
            let value = max(pathMatrix.get(candidateB,candidateK), min(pathMatrix.get(candidateB,candidateA), pathMatrix.get(candidateA,candidateK)))
            pathMatrix.set(candidateB,candidateK, value: value)
        }
    }
}


for candidateA in 0..<candidatesCount {
    var isWinner = true
    for candidateB in 0..<candidatesCount {
        guard candidateA != candidateB else { continue }
        isWinner = isWinner && (pathMatrix.get(candidateA, candidateB) >= pathMatrix.get(candidateB, candidateA))
    }
    if (isWinner) {
        winnerList.append(candidates[candidateA]);
    }
}

print(winnerList)

