enum Disk {
    case dark
    case light
}

extension Disk: Hashable {}

extension Disk {
    static var sides: [Disk] {
        [.dark, .light]
    }
    
    var flipped: Disk {
        switch self {
        case .dark: return .light
        case .light: return .dark
        }
    }
    
    mutating func flip() {
        self = flipped
    }
}


extension Disk {
    static func random() -> Disk {
        Bool.random() ? .dark : .light
    }
}

extension Disk: Equatable {}

extension Disk {
    var symbol: String {
        switch self {
        case .dark:
            return "x"
        case .light:
            return "o"
        }
    }
}

extension Optional where Wrapped == Disk {
    var symbol: String {
        switch self {
        case .some(let disk):
            return disk.symbol
        case .none:
            return "-"
        }
    }
}
