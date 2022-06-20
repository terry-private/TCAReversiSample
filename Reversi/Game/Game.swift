//
//  Board.swift
//  Reversi
//
//  Created by 若江照仁 on 2022/06/12.
//

import ComposableArchitecture
import SwiftyReversi

enum Game {}
extension Game {
    struct State: Equatable {
        var board: Board
        var turn: Disk = .dark
        var hasValidMoves = true
        var isWaitingTap = true
        var isLoading = false
        var isPassAtPrevious = false
        var passAlert: AlertState<Action>?
        var endAlert: AlertState<Action>?
        var shouldShowSetting: Bool = true
        var setting: Setting.State
        init() {
            setting = .init()
            board = Board(width: setting.size.value, height: setting.size.value)
            board.reset()
        }
    }
    
    enum Action: Equatable {
        case toggleSetting(Bool)
        case endSetting(Setting.Action)
        case gameStart
        case turnStart
        case tapped(Int, Int)
        case put(Int, Int)
        case turnEnd
        case undo
        case passAlert
        case passAlertDismissed
        case endAlert
        case endAlertDismissed
        case gameEnd
    }
    
    struct Environment {
        var mainQueue: AnySchedulerOf<DispatchQueue> = .main
        var histories: [Board] = []
    }
    
    static var reducer: Reducer<State, Action, Environment> {
        .combine(
            Setting.reducer.pullback(
                state: \State.setting,
                action: /Action.endSetting,
                environment: { _ in Setting.Environment() }
            ),
            Reducer<State, Action, Environment>() { state, action ,environment in
                switch action {
                case let .toggleSetting(shouldShowSetting):
                    state.shouldShowSetting = shouldShowSetting
                    return .none
                case let .endSetting(action):
                    switch action {
                    case let .set(setting):
                        state.setting = setting
                        state.board = Board(width: setting.size.value, height: setting.size.value)
                        state.board.reset()
                        state.shouldShowSetting = false
                    default:
                        return .none
                    }
                    return Effect(value: .gameStart)
                        .delay(for: 0.3, scheduler: environment.mainQueue)
                        .eraseToEffect()
                case .gameStart:
                    // 始まったことを示すアニメーションとかあった方がいいかも
                    return Effect(value: .turnStart)
                        .eraseToEffect()
                    
                case .turnStart:
                    if state.board.validMoves(for: state.turn).isEmpty {
                        return Effect(value: state.isPassAtPrevious ? .endAlert : .passAlert)
                    }
                    switch state.setting.player(state.turn) {
                    case .human:
                        state.isPassAtPrevious = false
                        state.isLoading = false
                        state.isWaitingTap = true
                        return .none
                    case .cpu:
                        guard let (x, y) = CPU.put(board: state.board, side: state.turn) else {
                            return Effect(value: .passAlert)
                                .eraseToEffect()
                        }
                        return Effect(value: .put(x, y))
                            .eraseToEffect()
                    }
                    
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
                        .delay(for: 0.1, scheduler: environment.mainQueue)
                        .eraseToEffect()
                    
                case .turnEnd:
                    state.turn = state.turn.flipped
                    return Effect(value: .turnStart)
                        .eraseToEffect()
                    
                case .passAlert:
                    state.isPassAtPrevious = true
                    state.passAlert = .init(title: TextState("置ける場所がありません。\nパスします。"))
                    return .none
                    
                case .passAlertDismissed:
                    state.passAlert = nil
                    return Effect(value: .turnEnd)
                        .eraseToEffect()
                    
                case .undo:
                    return .none
                    
                case .endAlert:
                    state.isPassAtPrevious = false
                    var message = ""
                    switch state.board.sideWithMoreDisks() {
                    case .light:
                        message = "白の勝ち"
                    case .dark:
                        message = "黒の勝ち"
                    case nil:
                        message = "引き分け"
                    }
                    state.endAlert = .init(title: TextState("ゲーム終了\n黒 \(state.board.count(of: .dark)) : 白 \(state.board.count(of: .light))\n\(message)"))
                    return .none
                    
                case .endAlertDismissed:
                    state.endAlert = nil
                    return Effect(value: .gameEnd)
                        .eraseToEffect()
                    
                case .gameEnd:
                    state = State()
                    return .none
                }
            }
        )
    }
    
    static var store: Store<State, Action> {
        .init(initialState: State(), reducer: reducer, environment: Environment())
    }
}
