//
//  CPU.swift
//  Reversi
//
//  Created by 若江照仁 on 2022/06/19.
//

import Foundation
import SwiftyReversi

enum CPU {
    static func put(board: Board, side: Disk) -> (Int, Int)? {
        let validMoves = board.validMoves(for: side)
        return validMoves.randomElement()
    }
}
