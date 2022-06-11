//
//  Board.swift
//  Reversi
//
//  Created by 若江照仁 on 2022/06/12.
//

import Foundation
import ComposableArchitecture
import SwiftyReversi

enum Game {}

extension Game {
    struct State: Equatable {
        var board: Board
        var turn: Disk = .dark
        var hasValidMoves = true
        var darkCount = 2
        var lightCount = 2
        var isLoading = false
        var isPassAtPrevious = false
        init(size: Int) {
            board = Board(width: size, height: size)
        }
    }
    
    enum Action {
        case reset
        case turnStart
        case tappedCell(Int, Int)
        case put(Int, Int)
        case turnEnd
        case error(String)
        case checkHasValidMoves
        case passAlert
        case passed
        case undo
    }
    
    struct Environment {
        var mainQueue: AnySchedulerOf<DispatchQueue> = .main
        var histories: [Board] = []
    }
    
    static var reducer: Reducer<State, Action, Environment> {
        .init() { state, action ,environment in
            switch action {
            case .reset:
                state.board.reset()
                return .none
            case .turnStart:
                return .none
            case let .tappedCell(x, y):
                guard state.board.canPlaceDisk(state.turn, atX: x, y: y) else {
                    return .none
                }
                return Effect(value: Action.put(x, y))
                    .eraseToEffect()
            case let .put(x, y):
                try? state.board.place(state.turn, atX: x, y: y)
                state.darkCount = state.board.count(of: .dark)
                state.lightCount = state.board.count(of: .light)
                state.isLoading = true
                return Effect(value: Action.turnEnd)
                    .delay(for: 0.1, scheduler: environment.mainQueue)
                    .eraseToEffect()
            case .turnEnd:
                state.turn = state.turn.flipped
                return .none
            case .error(_):
                return .none
            case .checkHasValidMoves:
                return .none
            case .passAlert:
                return .none
            case .passed:
                return .none
            case .undo:
                return .none
            }
        }
    }
    
    static var store: Store<State, Action> {
        .init(initialState: State(size: 8), reducer: reducer, environment: Environment())
    }
}
