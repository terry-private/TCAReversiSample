//
//  GameView.swift
//  Reversi
//
//  Created by 若江照仁 on 2022/06/12.
//

import SwiftUI
import ComposableArchitecture

extension Game {
    struct View: SwiftUI.View {
        let boardSize = 8
        let store: Store<State, Action>
        var body: some  SwiftUI.View {
            WithViewStore(store) { viewStore in
                VStack(spacing: 0) {
                    ForEach(viewStore.board.yRange) {y in
                        HStack(spacing: 0) {
                            ForEach(viewStore.board.xRange) {x in
                                
                                Cell.View(store: Cell.getStore(turn: viewStore.turn, disk: viewStore.board[x,y]))
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        Game.View(store: Game.store)
    }
}
