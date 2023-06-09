//
//  GameView.swift
//  Reversi
//
//  Created by 若江照仁 on 2022/06/12.
//

import SwiftUI
import ComposableArchitecture
import SwiftyReversi

extension Game {
    struct View: SwiftUI.View {
        let boardSize = 8
        let store: Store<State, Action>
        var body: some SwiftUI.View {
            WithViewStore(store) { viewStore in
                ZStack {
                    VStack(spacing: 0) {
                        //////////////////////////////// HeaderView ////////////////////////////////
                        HStack {
                            Text("\(viewStore.turn == .dark ? "黒" : "白")のターンです")
                                .padding()
                        }
                        
                        //////////////////////////////// BoardView ////////////////////////////////
                        ForEach(viewStore.board.yRange, id: \.self) {y in
                            HStack(spacing: 0) {
                                ForEach(viewStore.board.xRange, id: \.self) {x in
                                    cell(at: x, y, viewStore)
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    
                    //////////////////////////////// LoadingView ////////////////////////////////
                    if viewStore.isLoading {
                        ProgressView("Now Loading...")
                            .fixedSize()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.black)
                            .opacity(0.5)
                    }
                }
                .fullScreenCover(isPresented: viewStore.binding(get: \.shouldShowSetting, send: Action.toggleSetting)) {
                    Setting.View(store: store.scope(state: \.setting,action: Action.endSetting))
                }
                .alert(store.scope(state: \.passAlert), dismiss: .passAlertDismissed)
                .alert(store.scope(state: \.endAlert), dismiss: .endAlertDismissed)
            }
        }
        private func cell(at x: Int, _ y: Int, _ viewStore: ViewStore<State, Action>) -> some SwiftUI.View {
            Button(
                action: {
                    viewStore.send(.tapped(x, y))
                }
            ) {
                ZStack {
                    Rectangle()
                        .stroke(.black, lineWidth: 1)
                        .aspectRatio(1.0, contentMode: .fit)
                        .background(Color(red: 0.3, green: 0.5, blue: 0.3, opacity: 1))
                    switch viewStore.board[x, y] {
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

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        Game.View(store: Game.store)
    }
}
