//
//  CellView.swift
//  Reversi
//
//  Created by 若江照仁 on 2022/06/12.
//

import SwiftUI
import ComposableArchitecture

extension Cell {
    struct View: SwiftUI.View {
        let store: Store<State, Action>
        
        var body: some SwiftUI.View {
            WithViewStore(store) { viewStore in
                Button(
                    action: {
                        viewStore.send(.flipped)
                    }
                ) {
                    ZStack {
                        Rectangle()
                            .aspectRatio(1.0, contentMode: .fit)
                            .foregroundColor(.primary)
                        Rectangle()
                            .aspectRatio(1.0, contentMode: .fit)
                            .foregroundColor(.green)
                            .padding(1)
                        switch viewStore.disk {
                        case .dark:
                            Circle()
                                .padding(5)
                                .foregroundColor(.black)
                        case .light:
                            Circle()
                                .padding(5)
                                .foregroundColor(.white)
                        default:
                            EmptyView()
                        }
                    }
                }
                .aspectRatio(contentMode: .fit)
            }
        }
    }
}

struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        Cell.View(store: Cell.getStore(turn: .light))
    }
}
