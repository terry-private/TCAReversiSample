//
//  SafeBoard.swift
//  Reversi
//
//  Created by 若江照仁 on 2022/06/27.
//

import Foundation

actor SafeBoard {
    private init() {}
    private static var _shared = SafeBoard()
    static var shared: SafeBoard { _shared }
    var cache = [Board.Situation: [(x: Int, y: Int)]]()
    func validMoves(board: Board, _ disk: Disk) -> [(x: Int, y: Int)] {
        let situation = board.getSituation(side: disk)
        if let fromCache = cache[situation] {
            return fromCache
        }
        let coordinates = board.validMoves(for: disk)
        cache[situation] = coordinates
        return coordinates
    }
}
