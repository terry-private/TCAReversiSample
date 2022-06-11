//
//  BoardView.swift
//  Reversi
//
//  Created by 若江照仁 on 2022/06/12.
//

import SwiftUI

extension Board {
    struct View: SwiftUI.View {
        let boardSize = 8
        var body: some  SwiftUI.View {
            HStack(spacing: 0) {
                ForEach(0..<boardSize) {x in
                    VStack(spacing: 0) {
                        ForEach(0..<boardSize) {y in
                            
                            Cell.View(store: Cell.getStore(turn: .light))
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        Board.View()
    }
}
