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
    struct State:Identifiable, Equatable {
        var id: Int
        var disk: Disk?
    }
    
    enum Action {
        case flipped(Disk)
        case tapped(Int, Int)
    }
    
    struct Environment: Equatable {}
    
    static var reducer: Reducer<State, Action, Environment> {
        .init() { state, action, environment in
            switch action {
            case let .flipped(disk):
                state.disk = disk
                return .none
            case .tapped(_, _):
                return .none
            }
        }
    }
        
    static func getStore(index: Int, disk: Disk? = nil) -> Store<State, Action> {
        return .init(initialState: State(id: index, disk: disk), reducer: reducer, environment: Environment())
    }
}
