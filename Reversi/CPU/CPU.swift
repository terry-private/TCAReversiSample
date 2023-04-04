//
//  CPU.swift
//  Reversi
//
//  Created by 若江照仁 on 2022/06/19.
//

import Foundation

enum CPU {
    static var count = 0
    private static let DEFAULT_DEPTH = 2
    enum Status {
        case notEnd
        case win
        case loose
        case even
        init(board: Board, side: Disk) {
            let myCount = board.count(of: side)
            let enemyCount = board.count(of: side)
            if myCount + enemyCount == board.width * board.height {
                self.init(myCount: myCount, enemyCount: enemyCount)
                return
            }
            if board.validMoves(for: .dark).count == 0 &&
                board.validMoves(for: .light).count == 0 {
                self.init(myCount: myCount, enemyCount: enemyCount)
                return
            }
            self = .notEnd
        }
        init(myCount: Int, enemyCount: Int) {
            if myCount > enemyCount {
                self = .win
            } else if myCount < enemyCount {
                self = .loose
            } else {
                self = .even
            }
        }
    }
    
    typealias xyPoint = (
        x: Int,
        y: Int,
        p: Int
    )
    
    static func put(board: Board, side: Disk) -> (Int, Int)? {
        let validMoves = board.validMoves(for: side)
        let highScore = validMoves.reduce(xyPoint(0,0,Int.min)) { maxPoint, validMove in
            let (x, y) = (validMove.x, validMove.y)
            var result = board
            try? result.place(side, atX: x, y: y)
            let score = getScore(board: result, side: side.flipped, me: side, depth: 2)
            return maxPoint.p < score ? (x, y, score) : maxPoint
        }
        return (highScore.x, highScore.y)
    }
    
    static func put2(board: Board, side: Disk) async throws -> (Int, Int)? {
//        try await Task.sleep(nanoseconds: 10)
//        return board.validMoves(for: side).randomElement()
        let task: Task<(Int, Int), Error> = Task.detached(priority: .background) {
            let validMoves = await SafeBoard.shared.validMoves(board: board, side)
            var highScore = xyPoint(0,0,Int.min)
            try await withThrowingTaskGroup(of: xyPoint.self) { group in
                validMoves.forEach { validMove in
                    group.addTask {
                        let (x, y) = (validMove.x, validMove.y)
                        let task: Task<Int, Error> = Task.detached {
                            var result = board
                            try? result.place(side, atX: x, y: y)
                            return try await getScore2(board: result, side: side.flipped, me: side, depth: 2)
                        }
                        let score = try await task.value
                        return (x, y, score)
                    }
                }
                for try await (currentScore) in group {
                    if highScore.p < currentScore.p { highScore = currentScore }
                }
            }
            return (highScore.x, highScore.y)
        }
        return try await task.value
    }
    
//    static func boardScore2(board: Board, side: Disk, me: Disk) async -> Int {
//
//    }
    
    static func boardScore(board: Board, side: Disk, me: Disk) -> Int {
        var score = side == me ? 0 : 50
        let enemy = me.flipped
        let myCount = board.count(of: side)
        let enemyCount = board.count(of: side)
        let total = myCount + enemyCount
        let remain = board.width * board.height - total
        let (myCorner, enemyCorner) = board.cornerCount(me)
        let (myCornerFront, enemyCornerFront) = board.cornerFrontCount(me)
        score += myCorner * 15
        score -= enemyCorner * 15
        if side == me {
            if remain > max(board.width, board.height) {
                score -= board.count(of: side)*2/3
                score -= myCornerFront
                score += enemyCornerFront
            } else {
                score += board.count(of: side)*2/3
            }
            score += board.validMoves(for: side).count
        } else {
            if remain > max(board.width, board.height) {
                score += board.count(of: side)*2/3
                score -= myCornerFront
                score += enemyCornerFront
            } else {
                score -= board.count(of: side)*2/3
            }
            score -= board.validMoves(for: side).count
        }
        return score
    }
    static func getScore(board: Board, side: Disk, me: Disk, depth: Int) -> Int {
        var score = side == me ? Int.min : Int.max
        for validMove in board.validMoves(for: side) {
            let (x, y) = validMove
            var result = board
            try? result.place(side, atX: x, y: y)
            var currentScore = 0
            let status = Status(board: result, side: me)
            switch status {
            case .notEnd:
                if depth > 0 {
                    currentScore = getScore(board: result, side: side.flipped, me: me, depth: depth - 1)
                } else {
                    currentScore = boardScore(board: result, side: side.flipped, me: me)
                }
//                score = getScore(board: result, side: side.flipped, me: me, depth: depth - 1)
            case .win:
                currentScore = 100
                if side == me {
                    return 100
                }
            case .loose:
                currentScore = -100
                if side != me {
                    return -100
                }
            case .even:
                currentScore = 0
            }
            score = side == me ? max(currentScore, score) : min(currentScore, score)
        }
        return score
    }
    
    static func getScore2(board: Board, side: Disk, me: Disk, depth: Int) async throws -> Int {
        var score = side == me ? Int.min : Int.max
        try await withThrowingTaskGroup(of: Int.self) { group in
            for validMove in await SafeBoard.shared.validMoves(board: board, side) {
                group.addTask {
                    let (x, y) = validMove
                    var result = board
                    try? result.place(side, atX: x, y: y)
                    var currentScore = 0
                    let status = Status(board: result, side: me)
                    switch status {
                    case .notEnd:
                        if depth > 0 {
                            currentScore = try await getScore2(board: result, side: side.flipped, me: me, depth: depth - 1)
                        } else {
                            currentScore = boardScore(board: result, side: side.flipped, me: me)
                        }
        //                score = getScore(board: result, side: side.flipped, me: me, depth: depth - 1)
                    case .win:
                        currentScore = 100
                        if side == me {
                            return 100
                        }
                    case .loose:
                        currentScore = -100
                        if side != me {
                            return -100
                        }
                    case .even:
                        currentScore = 0
                    }
                    return currentScore
                }
                
            }
            for try await (currentScore) in group {
                score = side == me ? max(currentScore, score) : min(currentScore, score)
            }
        }
        
        return score
    }
    
}
