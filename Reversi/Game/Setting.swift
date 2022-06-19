//
//  Setting.swift
//  Reversi
//
//  Created by 若江照仁 on 2022/06/18.
//

import SwiftUI
import ComposableArchitecture
import SwiftyReversi

enum Setting{}

enum Player: Int {
    case human
    case cpu
}
enum BoardSize: Int, CaseIterable {
    case six
    case eight
    case ten
    var value: Int {
        switch self {
        case .six:      return 6
        case .eight:    return 8
        case .ten:      return 10
        }
    }
}

extension Setting {
    static let SIZES = [6, 8, 10]
    struct State: Equatable {
        var darkPlayer: Player = .human
        var lightPlayer: Player = .cpu
        var size: BoardSize = .eight
        func player(_ turn: Disk) -> Player {
            return turn == .dark ? darkPlayer : lightPlayer
        }
    }
    enum Action: Equatable {
        case start(State)
        case setDarkPlayer(Int)
        case setLightPlayer(Int)
        case setSize(Int)
    }
    struct Environment {}
    
    static var reducer = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case .start(_):
            return .none
        case let .setDarkPlayer(rawValue):
            state.darkPlayer = Player(rawValue: rawValue) ?? .human
            return .none
        case let .setLightPlayer(rawValue):
            state.lightPlayer = Player(rawValue: rawValue) ?? .human
            return .none
        case let .setSize(index):
            state.size = BoardSize(rawValue: index) ?? .eight
            return .none
        }
    }
    static var store = Store<State, Action>(initialState: State(), reducer: reducer, environment: Environment())
    
    struct View: SwiftUI.View {
        @SwiftUI.State var selection = 0
        let store: Store<State, Action>
        var body: some SwiftUI.View {
            
            WithViewStore(store) { viewStore in
                NavigationView {
                    ZStack {
                        Form {
                            Section("プレイヤー") {
                                HStack {
                                    HStack {
                                        ZStack {
                                            Rectangle()
                                                .stroke(.black, lineWidth: 1)
                                                .frame(width: 35, height: 35)
                                                .background(Color(red: 0.3, green: 0.5, blue: 0.3, opacity: 1))
                                            Circle()
                                                .foregroundColor(.black)
                                                .frame(width: 25)
                                        }
                                        Text("黒")
                                    }
                                    Spacer()
                                    Picker(
                                        selection: viewStore.binding(
                                            get: \.darkPlayer.rawValue,
                                            send: Action.setDarkPlayer
                                        ),
                                        label: Text("黒")
                                    ) {
                                        Text("人間")
                                            .tag(0)
                                        Text("AI")
                                            .tag(1)
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .frame(width: 150)
                                    
                                }
                                HStack {
                                    HStack {
                                        ZStack {
                                            Rectangle()
                                                .stroke(.black, lineWidth: 1)
                                                .frame(width: 35, height: 35)
                                                .background(Color(red: 0.3, green: 0.5, blue: 0.3, opacity: 1))
                                            Circle()
                                                .foregroundColor(.white)
                                                .frame(width: 25)
                                        }
                                        Text("白")
                                    }
                                    Spacer()
                                    Picker(
                                        selection: viewStore.binding(
                                            get: \.lightPlayer.rawValue,
                                            send: Action.setLightPlayer
                                        ),
                                        label: Text("白")
                                    ) {
                                        Text("人間")
                                            .tag(0)
                                        Text("AI")
                                            .tag(1)
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .frame(width: 150)
                                    
                                }
                            }
                            Section("ボードサイズ") {
                                Picker(
                                    selection: viewStore.binding(
                                        get: \.size.rawValue,
                                        send: Action.setSize
                                    ),
                                    label: Text("")
                                ) {
                                    Text("6")
                                        .tag(0)
                                    Text("8")
                                        .tag(1)
                                    Text("10")
                                        .tag(2)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                        }
                        VStack {
                            Spacer()
                            Button {
                                viewStore.send(.start(viewStore.state))
                            } label: {
                                Text("開始")
                                    .frame(width: 200.0, height: 40.0)
                                    .foregroundColor(.white)
                                    .background(.blue)
                                    .cornerRadius(20)
                            }
                            .padding([.bottom], 60)
                        }
                    }
                    .navigationTitle("ゲームモード")
                    .onDisappear {
                        viewStore.send(.start(viewStore.state))
                    }
                }
            }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        Setting.View(store: Setting.store)
    }
}
