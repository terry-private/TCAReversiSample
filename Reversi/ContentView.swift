//
//  ContentView.swift
//  Reversi
//
//  Created by 若江照仁 on 2022/06/12.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Game.View(store: Game.store)
//        Setting.View(store: Setting.store)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
