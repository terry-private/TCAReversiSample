//
//  CPUTests.swift
//  ReversiTests
//
//  Created by 若江照仁 on 2022/06/19.
//

import XCTest
@testable import Reversi
import SwiftyReversi

class CPUTests: XCTestCase {
    func testCPUのputは置ける場所を指定しているかどうか() throws {
        var board = Board(width: 8, height: 8)
        board.reset()
        guard let (x, y) = CPU.put(board: board, side: .dark) else {
            XCTAssertNil(board.validMoves(for: .dark))
            return
        }
        do {
            try board.place(.dark, atX: x, y: y)
        } catch {
            guard let error = error as? Board.DiskPlacementError else {
                XCTFail("不明なエラー")
                return
            }
            XCTFail("\(error.disk.symbol) を x: \(error.x), y: \(error.y) には置けません。")
        }
    }
}
