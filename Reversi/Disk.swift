//
//  Disk.swift
//  Reversi
//
//  Created by 若江照仁 on 2022/06/12.
//

import Foundation

enum Disk {
    case light
    case dark
    var reverse: Disk {
        switch self {
        case .light: return .dark
        case .dark: return .light
        }
    }
}
