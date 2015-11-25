//: Playground - noun: a place where people can play

import UIKit

let candidates = ["affe", "elefant", "blauwal", "maus", "wüstenfuchs"]

let vote0 = [1,3,2,4,0]
let vote1 = [1,3,0,2,4]
let vote2 = [3,2,4,1,0]
let vote3 = [1,2,0,3,4]
let vote4 = [1,2,4,0,3]
let vote5 = [4,3,2,0,1]

//let vote0 = [0,3,2,4,1]
//let vote1 = [0,3,2,4,1]
//let vote2 = [0,3,2,4,1]
//let vote3 = [1,2,4,3,0]
//let vote4 = [1,3,2,4,0]
//let vote5 = [4,3,2,0,1]

let votes = [vote0,vote1,vote2,vote3,vote4,vote5]


struct SimpleMatrix {
    
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


struct SchulzeVoting<T> {
    
    var candidates: [T]
    
    init(candidates: [T]) {
        self.candidates = candidates
    }
    
    
    func winnerListForVotes(votes: [[Int]]) -> [T] {
        
        let numberOfCandidates = candidates.count
        var voteMatrix = SimpleMatrix()
        var winnerList = [T]()
        
        for candidateA in 0..<numberOfCandidates {
            for candidateB in 0..<numberOfCandidates {
                guard candidateA != candidateB else { continue }
                let aOverB = numberOfVotesPrefering(candidateA, over: candidateB, votes: votes, numberOfCandidates: numberOfCandidates)
                let bOverA = numberOfVotesPrefering(candidateB, over: candidateA, votes: votes, numberOfCandidates: numberOfCandidates)
                let value = aOverB > bOverA ? aOverB : 0
                voteMatrix.set(candidateA, candidateB, value: value)
            }
        }
        
        
        for candidateA in 0..<numberOfCandidates {
            for candidateB in 0..<numberOfCandidates {
                guard candidateA != candidateB else { continue }
                for candidateK in 0..<numberOfCandidates {
                    guard candidateA != candidateK && candidateB != candidateK else { continue }
                    let value = max(voteMatrix.get(candidateB, candidateK), min(voteMatrix.get(candidateB, candidateA), voteMatrix.get(candidateA, candidateK)))
                    voteMatrix.set(candidateB, candidateK, value: value)
                }
            }
        }
        
        
        for candidateA in 0..<numberOfCandidates {
            var isWinner = true
            for candidateB in 0..<numberOfCandidates {
                guard candidateA != candidateB else { continue }
                isWinner = isWinner && (voteMatrix.get(candidateA, candidateB) >= voteMatrix.get(candidateB, candidateA))
            }
            if isWinner {
                winnerList.append(candidates[candidateA]);
            }
        }
        
        return winnerList
    }
    
    
    private func numberOfVotesPrefering(a: Int, over b: Int, votes: [[Int]], numberOfCandidates: Int) -> Int {
        var votesPreferingAoverB = 0
        for vote in votes {
            let indexOfA = vote.indexOf(a) ?? numberOfCandidates - 1
            let indexOfB = vote.indexOf(b) ?? numberOfCandidates - 1
            if indexOfA < indexOfB {
                votesPreferingAoverB++
            }
        }
        return votesPreferingAoverB
    }

    
}


let voting = SchulzeVoting(candidates: candidates)
let result = voting.winnerListForVotes(votes)

