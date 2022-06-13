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
        var size: Int
        var turn: Disk = .dark
        var hasValidMoves = true
        var isWaitingTap = true
        var isLoading = false
        var isPassAtPrevious = false
        var passAlert: AlertState<Action>?
        init(size: Int) {
            self.size = size
            board = Board(width: size, height: size)
            board.reset()
        }
    }
    
    enum Action: Equatable {
        case reset
        case turnStart
        case tapped(Int, Int)
        case put(Int, Int)
        case turnEnd
        case error(String)
        case passAlert
        case alertDismissed
        case undo
        case gameEnd
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
                if state.board.validMoves(for: state.turn).isEmpty {
                    if state.isPassAtPrevious {
                        return Effect(value: .gameEnd)
                            .eraseToEffect()
                    }
                    state.isPassAtPrevious = true
                    state.passAlert = .init(title: TextState("置ける場所がありません。\nパスします。"))
                    return .none
                }
                state.isPassAtPrevious = false
                state.isLoading = false
                state.isWaitingTap = true
                return .none
            case let .tapped(x, y):
                guard !state.isLoading,
                      state.isWaitingTap,
                      state.board.canPlaceDisk(state.turn, atX: x, y: y) else {
                    return .none
                }
                return Effect(value: .put(x, y))
                    .eraseToEffect()
            case let .put(x, y):
                try? state.board.place(state.turn, atX: x, y: y)
                state.isWaitingTap = false
                return Effect(value: .turnEnd)
                    .eraseToEffect()
            case .turnEnd:
                state.turn = state.turn.flipped
                return Effect(value: .turnStart)
                    .eraseToEffect()
            case .passAlert:
                return .none
            case .alertDismissed:
                state.passAlert = nil
                return Effect(value: .turnEnd)
                    .eraseToEffect()
            case .undo:
                return .none
            case .error(_):
                return .none
            case .gameEnd:
                return Effect(value: .reset)
                    .eraseToEffect()
            }
        }
    }
    
    static var store: Store<State, Action> {
        .init(initialState: State(size: 8), reducer: reducer, environment: Environment())
    }
}
