//
//  CellView.swift
//  Reversi
//
//  Created by 若江照仁 on 2022/06/12.
//

import SwiftUI
import ComposableArchitecture
//
//extension Cell {
//    struct View: SwiftUI.View {
//        let store: Store<State, Action>
//        
//        var body: some SwiftUI.View {
//            WithViewStore(store) { viewStore in
//                Button(
//                    action: {
//                        viewStore.send(.tapped(viewStore.x, viewStore.y))
//                    }
//                ) {
//                    ZStack {
//                        Rectangle()
//                            .aspectRatio(1.0, contentMode: .fit)
//                            .foregroundColor(.black)
//                        Rectangle()
//                            .aspectRatio(1.0, contentMode: .fit)
//                            .foregroundColor(Color(red: 0.3, green: 0.5, blue: 0.3, opacity: 1))
//                            .padding(1)
//                        switch viewStore.disk {
//                        case .dark:
//                            Circle()
//                                .padding(5)
//                                .foregroundColor(.black)
//                        case .light:
//                            Circle()
//                                .padding(5)
//                                .foregroundColor(.white)
//                        default:
//                            EmptyView()
//                        }
//                    }
//                }
//                .aspectRatio(contentMode: .fit)
//            }
//        }
//    }
//}
//
//struct CellView_Previews: PreviewProvider {
//    static var previews: some View {
//        Cell.View(store: Cell.getStore(x: 0, y: 0))
//    }
//}
