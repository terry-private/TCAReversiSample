//
//  Cell.swift
//  Reversi
//
//  Created by 若江照仁 on 2022/06/12.
//

import Foundation
import ComposableArchitecture
import SwiftyReversi

enum Cell {}

extension Cell {
    struct State: Equatable {
        var disk: Disk?
    }
    
    enum Action {
        case flipped
    }
    
    struct Environment: Equatable {
        let turn: Disk
    }
    
    static var reducer: Reducer<State, Action, Environment> {
        .init() { state, action, environment in
            switch action {
            case .flipped:
                state.disk = environment.turn
                return .none
            }
        }
    }
        
    static func getStore(turn: Disk, disk: Disk? = nil) -> Store<State, Action> {
        return .init(initialState: State(disk: disk), reducer: reducer, environment: Environment(turn: turn))
    }
}
