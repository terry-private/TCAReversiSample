//
//  CellView.swift
//  Reversi
//
//  Created by 若江照仁 on 2022/06/12.
//

import SwiftUI

extension Cell {
    struct View: SwiftUI.View {
        @State var state: Bool?
        var body: some SwiftUI.View {
            Button(
                action: {
                    guard state != nil else {
                        state = true
                        return
                    }
                    state?.toggle()
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
                    switch state {
                    case true:
                        Circle()
                            .padding(5)
                            .foregroundColor(.black)
                    case false:
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

struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        Cell.View()
    }
}
